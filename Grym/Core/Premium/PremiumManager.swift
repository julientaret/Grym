//
//  PremiumManager.swift
//  Grym
//
//  État de l'abonnement premium (achat unique non-consommable via StoreKit 2)
//  et limite du palier gratuit. `isPremium` reflète l'entitlement StoreKit,
//  mis en cache en UserDefaults pour un accès immédiat au lancement.
//

import Combine
import Foundation
import StoreKit

@MainActor
final class PremiumManager: ObservableObject {

    /// Nombre maximum de jeux distincts au palier gratuit.
    static let freeGameLimit = 10

    /// Identifiant produit (cf. StoreKit/Grym.storekit et App Store Connect).
    static let productID = "com.applemousse.grym.premium"

    @Published private(set) var isPremium: Bool
    /// Produit premium chargé depuis StoreKit (pour prix localisé + achat).
    @Published private(set) var product: Product?
    /// Achat/restauration en cours.
    @Published private(set) var isPurchasing = false

    private let storageKey = "isPremium"
    private var updatesTask: Task<Void, Never>?

    init() {
        isPremium = UserDefaults.standard.bool(forKey: storageKey)
        updatesTask = observeTransactionUpdates()
        Task {
            await loadProduct()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    /// Prix localisé du produit, ou `nil` si non chargé.
    var displayPrice: String? { product?.displayPrice }

    // MARK: - Chargement produit

    func loadProduct() async {
        product = try? await Product.products(for: [Self.productID]).first
    }

    // MARK: - Achat / restauration

    /// Lance l'achat du premium. Retourne `true` si l'achat est confirmé.
    @discardableResult
    func purchase() async -> Bool {
        guard let product, !isPurchasing else { return false }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    setPremium(true)
                    return true
                }
                return false
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    /// Restaure les achats (re-synchronise avec l'App Store).
    func restore() async {
        isPurchasing = true
        defer { isPurchasing = false }
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    // MARK: - Entitlements

    /// Recalcule `isPremium` depuis les droits StoreKit courants.
    func refreshEntitlements() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                owned = true
            }
        }
        setPremium(owned)
    }

    /// Observe les transactions entrantes (achats hors app, révocations…).
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.refreshEntitlements()
                }
            }
        }
    }

    // MARK: - Cache

    private func setPremium(_ value: Bool) {
        guard value != isPremium else { return }
        isPremium = value
        UserDefaults.standard.set(value, forKey: storageKey)
    }
}

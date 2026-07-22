//
//  PremiumBenefit.swift
//  Grym
//
//  Avantages du premium présentés sur le paywall. Volontairement limités
//  à ce que l'app débloque réellement aujourd'hui.
//

import Foundation

struct PremiumBenefit: Identifiable {
    let icon: String
    let titleKey: TranslationKey
    let detailKey: TranslationKey

    var id: TranslationKey { titleKey }

    /// Les trois avantages effectivement livrés par l'achat.
    static let all: [PremiumBenefit] = [
        PremiumBenefit(icon: "infinity",
                       titleKey: .premiumBenefitUnlimited,
                       detailKey: .premiumBenefitUnlimitedDetail),
        PremiumBenefit(icon: "paintpalette.fill",
                       titleKey: .premiumBenefitThemes,
                       detailKey: .premiumBenefitThemesDetail),
        PremiumBenefit(icon: "chart.bar.fill",
                       titleKey: .premiumBenefitStats,
                       detailKey: .premiumBenefitStatsDetail)
    ]
}

//
//  CoverStore.swift
//  Grym
//
//  Stockage local des jaquettes IGDB (offline-first). Les images sont
//  téléchargées à l'ajout d'un jeu et rangées dans Application Support,
//  nommées par `image_id`. Reconstruction d'URL à la demande sinon.
//

import Foundation

nonisolated enum CoverStore {

    /// Dossier des jaquettes (créé et exclu du backup au besoin).
    private static var directory: URL {
        // `.applicationSupportDirectory` est toujours présent : force unwrap justifié.
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("Covers", isDirectory: true)

        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            var mutable = dir
            var values = URLResourceValues()
            values.isExcludedFromBackup = true // ré-téléchargeable : hors backup iCloud
            try? mutable.setResourceValues(values)
        }
        return dir
    }

    /// Chemin local (existant ou non) d'une jaquette.
    static func localURL(for imageId: String) -> URL {
        directory.appendingPathComponent("\(imageId).jpg")
    }

    /// URL locale si le fichier est présent, sinon `nil`.
    static func existingLocalURL(for imageId: String) -> URL? {
        let url = localURL(for: imageId)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    /// Télécharge la jaquette si absente en local. Retourne l'URL locale.
    @discardableResult
    static func downloadIfNeeded(
        imageId: String,
        size: IGDBImageSize = .coverBig
    ) async -> URL? {
        let dest = localURL(for: imageId)
        if FileManager.default.fileExists(atPath: dest.path) { return dest }
        guard let remote = size.url(imageId: imageId) else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: remote)
            guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode) else { return nil }
            try data.write(to: dest, options: .atomic)
            return dest
        } catch {
            return nil
        }
    }

    /// Supprime la jaquette locale d'un jeu.
    static func delete(imageId: String) {
        try? FileManager.default.removeItem(at: localURL(for: imageId))
    }
}

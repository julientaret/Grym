//
//  ImageStore.swift
//  Grym
//
//  Stockage local des images de blocs (photos). Les données choisies sont
//  ré-encodées en JPEG downscalé et rangées dans Application Support.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

nonisolated enum ImageStore {

    /// Dossier des images de blocs (créé et exclu du backup au besoin).
    private static var directory: URL {
        // `.applicationSupportDirectory` est toujours présent : force unwrap justifié.
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("BlockImages", isDirectory: true)

        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            var mutable = dir
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try? mutable.setResourceValues(values)
        }
        return dir
    }

    /// URL locale d'une image par nom de fichier.
    static func url(for fileName: String) -> URL {
        directory.appendingPathComponent(fileName)
    }

    /// Enregistre des données image (JPEG downscalé) et retourne le nom de fichier.
    static func save(_ data: Data) -> String? {
        let name = "\(UUID().uuidString).jpg"
        let dest = url(for: name)
        let encoded = jpegData(from: data) ?? data
        do {
            try encoded.write(to: dest, options: .atomic)
            return name
        } catch {
            return nil
        }
    }

    /// Supprime une image locale.
    static func delete(fileName: String) {
        try? FileManager.default.removeItem(at: url(for: fileName))
    }

    // MARK: Ré-encodage

    private static func jpegData(
        from data: Data,
        maxDimension: CGFloat = 1600,
        quality: CGFloat = 0.8
    ) -> Data? {
#if canImport(UIKit)
        guard let image = UIImage(data: data) else { return nil }
        let size = image.size
        let largest = max(size.width, size.height)
        guard largest > 0 else { return nil }

        let scale = min(1, maxDimension / largest)
        let target = CGSize(width: size.width * scale, height: size.height * scale)

        // Échelle 1 : la taille en pixels = taille cible (évite un upscale ×3 écran).
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        let scaled = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
        return scaled.jpegData(compressionQuality: quality)
#else
        return nil
#endif
    }
}

//
//  SiteAssetManager.swift
//  WebMakr
//
//  Handles importing images via drag-and-drop and managing site assets.
//

import Foundation
import SwiftUI

class SiteAssetManager {
    static let shared = SiteAssetManager()
    
    private init() {}
    
    /// Storage directory for site assets
    func getBaseStorageURL(for siteSlug: String) -> URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportDirectory = paths[0]
        let base = appSupportDirectory.appendingPathComponent("WebMakr", isDirectory: true)
            .appendingPathComponent(siteSlug, isDirectory: true)
            .appendingPathComponent("assets", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base
    }
    
    /// Sanitize a string for a slug
    func slugify(_ text: String) -> String {
        let sanitized = text.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "[^a-z0-9-]", with: "", options: .regularExpression)
        return sanitized.isEmpty ? "site" : sanitized
    }
    
    /// Process a dropped file
    func importAsset(from url: URL, siteName: String, type: AssetType) throws -> String {
        let siteSlug = slugify(siteName)
        let ext = url.pathExtension.lowercased()
        
        // Validate extension
        let supported = ["png", "jpg", "jpeg", "svg", "ico", "webp"]
        guard supported.contains(ext) else {
            throw NSError(domain: "SiteAssetManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unsupported image format: .\(ext)"])
        }
        
        // Good SEO-friendly slug
        let filename = "\(siteSlug)-\(type.rawValue).\(ext)"
        let destinationDir = getBaseStorageURL(for: siteSlug)
        let destinationURL = destinationDir.appendingPathComponent(filename)
        
        // Clean up old files of same type but different extensions if needed?
        // For simplicity, just handle this specific filename
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        // Copy to internal storage
        try FileManager.default.copyItem(at: url, to: destinationURL)
        
        print("📁 [AssetManager] Imported \(type.rawValue) to: \(destinationURL.path)")
        
        return destinationURL.absoluteString
    }
    
    enum AssetType: String {
        case logo = "logo"
        case favicon = "favicon"
    }
}

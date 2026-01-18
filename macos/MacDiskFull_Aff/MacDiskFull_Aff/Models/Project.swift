//
//  Project.swift
//  WebMakr
//
//  Project model - wraps a Site with metadata for multi-project support
//  Compatible with macOS 11.0 (Big Sur) and later
//

import Foundation

/// A WebMakr project containing a site and metadata
struct Project: Identifiable, Codable {
    static let schemaVersion = 1
    
    let version: Int
    let projectId: UUID
    var displayName: String
    var createdAt: Date
    var updatedAt: Date
    var site: Site
    
    // Convenience property
    var id: UUID { projectId }
    
    init(
        version: Int = Project.schemaVersion,
        projectId: UUID = UUID(),
        displayName: String = "New Project",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        site: Site = Site()
    ) {
        self.version = version
        self.projectId = projectId
        self.displayName = displayName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.site = site
    }
    
    /// Create a project from an existing site
    static func from(site: Site) -> Project {
        Project(
            displayName: site.name,
            site: site
        )
    }
    
    /// Create a duplicate with new ID
    func duplicate(newName: String? = nil) -> Project {
        Project(
            displayName: newName ?? "\(displayName) Copy",
            site: site
        )
    }
}

// MARK: - Project Storage Manager

class ProjectStorage {
    static let shared = ProjectStorage()
    
    let fileManager = FileManager.default
    
    /// Base directory for WebMakr data
    var appSupportDirectory: URL {
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupport = urls[0].appendingPathComponent("WebMakr")
        return appSupport
    }
    
    /// Directory for project files
    var projectsDirectory: URL {
        appSupportDirectory.appendingPathComponent("Projects")
    }
    
    /// Directory for template files
    var templatesDirectory: URL {
        appSupportDirectory.appendingPathComponent("Templates")
    }
    
    /// File storing the current project ID
    private var currentProjectFile: URL {
        appSupportDirectory.appendingPathComponent("current_project.txt")
    }
    
    private init() {
        ensureDirectoriesExist()
    }
    
    /// Create directories if they don't exist
    func ensureDirectoriesExist() {
        try? fileManager.createDirectory(at: projectsDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: templatesDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Project CRUD
    
    /// Get path for a project file
    func projectPath(for projectId: UUID) -> URL {
        projectsDirectory.appendingPathComponent("\(projectId.uuidString).json")
    }
    
    /// Save a project to disk
    func save(_ project: Project) throws {
        var projectToSave = project
        projectToSave.updatedAt = Date()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(projectToSave)
        let path = projectPath(for: project.projectId)
        try data.write(to: path)
    }
    
    /// Load a project from disk
    func load(projectId: UUID) throws -> Project {
        let path = projectPath(for: projectId)
        let data = try Data(contentsOf: path)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Project.self, from: data)
    }
    
    /// Load a project from any URL
    func load(from url: URL) throws -> Project {
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Project.self, from: data)
    }
    
    /// Delete a project from disk
    func delete(projectId: UUID) throws {
        let path = projectPath(for: projectId)
        try fileManager.removeItem(at: path)
    }
    
    /// List all projects
    func listProjects() -> [ProjectSummary] {
        guard let contents = try? fileManager.contentsOfDirectory(at: projectsDirectory, includingPropertiesForKeys: [.contentModificationDateKey]) else {
            return []
        }
        
        var summaries: [ProjectSummary] = []
        
        for url in contents where url.pathExtension == "json" {
            if let summary = loadProjectSummary(from: url) {
                summaries.append(summary)
            }
        }
        
        return summaries.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    /// Load just the summary (faster than full project)
    private func loadProjectSummary(from url: URL) -> ProjectSummary? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Try to decode just the header fields
        guard let project = try? decoder.decode(Project.self, from: data) else { return nil }
        
        return ProjectSummary(
            projectId: project.projectId,
            displayName: project.displayName,
            siteName: project.site.name,
            productCount: project.site.products.count,
            createdAt: project.createdAt,
            updatedAt: project.updatedAt
        )
    }
    
    // MARK: - Current Project
    
    /// Get the current project ID
    func getCurrentProjectId() -> UUID? {
        guard let data = try? Data(contentsOf: currentProjectFile),
              let string = String(data: data, encoding: .utf8),
              let uuid = UUID(uuidString: string.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }
        return uuid
    }
    
    /// Set the current project ID
    func setCurrentProjectId(_ projectId: UUID) {
        try? projectId.uuidString.write(to: currentProjectFile, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Migration from UserDefaults
    
    /// Migrate from UserDefaults to file-based storage (one-time)
    func migrateFromUserDefaultsIfNeeded() -> Project? {
        // Check if already migrated (projects folder has files)
        if !listProjects().isEmpty {
            return nil
        }
        
        // Check for UserDefaults data
        let legacyKey = "WebMakr_CurrentSite"
        guard let data = UserDefaults.standard.data(forKey: legacyKey) else {
            return nil
        }
        
        // Try to decode the site
        let decoder = JSONDecoder()
        guard let site = try? decoder.decode(Site.self, from: data) else {
            return nil
        }
        
        // Create a new project from the site
        let project = Project.from(site: site)
        
        // Save it
        try? save(project)
        setCurrentProjectId(project.projectId)
        
        // Don't delete UserDefaults yet (one version fallback)
        // UserDefaults.standard.removeObject(forKey: legacyKey)
        
        return project
    }
    
    // MARK: - Import/Export
    
    /// Export project to a URL
    func exportProject(_ project: Project, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(project)
        try data.write(to: url)
    }
    
    /// Export just the site portion
    func exportSite(_ site: Site, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(site)
        try data.write(to: url)
    }
    
    /// Import a site and merge into project
    func importSite(from url: URL) throws -> Site {
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Site.self, from: data)
    }
}

// MARK: - Project Summary (lightweight for list views)

struct ProjectSummary: Identifiable {
    let projectId: UUID
    let displayName: String
    let siteName: String
    let productCount: Int
    let createdAt: Date
    let updatedAt: Date
    
    var id: UUID { projectId }
}

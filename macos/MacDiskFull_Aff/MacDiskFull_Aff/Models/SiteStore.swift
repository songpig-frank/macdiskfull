//
//  SiteStore.swift
//  WebMakr
//
//  Main Data Store - Multi-project support with file-based storage
//  Compatible with macOS 11.0 (Big Sur) and later
//

import Foundation
import SwiftUI
import Combine

/// Main observable store for the site builder
class SiteStore: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentProject: Project
    @Published var projectLibrary: [ProjectSummary] = []
    @Published var selectedProductId: UUID?
    @Published var isLoading: Bool = false
    
    // UI State
    @Published var showTemplatePicker: Bool = false
    @Published var showSaveTemplateView: Bool = false
    
    // Error Handling
    @Published var lastError: String?
    
    private let storage = ProjectStorage.shared
    
    // MARK: - Initialization
    
    init() {
        // Try migration first
        if let migratedProject = storage.migrateFromUserDefaultsIfNeeded() {
            self.currentProject = migratedProject
        } else if let currentId = storage.getCurrentProjectId(),
                  let project = try? storage.load(projectId: currentId) {
            // Load current project
            self.currentProject = project
        } else {
            // First run or no projects - create default
            let defaultProject = Project.from(site: Site.sampleMacDiskFull)
            self.currentProject = defaultProject
            try? storage.save(defaultProject)
            storage.setCurrentProjectId(defaultProject.projectId)
        }
        
        // Load project library
        refreshProjectLibrary()
    }
    
    // MARK: - Convenience Accessors
    
    var site: Site {
        get { currentProject.site }
        set {
            currentProject.site = newValue
            saveCurrentProject()
        }
    }
    
    // MARK: - Project Library
    
    func refreshProjectLibrary() {
        projectLibrary = storage.listProjects()
    }
    
    func switchToProject(_ projectId: UUID) {
        do {
            let project = try storage.load(projectId: projectId)
            currentProject = project
            storage.setCurrentProjectId(projectId)
            selectedProductId = nil
        } catch {
            lastError = "Failed to load project: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Project CRUD
    
    func createNewProject(name: String = "New Project") -> Project {
        var newSite = Site()
        newSite.name = name
        
        let project = Project(displayName: name, site: newSite)
        
        do {
            try storage.save(project)
            currentProject = project
            storage.setCurrentProjectId(project.projectId)
            refreshProjectLibrary()
        } catch {
            lastError = "Failed to create project: \(error.localizedDescription)"
        }
        
        return project
    }
    
    func duplicateProject(_ projectId: UUID) {
        guard let original = try? storage.load(projectId: projectId) else { return }
        
        let duplicate = original.duplicate()
        
        do {
            try storage.save(duplicate)
            refreshProjectLibrary()
        } catch {
            lastError = "Failed to duplicate: \(error.localizedDescription)"
        }
    }
    
    func renameProject(_ projectId: UUID, newName: String) {
        do {
            var project = try storage.load(projectId: projectId)
            project.displayName = newName
            try storage.save(project)
            
            if projectId == currentProject.projectId {
                currentProject.displayName = newName
            }
            
            refreshProjectLibrary()
        } catch {
            lastError = "Failed to rename: \(error.localizedDescription)"
        }
    }
    
    func deleteProject(_ projectId: UUID) {
        // Don't delete the current project if it's the only one
        if projectLibrary.count <= 1 && projectId == currentProject.projectId {
            lastError = "Cannot delete the only project"
            return
        }
        
        do {
            try storage.delete(projectId: projectId)
            
            // If deleted current project, switch to another
            if projectId == currentProject.projectId {
                refreshProjectLibrary()
                if let first = projectLibrary.first {
                    switchToProject(first.projectId)
                }
            } else {
                refreshProjectLibrary()
            }
        } catch {
            lastError = "Failed to delete: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Persistence
    
    func saveCurrentProject() {
        do {
            try storage.save(currentProject)
        } catch {
            lastError = "Failed to save: \(error.localizedDescription)"
        }
    }
    
    /// Convenience method for backward compatibility
    func save() {
        saveCurrentProject()
    }
    
    func resetToSample() {
        currentProject.site = Site.sampleMacDiskFull
        currentProject.displayName = "MacDiskFull.com"
        selectedProductId = nil
        saveCurrentProject()
        refreshProjectLibrary()
    }
    
    // MARK: - Import/Export
    
    func exportProject(to url: URL) throws {
        try storage.exportProject(currentProject, to: url)
    }
    
    func saveAsTemplate(name: String, description: String) {
        let template = Template.from(
            site: currentProject.site,
            name: name,
            description: description
        )
        do {
            try storage.saveTemplate(template)
        } catch {
            lastError = "Failed to save template: \(error.localizedDescription)"
        }
    }
    
    func exportSite(to url: URL) throws {
        try storage.exportSite(currentProject.site, to: url)
    }
    
    func importProject(from url: URL) throws {
        let project = try storage.load(from: url)
        
        // Save with a new ID to avoid conflicts
        var importedProject = project
        // Keep the same ID if it doesn't exist locally
        let existingIds = Set(projectLibrary.map { $0.projectId })
        if existingIds.contains(project.projectId) {
            // Create new ID for duplicate
            importedProject = Project(
                displayName: project.displayName,
                site: project.site
            )
        }
        
        try storage.save(importedProject)
        currentProject = importedProject
        storage.setCurrentProjectId(importedProject.projectId)
        refreshProjectLibrary()
    }
    
    func importSite(from url: URL) throws -> ImportReport {
        let importedSite = try storage.importSite(from: url)
        
        var report = ImportReport()
        
        // Merge products
        for importedProduct in importedSite.products {
            // Try to find existing product by ID or name
            if let existingIndex = currentProject.site.products.firstIndex(where: { 
                $0.id == importedProduct.id || 
                $0.name.lowercased() == importedProduct.name.lowercased() 
            }) {
                currentProject.site.products[existingIndex] = importedProduct
                report.updatedCount += 1
            } else {
                currentProject.site.products.append(importedProduct)
                report.importedCount += 1
            }
        }
        
        // Update site fields
        currentProject.site.name = importedSite.name
        currentProject.site.tagline = importedSite.tagline
        currentProject.site.domain = importedSite.domain
        currentProject.site.theme = importedSite.theme
        currentProject.site.affiliateSettings = importedSite.affiliateSettings
        
        // Enforce single recommended
        var foundRecommended = false
        for i in currentProject.site.products.indices {
            if currentProject.site.products[i].isRecommended {
                if foundRecommended {
                    currentProject.site.products[i].isRecommended = false
                    report.warnings.append("Multiple recommended products found; keeping only the first")
                } else {
                    foundRecommended = true
                }
            }
        }
        
        saveCurrentProject()
        return report
    }
    
    // MARK: - Products
    
    var selectedProduct: Product? {
        get {
            guard let id = selectedProductId else { return nil }
            return currentProject.site.products.first { $0.id == id }
        }
        set {
            if let newValue = newValue,
               let index = currentProject.site.products.firstIndex(where: { $0.id == newValue.id }) {
                currentProject.site.products[index] = newValue
                saveCurrentProject()
            }
        }
    }
    
    func addProduct() {
        var newProduct = Product()
        newProduct.name = "New Product"
        newProduct.sortOrder = currentProject.site.products.count + 1
        currentProject.site.products.append(newProduct)
        selectedProductId = newProduct.id
        saveCurrentProject()
    }
    
    func deleteProduct(_ product: Product) {
        currentProject.site.products.removeAll { $0.id == product.id }
        if selectedProductId == product.id {
            selectedProductId = currentProject.site.products.first?.id
        }
        // Re-order remaining products
        for i in currentProject.site.products.indices {
            currentProject.site.products[i].sortOrder = i + 1
        }
        saveCurrentProject()
    }
    
    func moveProduct(from source: IndexSet, to destination: Int) {
        currentProject.site.products.move(fromOffsets: source, toOffset: destination)
        // Update sort orders
        for i in currentProject.site.products.indices {
            currentProject.site.products[i].sortOrder = i + 1
        }
        saveCurrentProject()
    }
    
    // MARK: - Computed Properties
    
    var sortedProducts: [Product] {
        currentProject.site.products.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    var recommendedProduct: Product? {
        currentProject.site.products.first { $0.isRecommended }
    }
}

// MARK: - Import Report

struct ImportReport {
    var importedCount: Int = 0
    var updatedCount: Int = 0
    var warnings: [String] = []
    
    var summary: String {
        var parts: [String] = []
        if importedCount > 0 {
            parts.append("\(importedCount) new product(s) added")
        }
        if updatedCount > 0 {
            parts.append("\(updatedCount) product(s) updated")
        }
        if parts.isEmpty {
            return "No changes made"
        }
        return parts.joined(separator: ", ")
    }
}

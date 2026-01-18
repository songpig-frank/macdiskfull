//
//  TemplatePickerView.swift
//  WebMakr
//
//  Template picker for creating new projects from templates
//  Compatible with macOS 11.0 (Big Sur) and later
//

import SwiftUI

struct TemplatePickerView: View {
    @ObservedObject var store: SiteStore
    @Binding var isPresented: Bool
    
    @State private var templates: [TemplateSummary] = []
    @State private var selectedCategory: TemplateCategory? = nil
    @State private var selectedTemplateId: UUID? = nil
    @State private var newProjectName: String = ""
    
    private let storage = ProjectStorage.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New Project")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Category Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryPill(
                        title: "All",
                        icon: "square.grid.2x2",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    ForEach(TemplateCategory.allCases, id: \.self) { category in
                        CategoryPill(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Template Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 200, maximum: 250), spacing: 16)
                ], spacing: 16) {
                    ForEach(filteredTemplates) { template in
                        TemplateCard(
                            template: template,
                            isSelected: selectedTemplateId == template.templateId,
                            action: { selectedTemplateId = template.templateId }
                        )
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer with project name and create button
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Project Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("My New Project", text: $newProjectName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 200)
                }
                
                Spacer()
                
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)
                
                Button("Create Project") {
                    createProject()
                }
                .keyboardShortcut(.return)
                .disabled(selectedTemplateId == nil)
                .buttonStyle(DefaultButtonStyle())
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 600, height: 500)
        .onAppear {
            loadTemplates()
        }
    }
    
    private var filteredTemplates: [TemplateSummary] {
        if let category = selectedCategory {
            return templates.filter { $0.category == category }
        }
        return templates
    }
    
    private func loadTemplates() {
        templates = storage.listTemplates()
        // Pre-select first template
        selectedTemplateId = templates.first?.templateId
    }
    
    private func createProject() {
        guard let templateId = selectedTemplateId,
              let template = storage.loadTemplate(id: templateId) else {
            return
        }
        
        let projectName = newProjectName.isEmpty ? template.templateName : newProjectName
        
        // Create new project from template
        var newSite = template.site
        newSite.name = projectName
        
        let project = Project(
            displayName: projectName,
            site: newSite
        )
        
        do {
            try storage.save(project)
            store.currentProject = project
            storage.setCurrentProjectId(project.projectId)
            store.refreshProjectLibrary()
            isPresented = false
        } catch {
            print("Failed to create project: \(error)")
        }
    }
}

// MARK: - Category Pill

struct CategoryPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Template Card

struct TemplateCard: View {
    let template: TemplateSummary
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Icon and category
                HStack {
                    Image(systemName: template.category.icon)
                        .font(.title2)
                        .foregroundColor(.accentColor)
                    
                    Spacer()
                    
                    if template.isBuiltIn {
                        Text("Built-in")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                // Name
                Text(template.templateName)
                    .font(.headline)
                    .lineLimit(1)
                
                // Description
                Text(template.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                // Meta
                HStack {
                    Text("\(template.productCount) products")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(template.category.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(height: 140)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct TemplatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        TemplatePickerView(store: SiteStore(), isPresented: .constant(true))
    }
}

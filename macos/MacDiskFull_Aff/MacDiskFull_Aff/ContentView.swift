//
//  ContentView.swift
//  WebMakr
//
//  Main app interface with Projects sidebar + 4 main sections
//  Compatible with macOS 11.0 (Big Sur) and later
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var store: SiteStore
    @State private var
        selectedSection:
        SidebarSection? =
        .siteSettings
    @State private var
        showProjectsPopover = false
    @State private var showAffiliateManager = false
    
    enum SidebarSection: String, CaseIterable, Hashable {
        case siteSettings = "Site Settings"
        case products = "Products"
        case articles = "Articles"
        case preview = "Preview"
        case generate = "Generate"
    }
    
    var body: some View {
        NavigationView {
            // Sidebar
            VStack(spacing: 0) {
                // Project Selector at top
                Button(action: { showProjectsPopover.toggle() }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.currentProject.displayName)
                                .font(.headline)
                                .lineLimit(1)
                            Text("\(store.site.products.count) products")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
                .popover(isPresented: $showProjectsPopover) {
                    ProjectsPopover(store: store, isPresented: $showProjectsPopover)
                }
                
                Divider()
                
                // Main sections
                List(selection: $selectedSection) {
                    Label("Site Settings", systemImage: "gearshape")
                        .tag(SidebarSection.siteSettings)
                    
                    Label("Products", systemImage: "cube.box")
                        .tag(SidebarSection.products)
                    
                    Label("Articles", systemImage: "doc.text")
                        .tag(SidebarSection.articles)
                    
                    Label("Preview", systemImage: "eye")
                        .tag(SidebarSection.preview)
                    
                    Label("Generate", systemImage: "arrow.down.doc")
                        .tag(SidebarSection.generate)
                }
                .listStyle(SidebarListStyle())
            }
            .frame(minWidth: 200)
            
            // Detail view based on selection
            detailView
        }
        .frame(minWidth: 900, minHeight: 600)
        .navigationTitle(store.currentProject.displayName)
        .sheet(isPresented: $store.showTemplatePicker) {
            TemplatePickerView(store: store, isPresented: $store.showTemplatePicker)
        }
        .sheet(isPresented: $store.showSaveTemplateView) {
            SaveTemplateView(store: store, isPresented: $store.showSaveTemplateView)
        }
        .sheet(isPresented: $showAffiliateManager) {
            AffiliateNetworkListView(enabledNetworks: $store.site.affiliateSettings.globalAffiliateIds)
                .frame(width: 900, height: 600)
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch selectedSection {
        case .siteSettings:
            SiteSettingsView(site: Binding(
                get: { store.site },
                set: { store.site = $0 }
            ), showAffiliateManager: $showAffiliateManager, onSave: store.save, onReset: store.resetToSample)
        case .products:
            ProductsView(store: store)
        case .articles:
            ArticlesView(site: $store.site)
        case .preview:
            PreviewView(store: store)
        case .generate:
            GenerateView(store: store)
        case .none:
            WelcomeView()
        }
    }
}

// MARK: - Projects Popover

struct ProjectsPopover: View {
    @ObservedObject var store: SiteStore
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Projects")
                    .font(.headline)
                Spacer()
                Button(action: {
                    store.showTemplatePicker = true
                    isPresented = false
                }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            
            Divider()
            
            // Project List
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(store.projectLibrary) { project in
                        ProjectRow(
                            project: project,
                            isSelected: project.projectId == store.currentProject.projectId,
                            onSelect: {
                                store.switchToProject(project.projectId)
                                isPresented = false
                            },
                            onDuplicate: {
                                store.duplicateProject(project.projectId)
                            },
                            onDelete: {
                                store.deleteProject(project.projectId)
                            }
                        )
                    }
                }
                .padding()
            }
            .frame(maxHeight: 300)
        }
        .frame(width: 280)
        .onAppear {
            store.refreshProjectLibrary()
        }
    }
}

struct ProjectRow: View {
    let project: ProjectSummary
    let isSelected: Bool
    let onSelect: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(project.displayName)
                    .fontWeight(isSelected ? .semibold : .regular)
                HStack(spacing: 8) {
                    Text("\(project.productCount) products")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(project.updatedAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isHovering {
                HStack(spacing: 8) {
                    Button(action: onDuplicate) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Duplicate")
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Delete")
                }
            }
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
        .padding(8)
        .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
        .cornerRadius(6)
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// MARK: - Welcome View (Empty State)

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("Welcome to WebMakr")
                .font(.largeTitle.weight(.bold))
            
            Text("Select an item from the sidebar to get started")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Site Settings View (Moved to Views/SiteSettingsView.swift)

struct SummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body.weight(.medium))
        }
    }
}

// MARK: - Helper Views

struct LabeledTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var isMultiLine: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            if isMultiLine {
                TextEditor(text: $text)
                    .frame(minHeight: 60, maxHeight: 100)
                    .font(.body)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                TextField(placeholder.isEmpty ? label : placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

struct AssetPickerRow: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    let onBrowse: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack {
                TextField(placeholder.isEmpty ? label : placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: onBrowse) {
                    Label("Browse...", systemImage: "folder.badge.plus")
                }
                .controlSize(.small)
            }
        }
    }
}

struct ColorPickerField: View {
    let label: String
    @Binding var hex: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: hex) ?? Color.gray)
                    .frame(width: 28, height: 28)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                TextField("Hex", text: $hex)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 90)
            }
        }
    }
}

struct ThemePresetCard: View {
    let preset: SiteTheme
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                // Preview Box
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: preset.bgColor) ?? .black)
                    
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: preset.primaryColor) ?? .blue)
                            .frame(height: 12)
                        
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: preset.cardColor) ?? .gray)
                                .frame(height: 20)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: preset.cardColor) ?? .gray)
                                .frame(height: 20)
                        }
                    }
                    .padding(8)
                    
                    // Selection indicator
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.blue))
                                    .font(.system(size: 14))
                                    .padding(4)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                )
                
                Text(preset.name)
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SiteStore())
    }
}

// MARK: - Logo Decoration Preview Component

@available(macOS 12.0, *)
struct LogoDecorationPreview: View {
    let logoURL: String?
    let shape: LogoShape
    let decoration: LogoDecoration
    let decoColor: Color
    let bgColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background (matching theme)
                RoundedRectangle(cornerRadius: 12)
                    .fill(bgColor)
                    .frame(width: 140, height: 80)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                
                // Decoration Layer
                decorationView
                
                // Logo Image
                logoView
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text("Header Preview").font(.caption2).foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var logoView: some View {
        if let urlString = logoURL, !urlString.isEmpty, let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "photo").foregroundColor(.gray)
            }
            .frame(width: 80, height: 40)
        } else {
            Text("Logo").font(.caption2).foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var decorationView: some View {
        switch decoration {
        case .none:
            EmptyView()
        case .glow:
            if shape == .square {
                RoundedRectangle(cornerRadius: 12)
                    .fill(decoColor.opacity(0.3))
                    .blur(radius: 12)
                    .frame(width: 50, height: 50)
            } else {
                Capsule()
                    .fill(decoColor.opacity(0.3))
                    .blur(radius: 12)
                    .frame(width: 100, height: 50)
            }
        case .ring:
            if shape == .square {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(decoColor, lineWidth: 2)
                    .shadow(color: decoColor, radius: 8)
                    .frame(width: 50, height: 50)
            } else {
                Capsule()
                    .stroke(decoColor, lineWidth: 2)
                    .shadow(color: decoColor, radius: 8)
                    .frame(width: 100, height: 50)
            }
        case .glass:
            if shape == .square {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 50, height: 50)
            } else {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 100, height: 50)
            }
        }
    }
}

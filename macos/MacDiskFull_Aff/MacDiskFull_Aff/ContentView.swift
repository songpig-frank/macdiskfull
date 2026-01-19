//
//  ContentView.swift
//  WebMakr
//
//  Main app interface with Projects sidebar + 4 main sections
//  Compatible with macOS 11.0 (Big Sur) and later
//

import SwiftUI
import Combine

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

// MARK: - Site Settings View (MVP: Simplified)

struct SiteSettingsView: View {
    @Binding var site: Site
    @Binding var showAffiliateManager: Bool
    var onSave: () -> Void
    var onReset: () -> Void
    @State private var showResetConfirm = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Site Settings")
                        .font(.largeTitle.weight(.bold))
                    Text("Configure your comparison site")
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
                
                // Basic Info
                GroupBox(label: Label("Basic Information", systemImage: "info.circle")) {
                    VStack(alignment: .leading, spacing: 16) {
                        LabeledTextField(label: "Site Name", text: $site.name, placeholder: "My Comparison Site")
                        LabeledTextField(label: "Tagline", text: $site.tagline, placeholder: "Compare the best tools for...")
                        LabeledTextField(label: "Domain (optional)", text: $site.domain, placeholder: "example.com")
                    }
                    .padding()
                    .onChange(of: site.name) { _ in onSave() }
                    .onChange(of: site.tagline) { _ in onSave() }
                    .onChange(of: site.domain) { _ in onSave() }
                }
                
                // Branding - Logo & Favicon
                GroupBox(label: Label("Branding", systemImage: "photo")) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Logo and favicon for your site. Use URLs to images (PNG, SVG, or ICO).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LabeledTextField(label: "Logo URL", text: Binding(
                            get: { site.logoURL ?? "" },
                            set: { site.logoURL = $0.isEmpty ? nil : $0 }
                        ), placeholder: "https://example.com/logo.png")
                        
                        LabeledTextField(label: "Favicon URL", text: Binding(
                            get: { site.faviconURL ?? "" },
                            set: { site.faviconURL = $0.isEmpty ? nil : $0 }
                        ), placeholder: "https://example.com/favicon.ico")
                        
                        // Preview (if URLs exist) - macOS 12+ only
                        if #available(macOS 12.0, *) {
                            HStack(spacing: 20) {
                                if let logoURL = site.logoURL, !logoURL.isEmpty {
                                    VStack {
                                        AsyncImage(url: URL(string: logoURL)) { image in
                                            image.resizable().aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            Image(systemName: "photo").foregroundColor(.gray)
                                        }
                                        .frame(width: 80, height: 40)
                                        Text("Logo").font(.caption2).foregroundColor(.secondary)
                                    }
                                }
                                if let faviconURL = site.faviconURL, !faviconURL.isEmpty {
                                    VStack {
                                        AsyncImage(url: URL(string: faviconURL)) { image in
                                            image.resizable().aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            Image(systemName: "photo").foregroundColor(.gray)
                                        }
                                        .frame(width: 32, height: 32)
                                        Text("Favicon").font(.caption2).foregroundColor(.secondary)
                                    }
                                }
                            }
                        } else {
                            // Fallback for macOS 11
                            if site.logoURL != nil || site.faviconURL != nil {
                                Text("Preview requires macOS 12+")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
                
                // Theme (MVP: Just primary color)
                GroupBox(label: Label("Theme", systemImage: "paintbrush")) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 24) {
                            ColorPickerField(label: "Primary Color", hex: $site.theme.primaryColor)
                        }
                        
                        Text("Dark theme is used by default for modern, professional look.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .onChange(of: site.theme.primaryColor) { _ in onSave() }
                }
                
                // SEO Optimization Engine Rules
                GroupBox(label: Label("AI Optimization Engine Rules", systemImage: "brain.head.profile")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Define current SEO logic and AI ranking factors to guide the Polish engine.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $site.optimizationRules)
                            .font(.system(.body, design: .monospaced))
                            .frame(minHeight: 120)
                            .padding(4)
                            .background(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            .onChange(of: site.optimizationRules) { _ in onSave() }
                    }
                    .padding()
                }
                
                // AI Provider Configuration
                GroupBox(label: Label("AI Configuration", systemImage: "cpu")) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Configure your AI provider for article generation and polishing.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Provider Picker
                        HStack {
                            Text("Provider:")
                                .frame(width: 80, alignment: .trailing)
                            Picker("", selection: $site.aiProvider) {
                                Text("OpenAI").tag("OpenAI")
                                Text("OpenRouter").tag("OpenRouter")
                                Text("Anthropic").tag("Anthropic")
                                Text("Gemini").tag("Gemini")
                                Text("Ollama").tag("Ollama")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: site.aiProvider) { _ in onSave() }
                        }
                        
                        Divider()
                        
                        // Provider-specific configuration
                        if site.aiProvider == "OpenAI" {
                            HStack {
                                Text("API Key:")
                                    .frame(width: 80, alignment: .trailing)
                                SecureField("sk-...", text: $site.openAIKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: site.openAIKey) { _ in onSave() }
                            }
                            HStack {
                                Text("Model:")
                                    .frame(width: 80, alignment: .trailing)
                                Picker("", selection: $site.aiModel) {
                                    Text("GPT-4o").tag("gpt-4o")
                                    Text("GPT-4o Mini").tag("gpt-4o-mini")
                                    Text("GPT-4 Turbo").tag("gpt-4-turbo")
                                    Text("GPT-3.5 Turbo").tag("gpt-3.5-turbo")
                                }
                                .onChange(of: site.aiModel) { _ in onSave() }
                            }
                            Text("Get your key at platform.openai.com/api-keys")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                
                        } else if site.aiProvider == "OpenRouter" {
                            HStack {
                                Text("API Key:")
                                    .frame(width: 80, alignment: .trailing)
                                SecureField("sk-or-...", text: $site.openAIKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: site.openAIKey) { _ in onSave() }
                            }
                            HStack {
                                Text("Model:")
                                    .frame(width: 80, alignment: .trailing)
                                Picker("", selection: $site.aiModel) {
                                    Text("Claude 3.5 Sonnet").tag("anthropic/claude-3.5-sonnet")
                                    Text("GPT-4o").tag("openai/gpt-4o")
                                    Text("Gemini Pro 1.5").tag("google/gemini-pro-1.5")
                                    Text("Llama 3.1 405B").tag("meta-llama/llama-3.1-405b-instruct")
                                    Text("Mixtral 8x22B").tag("mistralai/mixtral-8x22b")
                                    Text("DeepSeek V3").tag("deepseek/deepseek-chat")
                                }
                                .onChange(of: site.aiModel) { _ in onSave() }
                            }
                            Text("OpenRouter gives access to 100+ models. Get key at openrouter.ai")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                
                        } else if site.aiProvider == "Anthropic" {
                            HStack {
                                Text("API Key:")
                                    .frame(width: 80, alignment: .trailing)
                                SecureField("sk-ant-...", text: $site.anthropicKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: site.anthropicKey) { _ in onSave() }
                            }
                            HStack {
                                Text("Model:")
                                    .frame(width: 80, alignment: .trailing)
                                Picker("", selection: $site.aiModel) {
                                    Text("Claude 3.5 Sonnet").tag("claude-3-5-sonnet-20240620")
                                    Text("Claude 3 Opus").tag("claude-3-opus-20240229")
                                    Text("Claude 3 Haiku").tag("claude-3-haiku-20240307")
                                }
                                .onChange(of: site.aiModel) { _ in onSave() }
                            }
                            Text("Get your key at console.anthropic.com")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                
                        } else if site.aiProvider == "Gemini" {
                            HStack {
                                Text("API Key:")
                                    .frame(width: 80, alignment: .trailing)
                                SecureField("AIza...", text: $site.geminiKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: site.geminiKey) { _ in onSave() }
                            }
                            HStack {
                                Text("Model:")
                                    .frame(width: 80, alignment: .trailing)
                                Picker("", selection: $site.aiModel) {
                                    Text("Gemini 2.0 Flash").tag("gemini-2.0-flash")
                                    Text("Gemini 1.5 Pro").tag("gemini-1.5-pro")
                                    Text("Gemini 1.5 Flash").tag("gemini-1.5-flash")
                                }
                                .onChange(of: site.aiModel) { _ in onSave() }
                            }
                            Text("Get your key at aistudio.google.com/apikey")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                
                        } else if site.aiProvider == "Ollama" {
                            HStack {
                                Text("URL:")
                                    .frame(width: 80, alignment: .trailing)
                                TextField("http://localhost:11434", text: $site.ollamaURL)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: site.ollamaURL) { _ in onSave() }
                            }
                            HStack {
                                Text("Model:")
                                    .frame(width: 80, alignment: .trailing)
                                TextField("llama3.2, mistral, etc.", text: $site.aiModel)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: site.aiModel) { _ in onSave() }
                            }
                            Text("Ollama runs locally - no API key needed. Run 'ollama serve' first.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        // Status indicator
                        HStack {
                            if site.aiProvider == "OpenAI" && !site.openAIKey.isEmpty {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                Text("OpenAI configured (\(site.aiModel))").font(.caption)
                            } else if site.aiProvider == "OpenRouter" && !site.openAIKey.isEmpty {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                Text("OpenRouter configured (\(site.aiModel))").font(.caption)
                            } else if site.aiProvider == "Anthropic" && !site.anthropicKey.isEmpty {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                Text("Anthropic configured (\(site.aiModel))").font(.caption)
                            } else if site.aiProvider == "Gemini" && !site.geminiKey.isEmpty {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                Text("Gemini configured (\(site.aiModel))").font(.caption)
                            } else if site.aiProvider == "Ollama" {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                Text("Ollama configured (\(site.aiModel))").font(.caption)
                            } else {
                                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                                Text("Add your API key to enable AI features").font(.caption)
                            }
                        }
                    }
                    .padding()
                }
                
                // Affiliate Networks
                GroupBox(label: Label("Affiliate Networks", systemImage: "link.badge.plus")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Manage your affiliate programs.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Browse Database") {
                                showAffiliateManager = true
                            }
                        }
                        
                        Divider()
                        
                        if !site.affiliateSettings.globalAffiliateIds.isEmpty {
                            ForEach(site.affiliateSettings.globalAffiliateIds.keys.sorted(), id: \.self) { key in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    Text(key)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(site.affiliateSettings.globalAffiliateIds[key] ?? "")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }
                            }
                        } else {
                            Text("No networks enabled. Click Browse Database to add.")
                                .italic()
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .onChange(of: site.affiliateSettings.globalAffiliateIds) { _ in onSave() }
                }
                
                // Affiliate Disclosure
                GroupBox(label: Label("Affiliate Disclosure", systemImage: "doc.text")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This text appears in the footer of your site (required by FTC):")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $site.affiliateSettings.defaultAffiliateDisclosure)
                            .font(.body)
                            .frame(minHeight: 80)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding()
                    .onChange(of: site.affiliateSettings.defaultAffiliateDisclosure) { _ in onSave() }
                    .onChange(of: site.affiliateSettings.defaultAffiliateDisclosure) { _ in onSave() }
                }
                
                // Amazon Localization (GeniusLink)
                GroupBox(label: Label("Amazon Localization", systemImage: "globe.americas.fill")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Automatically localize Amazon links using GeniusLink (Amazon Link Engine).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LabeledTextField(label: "GeniusLink TSID", text: $site.affiliateSettings.geniusLinkTSID, placeholder: "e.g. 12345")
                        
                        if !site.affiliateSettings.geniusLinkTSID.isEmpty {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Localization active")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .onChange(of: site.affiliateSettings.geniusLinkTSID) { _ in onSave() }
                }
                
                // Summary
                GroupBox(label: Label("Site Summary", systemImage: "list.bullet")) {
                    VStack(alignment: .leading, spacing: 8) {
                        SummaryRow(label: "Products", value: "\(site.products.count)")
                        SummaryRow(label: "Recommended", value: site.products.first { $0.isRecommended }?.name ?? "None")
                    }
                    .padding()
                }
                
                // Reset Button
                GroupBox(label: Label("Reset", systemImage: "arrow.counterclockwise")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Load the sample MacDiskFull comparison site to see how WebMakr works.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: { showResetConfirm = true }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset to Sample Data")
                            }
                            .foregroundColor(.orange)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
        }
        .alert(isPresented: $showResetConfirm) {
            Alert(
                title: Text("Reset to Sample?"),
                message: Text("This will replace all your data with the MacDiskFull sample site. This cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    onReset()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

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

//
//  SiteSettingsView.swift
//  WebMakr
//
//  Refactored Dashboard-style Settings View
//  Organizes Site Configuration into logical grid
//

import SwiftUI
import AppKit // Required for NSColor
import UniformTypeIdentifiers

struct SiteSettingsView: View {
    @Binding var site: Site
    @Binding var showAffiliateManager: Bool
    var onSave: () -> Void
    var onReset: () -> Void
    
    @State private var showResetConfirm = false
    
    // Drop Targets
    @State private var isLogoTargeted = false
    @State private var isFaviconTargeted = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("Settings Dashboard")
                        .font(.largeTitle.bold())
                    Spacer()
                    Button(action: { showResetConfirm = true }) {
                        Label("Reset Project", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
                
                // Dashboard Grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 400), spacing: 20)], alignment: .leading, spacing: 20) {
                    
                    // 1. IDENTITY & BRANDING (Top priority)
                    VStack(spacing: 20) {
                        FormGroupBox(title: "Identity") {
                            LabeledTextField(label: "Site Name", text: $site.name, placeholder: "My Comparison Site")
                            LabeledTextField(label: "Tagline", text: $site.tagline, placeholder: "Compare the best tools for...")
                            LabeledTextField(label: "Domain", text: $site.domain, placeholder: "example.com")
                        }
                        
                        FormGroupBox(title: "Branding") {
                            // Logo
                            AssetPickerRow(label: "Logo", text: Binding(
                                get: { site.logoURL ?? "" },
                                set: { site.logoURL = $0.isEmpty ? nil : $0 }
                            ), placeholder: "Drop logo image...", onBrowse: {
                                browseForAsset(type: .logo)
                            })
                            .onDrop(of: [.fileURL], isTargeted: $isLogoTargeted) { providers in
                                handleAssetDrop(providers: providers, type: .logo)
                            }
                            
                            // Favicon
                            AssetPickerRow(label: "Favicon", text: Binding(
                                get: { site.faviconURL ?? "" },
                                set: { site.faviconURL = $0.isEmpty ? nil : $0 }
                            ), placeholder: "Drop favicon image...", onBrowse: {
                                browseForAsset(type: .favicon)
                            })
                            .onDrop(of: [.fileURL], isTargeted: $isFaviconTargeted) { providers in
                                handleAssetDrop(providers: providers, type: .favicon)
                            }
                            
                            Divider()
                            
                            // Compact styling preview
                            DisclosureGroup("Logo Styling & Preview") {
                                VStack(spacing: 12) {
                                    HStack {
                                        Picker("Layout", selection: $site.logoShape) {
                                            ForEach(LogoShape.allCases) { shape in Text(shape.rawValue).tag(shape) }
                                        }.labelsHidden()
                                        
                                        Picker("Effect", selection: $site.logoDecoration) {
                                            ForEach(LogoDecoration.allCases) { deco in Text(deco.rawValue).tag(deco) }
                                        }.labelsHidden()
                                        
                                        if site.logoDecoration != .none {
                                            ColorPickerField(label: "", hex: Binding(
                                                get: { site.logoDecorationColor ?? site.theme.primaryColor },
                                                set: { site.logoDecorationColor = $0 }
                                            ))
                                        }
                                    }
                                    
                                    if #available(macOS 12.0, *) {
                                        LogoDecorationPreview(
                                            logoURL: site.logoURL,
                                            shape: site.logoShape,
                                            decoration: site.logoDecoration,
                                            decoColor: Color(hex: site.logoDecorationColor ?? site.theme.primaryColor) ?? .blue,
                                            bgColor: Color(hex: site.theme.bgColor) ?? .black
                                        )
                                        .frame(height: 60)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    
                    // 2. CONTACT & SOCIAL (New features)
                    FormGroupBox(title: "Contact & Social") {
                        LabeledTextField(label: "Support Email", text: $site.contact.email, placeholder: "support@example.com")
                        LabeledTextField(label: "Address", text: $site.contact.address, placeholder: "Optional physical address")
                        
                        Divider()
                        
                        VStack(spacing: 10) {
                            Text("Social Profiles").font(.caption).foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .leading)
                            LabeledTextField(label: "X (Twitter)", text: $site.contact.twitterURL, placeholder: "https://x.com/...")
                            LabeledTextField(label: "LinkedIn", text: $site.contact.linkedinURL, placeholder: "https://linkedin.com/...")
                            LabeledTextField(label: "TikTok", text: $site.contact.tiktokURL, placeholder: "https://tiktok.com/...")
                            LabeledTextField(label: "YouTube", text: $site.contact.youtubeURL, placeholder: "https://youtube.com/...")
                        }
                    }
                    
                    // 3. INTEGRATIONS (Compact)
                    FormGroupBox(title: "Integrations") {
                        // AI
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AI Provider").font(.caption).bold()
                            HStack {
                                Picker("", selection: $site.aiProvider) {
                                    Text("OpenAI").tag("OpenAI")
                                    Text("OpenRouter").tag("OpenRouter")
                                    Text("Anthropic").tag("Anthropic")
                                }.labelsHidden()
                                
                                if site.aiProvider == "OpenAI" {
                                    SecureField("sk-...", text: $site.openAIKey).textFieldStyle(RoundedBorderTextFieldStyle())
                                } else if site.aiProvider == "Anthropic" {
                                    SecureField("sk-ant-...", text: $site.anthropicKey).textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Affiliates
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Affiliate Networks")
                                    .font(.caption).bold()
                                Text(site.affiliateSettings.globalAffiliateIds.isEmpty ? "None connected" : "\(site.affiliateSettings.globalAffiliateIds.count) active")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Manage") { showAffiliateManager = true }
                                .controlSize(.small)
                        }
                        
                        Divider()
                        
                        // GeniusLink
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amazon Localization").font(.caption).bold()
                            LabeledTextField(label: "GeniusLink TSID", text: $site.affiliateSettings.geniusLinkTSID, placeholder: "e.g. 12345")
                        }
                    }
                    
                    // 4. LEGAL & COMPLIANCE (Collapsible Disclosure)
                    FormGroupBox(title: "Legal & Compliance") {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Privacy Policy", isOn: $site.legal.includePrivacyPolicy)
                            Toggle("Terms of Service", isOn: $site.legal.includeTermsConditions)
                            Toggle("Cookie Policy", isOn: $site.legal.includeCookiePolicy)
                            Toggle("EULA (Software)", isOn: $site.legal.includeEULA)
                            
                            Divider()
                            
                            DisclosureGroup("Affiliate Disclosure (Footer)") {
                                TextEditor(text: $site.affiliateSettings.defaultAffiliateDisclosure)
                                    .font(.caption)
                                    .frame(minHeight: 80)
                                    .padding(4)
                                    .background(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.2)))
                                    .padding(.top, 4)
                            }
                        }
                    }
                    
                    // 5. THEME (Compact)
                    FormGroupBox(title: "Appearance") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Current Theme:")
                                Spacer()
                                Text(site.theme.name).bold()
                            }
                            
                            // Color Palette Preview
                            HStack(spacing: 8) {
                                ForEach([site.theme.primaryColor, site.theme.secondaryColor, site.theme.accentColor, site.theme.bgColor, site.theme.cardColor], id: \.self) { colorHex in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(hex: colorHex) ?? .gray)
                                        .frame(height: 20)
                                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.2)))
                                }
                            }
                            
                            DisclosureGroup("Customize Theme") {
                                VStack(spacing: 12) {
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                                        ForEach(SiteTheme.allPresets) { preset in
                                            Button(action: { site.theme = preset; onSave() }) {
                                                Text(preset.name)
                                                    .font(.caption)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(6)
                                                    .background(site.theme.name == preset.name ? Color.accentColor.opacity(0.1) : Color.clear)
                                                    .cornerRadius(4)
                                                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(site.theme.name == preset.name ? Color.accentColor : Color.gray.opacity(0.2)))
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    
                                    Divider()
                                    
                                    // Basic Color Pickers
                                    HStack {
                                        ColorPickerField(label: "Primary", hex: $site.theme.primaryColor)
                                        ColorPickerField(label: "Backgrnd", hex: $site.theme.bgColor)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    
                    // 6. ADVANCED (Collapsed)
                    FormGroupBox(title: "Advanced SEO") {
                        DisclosureGroup("Optimization Rules") {
                            TextEditor(text: $site.optimizationRules)
                                .font(.system(.caption, design: .monospaced))
                                .frame(minHeight: 100)
                                .padding(4)
                                .background(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.2)))
                        }
                    }
                    
                } // End Grid
            }
            .padding(30)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .alert(isPresented: $showResetConfirm) {
            Alert(
                title: Text("Reset to Sample?"),
                message: Text("This will replace all your data with the MacDiskFull sample site."),
                primaryButton: .destructive(Text("Reset")) {
                    onReset()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // Kept helper functions...
    private func handleAssetDrop(providers: [NSItemProvider], type: SiteAssetManager.AssetType) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
            var sourceURL: URL?
            if let url = item as? URL { sourceURL = url }
            else if let data = item as? Data { sourceURL = URL(dataRepresentation: data, relativeTo: nil) }
            
            guard let url = sourceURL else { return }
            
            DispatchQueue.main.async {
                do {
                    let newURLString = try SiteAssetManager.shared.importAsset(from: url, siteName: site.name, type: type)
                    if type == .logo { site.logoURL = newURLString } else { site.faviconURL = newURLString }
                    onSave()
                } catch {
                    print("Error importing asset: \(error)")
                }
            }
        }
        return true
    }
    
    private func browseForAsset(type: SiteAssetManager.AssetType) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]
        if panel.runModal() == .OK, let url = panel.url {
            let _ = handleAssetDrop(providers: [NSItemProvider(contentsOf: url)!], type: type)
        }
    }
}

// Helper for consistency
struct FormGroupBox<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            VStack(alignment: .leading, spacing: 16) { content }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.1), lineWidth: 1))
        }
    }
}


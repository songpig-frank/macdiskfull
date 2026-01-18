//
//  GenerateView.swift
//  WebMakr
//
//  MVP: Generate site to user-selected folder
//  Compatible with macOS 11.0 (Big Sur) and later
//

import SwiftUI
import UniformTypeIdentifiers
import Combine

struct GenerateView: View {
    @ObservedObject var store: SiteStore
    @State private var statusMessage: String = ""
    @State private var isSuccess: Bool = false
    @State private var lastOutputPath: URL?
    @State private var isGenerating: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "arrow.down.doc.fill")
                        .font(.system(size: 64))
                        .foregroundColor(Color(hex: store.site.theme.primaryColor) ?? .purple)
                    
                    Text("Generate Your Site")
                        .font(.largeTitle.weight(.bold))
                    
                    Text("Export your comparison site as static HTML files")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // What Will Be Generated
                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("What will be generated:", systemImage: "doc.on.doc")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FileRow(icon: "doc.text", name: "index.html", description: "Main comparison page")
                            FileRow(icon: "paintbrush", name: "style.css", description: "All styles (mobile-responsive)")
                            FileRow(icon: "globe", name: "robots.txt", description: "SEO: Allow search indexing")
                            if !store.site.domain.isEmpty {
                                FileRow(icon: "map", name: "sitemap.xml", description: "SEO: Page listing")
                            }
                            FileRow(icon: "folder", name: "assets/", description: "OG image & favicon placeholders")
                        }
                        .padding(.leading, 4)
                    }
                    .padding()
                }
                .frame(maxWidth: 500)
                
                // Site Summary
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Site Summary", systemImage: "list.bullet")
                            .font(.headline)
                        
                        Divider()
                        
                        HStack {
                            Text("Site Name")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(store.site.name)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Products")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(store.site.products.count)")
                                .fontWeight(.medium)
                        }
                        
                        if let recommended = store.site.products.first(where: { $0.isRecommended }) {
                            HStack {
                                Text("Featured")
                                    .foregroundColor(.secondary)
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    Text(recommended.name)
                                        .fontWeight(.medium)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        
                        if store.site.domain.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text("No domain set - canonical URLs will be omitted")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: 500)
                
                // Generate Button
                VStack(spacing: 16) {
                    Button(action: generateSite) {
                        HStack(spacing: 8) {
                            if isGenerating {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "hammer.fill")
                            }
                            Text(isGenerating ? "Generating..." : "Generate Site")
                        }
                        .font(.headline)
                        .frame(maxWidth: 300)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isGenerating || store.site.products.isEmpty)
                    
                    if store.site.products.isEmpty {
                        Text("Add at least one product to generate")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    // Open Folder Button
                    if let path = lastOutputPath {
                        Button(action: { NSWorkspace.shared.open(path) }) {
                            HStack {
                                Image(systemName: "folder")
                                Text("Open Generated Folder")
                            }
                        }
                    }
                }
                
                // Status Message
                if !statusMessage.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                            Text(isSuccess ? "Success!" : "Error")
                                .fontWeight(.semibold)
                        }
                        Text(statusMessage)
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if !isSuccess {
                            Text("Tip: Try selecting your Desktop or Documents folder instead.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(isSuccess ? .green : .red)
                    .padding()
                    .frame(maxWidth: 500)
                    .background((isSuccess ? Color.green : Color.red).opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func generateSite() {
        isGenerating = true
        statusMessage = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let generator = SiteGeneratorSync(site: store.site)
                let outputURL = try generator.generate()  // Generates to temp folder
                
                DispatchQueue.main.async {
                    isGenerating = false
                    lastOutputPath = outputURL
                    statusMessage = "Site generated! Files are ready in Finder."
                    isSuccess = true
                    
                    // Reveal in Finder
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: outputURL.path)
                }
            } catch {
                DispatchQueue.main.async {
                    isGenerating = false
                    statusMessage = "Failed: \(error.localizedDescription)"
                    isSuccess = false
                }
            }
        }
    }
}

struct FileRow: View {
    let icon: String
    let name: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(name)
                .fontWeight(.medium)
                .frame(width: 100, alignment: .leading)
            
            Text(description)
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}

struct GenerateView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateView(store: SiteStore())
    }
}

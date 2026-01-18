//
//  PreviewView.swift
//  WebMakr
//
//  MVP: Live preview with responsive toggle
//  Compatible with macOS 11.0 (Big Sur) and later
//

import SwiftUI
import WebKit
import Combine

struct PreviewView: View {
    @ObservedObject var store: SiteStore
    @State private var isLoading: Bool = true
    @State private var previewURL: URL?
    @State private var isDesktop: Bool = true  // Simple bool toggle
    @State private var refreshID = UUID()      // Force refresh
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text("Preview")
                    .font(.headline)
                
                Spacer()
                
                // Simple Desktop/Mobile Toggle
                HStack(spacing: 0) {
                    Button(action: { isDesktop = true; regeneratePreview() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "desktopcomputer")
                            Text("Desktop")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isDesktop ? Color.accentColor : Color.clear)
                        .foregroundColor(isDesktop ? .white : .primary)
                        .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { isDesktop = false; regeneratePreview() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "iphone")
                            Text("Mobile")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(!isDesktop ? Color.accentColor : Color.clear)
                        .foregroundColor(!isDesktop ? .white : .primary)
                        .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                Button(action: regeneratePreview) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .padding(.leading, 16)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Preview Container
            GeometryReader { geometry in
                ZStack {
                    Color(NSColor.textBackgroundColor)
                    
                    if isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Generating preview...")
                                .foregroundColor(.secondary)
                        }
                    } else if let url = previewURL {
                        ScrollView([.horizontal, .vertical], showsIndicators: true) {
                            VStack {
                                // Browser chrome bar
                                HStack(spacing: 8) {
                                    Circle().fill(Color.red.opacity(0.8)).frame(width: 12, height: 12)
                                    Circle().fill(Color.yellow.opacity(0.8)).frame(width: 12, height: 12)
                                    Circle().fill(Color.green.opacity(0.8)).frame(width: 12, height: 12)
                                    Spacer()
                                    Text(store.site.domain.isEmpty ? "preview" : store.site.domain)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(isDesktop ? "1200px" : "375px")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                                .background(Color(white: 0.15))
                                
                                // WebView
                                WebViewContainer(url: url, refreshID: refreshID)
                                    .frame(
                                        width: isDesktop ? 1200 : 375,
                                        height: isDesktop ? max(600, geometry.size.height - 100) : 667
                                    )
                            }
                            .background(Color(white: 0.1))
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.3), radius: 10)
                            .padding(20)
                            .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            Text("Failed to generate preview")
                                .foregroundColor(.secondary)
                            Button("Try Again", action: regeneratePreview)
                        }
                    }
                }
            }
        }
        .onAppear {
            generatePreview()
        }
    }
    
    private func regeneratePreview() {
        refreshID = UUID()  // Force WebView to reload
        generatePreview()
    }
    
    private func generatePreview() {
        isLoading = true
        previewURL = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let generator = SiteGeneratorSync(site: store.site)
                let outputURL = try generator.generate()
                let indexURL = outputURL.appendingPathComponent("index.html")
                
                DispatchQueue.main.async {
                    previewURL = indexURL
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    print("Preview error: \(error)")
                }
            }
        }
    }
}

// MARK: - WebView Wrapper

struct WebViewContainer: NSViewRepresentable {
    let url: URL
    let refreshID: UUID  // Changes trigger reload
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        // Handle link clicks - open external links in default browser
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            // If it's a file:// URL (local preview), allow it
            if url.scheme == "file" {
                decisionHandler(.allow)
                return
            }
            
            // If it's an external link (http/https), open in default browser
            if url.scheme == "http" || url.scheme == "https" {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)  // Don't navigate in WebView
                return
            }
            
            // Allow other navigations
            decisionHandler(.allow)
        }
    }
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView(store: SiteStore())
    }
}

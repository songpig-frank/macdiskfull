//
//  PolishedResultComparisonView.swift
//  MacDiskFull_Aff
//

import SwiftUI
import WebKit

struct PolishedResultComparisonView: View {
    let originalTitle: String
    let originalSlug: String
    let originalSummary: String
    let originalHTML: String // Fallback current content
    let history: [ArticleVersion] // Historical versions
    let result: PolishedResult
    let onApply: () -> Void
    let onCancel: () -> Void
    
    @State private var viewMode: Int = 1 // 1=Visual Split, 3=Polished Only
    @State private var selectedVersionID: UUID? // For selecting historical version
    
    // Compute the HTML to display on the left side
    var selectedOriginalHTML: String {
        // If user selected a specific version, use it
        if let id = selectedVersionID, let ver = history.first(where: { $0.id == id }) {
            return ver.contentHTML
        }
        // If history exists but nothing selected, default to the FIRST one (True Original)
        // This solves the user's request to see the "First original" by default
        if let first = history.first {
            return first.contentHTML
        }
        // Fallback
        return originalHTML
    }
    
    var body: some View {
        GeometryReader { fullScreen in
            HStack(spacing: 0) {
                // MARK: - LEFT SIDE: VISUAL CONTENT (75%)
                VStack(spacing: 0) {
                    // Header Bar
                    HStack {
                        Text("✨ Transformation Review")
                            .font(.system(size: 24, weight: .bold))
                        
                        Spacer()
                        
                        Picker("", selection: $viewMode) {
                            Text("Visual Split").tag(1)
                            Text("Polished Only").tag(3)
                            Text("Code Diff").tag(0)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 300)
                    }
                    .padding()
                    .background(Color(NSColor.windowBackgroundColor))
                    .overlay(Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.1)), alignment: .bottom)
                    
                    // Main Content Area
                    if viewMode == 1 {
                        // Synced Scrolling Split View
                        VStack(spacing: 0) {
                            // Column Headers
                            HStack(spacing: 0) {
                                // Original Header with Picker
                                HStack {
                                    Spacer()
                                    if !history.isEmpty {
                                        Picker("Version", selection: bindingForSelection) {
                                            ForEach(history) { ver in
                                                Text(ver.label).tag(Optional(ver.id))
                                            }
                                            // Option for the state right before this polish?
                                            // The 'originalHTML' passed in IS the state right before polish.
                                            // We can label it "Current State" if it's not in history.
                                            // But usually we append it to history before showing.
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .frame(width: 150)
                                    } else {
                                        Text("ORIGINAL")
                                            .font(.headline)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                
                                // Divider
                                Rectangle().frame(width: 1).foregroundColor(Color.gray.opacity(0.2))
                                
                                // Optimized Header
                                Text("OPTIMIZED")
                                    .font(.headline)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green.opacity(0.1))
                                    .foregroundColor(.green)
                            }
                            
                            // Unified WebView for Perfect Sync Scrolling
                            WebView(html: generateSplitPreview(left: selectedOriginalHTML, right: result.html))
                        }
                    } else if viewMode == 3 {
                        // Polished Only
                        WebView(html: generateSinglePreview(html: result.html))
                    } else {
                        // Code Diff
                        SyncedDiffView(originalContent: selectedOriginalHTML, polishedContent: result.html)
                    }
                }
                .frame(width: fullScreen.size.width * 0.75)
                .background(Color.white)
                
                // MARK: - RIGHT SIDE: ANALYSIS & CONTROLS (25%)
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // 1. SCORES
                            HStack(alignment: .center, spacing: 16) {
                                VStack {
                                    // Try to find score of selected version
                                    let score = history.first(where: { $0.id == selectedVersionID })?.score ?? 0
                                    Text("\(score)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.red)
                                    Text("Before")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Image(systemName: "arrow.right")
                                    .font(.title)
                                    .foregroundColor(.gray)
                                
                                VStack {
                                    Text("\(result.seo_score)")
                                        .font(.system(size: 48, weight: .heavy))
                                        .foregroundColor(.green)
                                    Text("After")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                            
                            // 2. BREAKDOWN
                            if let breakdown = result.score_breakdown {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Scorecard").font(.headline)
                                    ForEach(breakdown, id: \.criterion) { item in
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(item.criterion).font(.subheadline).bold()
                                                Spacer()
                                                Text("\(item.score)/\(item.max_score)").font(.system(.subheadline, design: .monospaced))
                                            }
                                            ProgressView(value: Double(item.score), total: Double(item.max_score))
                                                .accentColor(item.score > Int(Double(item.max_score)*0.8) ? .green : .orange)
                                            Text(item.reasoning).font(.caption).foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // 3. METADATA UPDATES
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Metadata Updates").font(.headline)
                                ChangeBlock(label: "Title", oldVal: originalTitle, newVal: result.title)
                                ChangeBlock(label: "Slug", oldVal: originalSlug, newVal: result.slug)
                                ChangeBlock(label: "Summary", oldVal: originalSummary, newVal: result.summary)
                            }
                            
                            Divider()
                            
                            // 4. ANALYSIS TEXT
                            VStack(alignment: .leading, spacing: 8) {
                                Text("AI Analysis").font(.headline)
                                Text(result.analysis)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Spacer(minLength: 40)
                        }
                        .padding()
                    }
                    
                    // Footer Actions
                    VStack(spacing: 12) {
                        Button(action: onApply) {
                            Text("Apply Optimization")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(DefaultButtonStyle())
                        .controlSize(.large)
                        
                        Button("Cancel", action: onCancel)
                            .keyboardShortcut(.cancelAction)
                    }
                    .padding()
                    .background(Color(NSColor.windowBackgroundColor))
                    .overlay(Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.1)), alignment: .top)
                }
                .frame(width: fullScreen.size.width * 0.25)
                .background(Color(NSColor.controlBackgroundColor))
                .overlay(Rectangle().frame(width: 1).foregroundColor(Color.gray.opacity(0.2)), alignment: .leading)
            }
        }
        .onAppear {
            // Select the oldest version by default (True Original)
            if let first = history.first {
                selectedVersionID = first.id
            }
        }
    }
    
    // Binding helper for the Picker to handle Optional
    var bindingForSelection: Binding<UUID?> {
        Binding {
            selectedVersionID
        } set: { newVal in
            selectedVersionID = newVal
        }
    }
    
    // HTML Generation
    func generateSplitPreview(left: String, right: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
        <style>
            body { 
                font-family: -apple-system, system-ui, sans-serif; 
                margin: 0; padding: 0;
                color: #333;
                background: white; 
            }
            .container {
                display: flex;
                min-height: 100vh;
            }
            .pane {
                flex: 1;
                padding: 20px;
                box-sizing: border-box;
                border-right: 1px solid #eee;
            }
            .pane:last-child { border-right: none; }
            img { max-width: 100%; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
            h1 { font-size: 2em; margin-bottom: 0.5em; line-height: 1.2; }
            h2 { font-size: 1.5em; margin-top: 1.5em; }
            p { margin-bottom: 1em; line-height: 1.6; }
        </style>
        </head>
        <body>
            <div class="container">
                <div class="pane">\(left)</div>
                <div class="pane">\(right)</div>
            </div>
        </body>
        </html>
        """
    }
    
    func generateSinglePreview(html: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
        <style>
            body { 
                font-family: -apple-system, system-ui, sans-serif; 
                padding: 40px; 
                max-width: 800px;
                margin: 0 auto;
                line-height: 1.6; 
                color: #333;
            }
            img { max-width: 100%; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        </style>
        </head>
        <body>
            \(html)
        </body>
        </html>
        """
    }
}

// Helpers
struct ChangeBlock: View {
    let label: String
    let oldVal: String
    let newVal: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption.bold()).foregroundColor(.secondary)
            if oldVal != newVal {
                Text(oldVal).strikethrough().font(.caption).foregroundColor(.red)
            }
            Text(newVal).font(.subheadline).bold().foregroundColor(.blue)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.1)))
    }
}

struct SyncedDiffView: View {
    let originalContent: String
    let polishedContent: String
    @State private var showDiffHighlights = true
    
    var body: some View {
        VStack(spacing: 0) {
            Toggle("Highlight Changes", isOn: $showDiffHighlights).padding()
            GeometryReader { geo in
                HStack(spacing: 1) {
                    ScrollView { Text(originalContent).font(.system(.caption, design: .monospaced)).padding() }
                        .frame(width: geo.size.width/2)
                    ScrollView { Text(polishedContent).font(.system(.caption, design: .monospaced)).padding() }
                        .frame(width: geo.size.width/2)
                }
            }
        }
    }
}

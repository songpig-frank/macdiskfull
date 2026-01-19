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
    let originalHTML: String
    let result: PolishedResult
    let onApply: () -> Void
    let onCancel: () -> Void
    
    @State private var viewMode: Int = 1 // Default to Visual Preview (1)
    
    var body: some View {
        GeometryReader { fullScreen in
            HStack(spacing: 0) {
                // MARK: - LEFT SIDE: VISUAL CONTENT (75%)
                VStack(spacing: 0) {
                    // Header Bar
                    HStack {
                        Text("✨ Transformation Review")
                            .font(.system(size: 24, weight: .bold)) // BIG Title
                        
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
                        // Visual Split (Before / After)
                        HStack(spacing: 0) {
                            // BEFORE
                            VStack(spacing: 0) {
                                Text("ORIGINAL")
                                    .font(.headline)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red.opacity(0.1))
                                    .foregroundColor(.red)
                                
                                WebView(html: generatePreview(html: originalHTML))
                            }
                            .overlay(Rectangle().frame(width: 1).foregroundColor(Color.gray.opacity(0.2)), alignment: .trailing)
                            
                            // AFTER
                            VStack(spacing: 0) {
                                Text("OPTIMIZED")
                                    .font(.headline)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green.opacity(0.1))
                                    .foregroundColor(.green)
                                
                                WebView(html: generatePreview(html: result.html))
                            }
                        }
                    } else if viewMode == 3 {
                        // Polished Only (MAXIMIZED)
                        WebView(html: generatePreview(html: result.html))
                    } else {
                        // Code Diff
                        SyncedDiffView(originalContent: originalHTML, polishedContent: result.html)
                    }
                }
                .frame(width: fullScreen.size.width * 0.75) // 75% Width
                .background(Color.white)
                
                // MARK: - RIGHT SIDE: ANALYSIS & CONTROLS (25%)
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // 1. SCORES (The "Marketing" Badge)
                            HStack(alignment: .center, spacing: 16) {
                                VStack {
                                    Text("\(result.original_score)")
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
                                        .font(.system(size: 48, weight: .heavy)) // HUGE Score
                                        .foregroundColor(.green)
                                    Text("After")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            
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
                            
                            // 3. METADATA CHANGES
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
                        .buttonStyle(DefaultButtonStyle()) // Fallback for stability
                        .controlSize(.large)
                        
                        Button("Cancel", action: onCancel)
                            .keyboardShortcut(.cancelAction)
                    }
                    .padding()
                    .background(Color(NSColor.windowBackgroundColor))
                    .overlay(Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.1)), alignment: .top)
                }
                .frame(width: fullScreen.size.width * 0.25) // 25% Width
                .background(Color(NSColor.controlBackgroundColor))
                .overlay(Rectangle().frame(width: 1).foregroundColor(Color.gray.opacity(0.2)), alignment: .leading)
            }
        }
    }
    
    // Helper for HTML Preview Styling
    func generatePreview(html: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
        <style>
            body { 
                font-family: -apple-system, system-ui, sans-serif; 
                padding: 20px; 
                line-height: 1.6; 
                color: #333;
                background: white; 
            }
            img { max-width: 100%; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
            h1 { font-size: 2em; margin-bottom: 0.5em; line-height: 1.2; }
            h2 { font-size: 1.5em; margin-top: 1.5em; }
            p { margin-bottom: 1em; }
        </style>
        </head>
        <body>
            \(html)
        </body>
        </html>
        """
    }
}

// Helper for Metadata Changes
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

// Reuse existing Diff components
struct SyncedDiffView: View {
    let originalContent: String
    let polishedContent: String
    
    @State private var showDiffHighlights = true
    
    var body: some View {
        VStack(spacing: 0) {
            Toggle("Highlight Changes", isOn: $showDiffHighlights)
                .padding()
            
            GeometryReader { geo in
                HStack(spacing: 1) {
                    ScrollView {
                         Text(originalContent)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                    }
                    .frame(width: geo.size.width/2)
                    
                    ScrollView {
                        Text(polishedContent)
                           .font(.system(.caption, design: .monospaced))
                           .padding()
                   }
                   .frame(width: geo.size.width/2)
                }
            }
        }
    }
}

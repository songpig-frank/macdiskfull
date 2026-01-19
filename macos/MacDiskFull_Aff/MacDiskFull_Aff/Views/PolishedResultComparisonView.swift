
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
    
    @State private var viewMode: Int = 0 // 0: Code, 1: Preview
    @State private var showFullScreen: Bool = false
    @State private var showScoreDetails: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var isPresentationMode: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isPresentationMode ? "✨ Transformation Review" : "AI Polish Review")
                    .font(isPresentationMode ? .title : .headline)
                
                Spacer()
                
                Picker("", selection: $viewMode) {
                    Text("Code Diff").tag(0)
                    Text("Enhanced Diff").tag(2)
                    Text("Visual Preview").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 280)
                
                Spacer()
                
                if !isPresentationMode {
                    Button(action: { showFullScreen = true }) {
                        Label("Presentation", systemImage: "macwindow.on.rectangle")
                    }
                    .padding(.trailing, 8)
                    
                    Button("Cancel", action: onCancel)
                        .keyboardShortcut(.cancelAction)
                } else {
                     Button("Exit Presentation", action: { presentationMode.wrappedValue.dismiss() })
                        .keyboardShortcut(.cancelAction)
                }
                
                if #available(macOS 12.0, *) {
                    Button("Apply Changes", action: onApply)
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.defaultAction)
                } else { // Fallback
                    Button("Apply Changes", action: onApply)
                        .keyboardShortcut(.defaultAction)
                }
            }
            .padding()
            .background(Group {
                if #available(macOS 12.0, *) {
                    Rectangle().fill(.regularMaterial)
                } else {
                    Color.gray.opacity(0.1)
                }
            })
            
            // Metadata Review (Table Style)
            VStack(spacing: 12) {
                // Title
                ComparisonRow(label: "Title", oldVal: originalTitle, newVal: result.title, isBold: true)
                Divider()
                // Slug
                ComparisonRow(label: "Slug", oldVal: originalSlug, newVal: result.slug)
                Divider()
                // Summary
                ComparisonRow(label: "Summary", oldVal: originalSummary, newVal: result.summary)
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
            .padding(.horizontal)
            
            
            // Scores
            // Scores
            VStack {
                HStack(spacing: 40) {
                    ScoreBadge(title: "Original", score: result.original_score)
                    Image(systemName: "arrow.right").font(.title2).foregroundColor(.secondary)
                    VStack {
                        ScoreBadge(title: "Polished (After)", score: result.seo_score)
                        
                        // Score Breakdown Toggle
                        Button(action: { showScoreDetails.toggle() }) {
                            Label(showScoreDetails ? "Hide Details" : "Score Details", systemImage: "info.circle")
                                .font(.caption)
                        }
                        .buttonStyle(.link)
                        .padding(.top, 4)
                        
                        if result.html.contains("placehold.co") {
                            Text("Visuals Pending")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.orange)
                                .padding(.top, 2)
                                .help("Score assumes images will be generated")
                        }
                    }
                }
                
                if showScoreDetails, let breakdown = result.score_breakdown {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Why this score?").font(.caption.bold()).foregroundColor(.secondary)
                        
                        ForEach(breakdown, id: \.criterion) { item in
                            HStack(alignment: .center) {
                                Text(item.criterion)
                                    .font(.system(size: 13, weight: .medium))
                                    .frame(width: 140, alignment: .leading)
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .frame(width: 80, height: 6)
                                            .opacity(0.1)
                                            .foregroundColor(.gray)
                                            .cornerRadius(3)
                                        
                                        Rectangle()
                                            .frame(width: 80 * (CGFloat(item.score) / CGFloat(item.max_score)), height: 6)
                                            .foregroundColor(item.score > Int(Double(item.max_score) * 0.8) ? .green : (item.score > Int(Double(item.max_score) * 0.5) ? .orange : .red))
                                            .cornerRadius(3)
                                    }
                                }
                                .frame(width: 80, height: 6)
                                
                                Text("\(item.score)/\(item.max_score)")
                                    .font(.system(.caption, design: .monospaced))
                                    .frame(width: 35, alignment: .trailing)
                                
                                Text(item.reasoning)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                            Divider()
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    .padding(.top, 10)
                    .padding(.horizontal)
                    .transition(.opacity)
                }
            }
            .padding(.vertical)
            .padding()
            
            Divider()
            
            // Comparison
            if viewMode == 2 {
                // Enhanced side-by-side with synced scrolling
                SyncedDiffView(originalContent: originalHTML, polishedContent: result.html)
            } else {
                HSplitView {
                    VStack(alignment: .leading) {
                        Text("Original (Before)").font(.caption).bold().padding(.leading)
                        if viewMode == 0 {
                            TextEditor(text: .constant(originalHTML))
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            WebView(html: generatePreview(html: originalHTML))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .layoutPriority(1)
                    
                    VStack(alignment: .leading) {
                        Text("Polished (After)").font(.caption).bold().padding(.leading)
                        if viewMode == 0 {
                            TextEditor(text: .constant(result.html))
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            WebView(html: generatePreview(html: result.html))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .layoutPriority(1)
                }
            }
            
            Divider()
            
            // Stats Footer
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Optimization Analysis").font(.caption.bold())
                    Text(result.analysis).font(.caption)
                    
                    if let conflict = result.conflict_resolution {
                         Text("\nVerdict: \(conflict)").font(.caption).foregroundColor(.orange)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Ranking Keywords").font(.caption.bold())
                    Text(result.keywords.joined(separator: ", ")).font(.caption)
                }
                .frame(width: 200)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
        }
        .frame(minWidth: 1100, idealWidth: 1400, maxWidth: .infinity, minHeight: 800, idealHeight: 1000, maxHeight: .infinity)
        .sheet(isPresented: $showFullScreen) {
            PolishedResultComparisonView(
                originalTitle: originalTitle,
                originalSlug: originalSlug,
                originalSummary: originalSummary,
                originalHTML: originalHTML,
                result: result,
                onApply: {
                    showFullScreen = false
                    onApply()
                },
                onCancel: {
                    showFullScreen = false
                },
                isPresentationMode: true
            )
            .preferredColorScheme(.dark)
        }
    }
    
    // Fallback helper for macOS 11 compatibility if needed, 
    // or just use .sheet if fullScreenCover is unavailable (it's macOS 11+).
    // .fullScreenCover is macOS 11.0+.
    
    func generatePreview(html: String) -> String {
        return """
        <!DOCTYPE html>
        <html><head><style>body { font-family: -apple-system, sans-serif; padding: 20px; color: #333; line-height: 1.6; } img { max-width: 100%; border-radius: 8px; } h2 { margin-top: 20px; }</style></head><body>\(html)</body></html>
        """
    }
}

struct ScoreBadge: View {
    let title: String
    let score: Int
    
    var color: Color {
        score >= 80 ? .green : (score >= 50 ? .orange : .red)
    }
    
    var body: some View {
        VStack {
            Text(title).font(.caption).foregroundColor(.secondary)
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 4)
                    .frame(width: 50, height: 50)
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                Text("\(score)")
                    .font(.headline)
                    .foregroundColor(color)
            }
        }
    }
}

struct ComparisonRow: View {
    let label: String
    let oldVal: String
    let newVal: String
    var isBold: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(label)
                .font(.caption).bold().foregroundColor(.secondary)
                .frame(width: 60, alignment: .trailing)
            
            Text(oldVal.isEmpty ? "(None)" : oldVal)
                .font(isBold ? .system(size: 13, weight: .semibold) : .caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(3)
            
            Image(systemName: "arrow.right").font(.caption).foregroundColor(.blue)
            
            Text(newVal.isEmpty ? "(None)" : newVal)
                .font(isBold ? .headline : .caption)
                .foregroundColor(isBold ? .blue : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(3)
        }
    }
}

// MARK: - Synced Diff View (Enhanced)

struct SyncedDiffView: View {
    let originalContent: String
    let polishedContent: String
    
    @State private var scrollOffset: CGFloat = 0
    @State private var showDiffHighlights = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Toggle("Highlight Changes", isOn: $showDiffHighlights)
                    .toggleStyle(.switch)
                Spacer()
                Text("\(originalLines.count) lines → \(polishedLines.count) lines")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Side by side
            GeometryReader { geo in
                HStack(spacing: 1) {
                    // Left: Original
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.secondary)
                            Text("Original")
                                .font(.caption.bold())
                            Spacer()
                            Text("\(originalContent.count) chars")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(6)
                        .background(Color.red.opacity(0.1))
                        
                        ScrollView {
                            DiffTextContent(
                                lines: originalLines,
                                comparisonLines: polishedLines,
                                isOriginal: true,
                                showHighlights: showDiffHighlights
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color(NSColor.textBackgroundColor))
                    }
                    .frame(width: geo.size.width / 2 - 1)
                    
                    // Divider
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2)
                    
                    // Right: Polished
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.accentColor)
                            Text("Polished")
                                .font(.caption.bold())
                            Spacer()
                            Text("\(polishedContent.count) chars")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(6)
                        .background(Color.green.opacity(0.1))
                        
                        ScrollView {
                            DiffTextContent(
                                lines: polishedLines,
                                comparisonLines: originalLines,
                                isOriginal: false,
                                showHighlights: showDiffHighlights
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color(NSColor.textBackgroundColor))
                    }
                    .frame(width: geo.size.width / 2 - 1)
                }
            }
        }
    }
    
    private var originalLines: [String] {
        originalContent.components(separatedBy: .newlines)
    }
    
    private var polishedLines: [String] {
        polishedContent.components(separatedBy: .newlines)
    }
}

struct DiffTextContent: View {
    let lines: [String]
    let comparisonLines: [String]
    let isOriginal: Bool
    let showHighlights: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                HStack(spacing: 4) {
                    // Line number
                    Text("\(index + 1)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(width: 30, alignment: .trailing)
                    
                    // Content
                    Text(line.isEmpty ? " " : line)
                        .font(.system(size: 11, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 1)
                .padding(.horizontal, 4)
                .background(lineBackground(for: line))
            }
        }
        .padding(4)
    }
    
    private func lineBackground(for line: String) -> Color {
        guard showHighlights else { return .clear }
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return .clear }
        
        let inComparison = comparisonLines.contains { $0.trimmingCharacters(in: .whitespaces) == trimmed }
        
        if !inComparison {
            return isOriginal ? Color.red.opacity(0.15) : Color.green.opacity(0.15)
        }
        return .clear
    }
}

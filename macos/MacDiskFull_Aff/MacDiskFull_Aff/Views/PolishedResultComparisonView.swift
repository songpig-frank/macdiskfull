
//
//  PolishedResultComparisonView.swift
//  MacDiskFull_Aff
//

import SwiftUI
import WebKit

struct PolishedResultComparisonView: View {
    let original: String
    let result: PolishedResult
    let onApply: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("AI Polish Review")
                    .font(.headline)
                Spacer()
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Button("Apply Changes", action: onApply)
                    // .buttonStyle(.borderedProminent) - macOS 12+ only
                    .keyboardShortcut(.defaultAction)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Scores
            HStack(spacing: 40) {
                ScoreBadge(title: "Original", score: result.original_score)
                Image(systemName: "arrow.right").font(.title2).foregroundColor(.secondary)
                ScoreBadge(title: "Polished", score: result.seo_score)
            }
            .padding()
            
            Divider()
            
            // Comparison
            HSplitView {
                VStack(alignment: .leading) {
                    Text("Original").font(.caption).bold().padding(.leading)
                    TextEditor(text: .constant(original))
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .layoutPriority(1)
                
                VStack(alignment: .leading) {
                    Text("Polished").font(.caption).bold().padding(.leading)
                    WebView(html: generatePreview(html: result.html))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .layoutPriority(1)
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
        .frame(minWidth: 900, minHeight: 700)
    }
    
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

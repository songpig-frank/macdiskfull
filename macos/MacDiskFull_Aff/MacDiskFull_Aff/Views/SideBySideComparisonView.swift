//
//  SideBySideComparisonView.swift
//  WebMakr
//
//  Enhanced comparison view with synchronized scrolling and diff highlighting
//

import SwiftUI
import AppKit

struct SideBySideComparisonView: View {
    let originalContent: String
    let polishedContent: String
    let siteName: String
    var onAccept: () -> Void
    var onReject: () -> Void
    var onAcceptPartial: ((String) -> Void)?  // For accepting edited version
    
    @State private var editedContent: String
    @State private var showDiff = true
    @State private var scrollPosition: CGFloat = 0
    @State private var isEditing = false
    @State private var leftScrollView: NSScrollView?
    @State private var rightScrollView: NSScrollView?
    
    // Statistics
    @State private var stats: DiffStats = DiffStats()
    
    init(originalContent: String, polishedContent: String, siteName: String,
         onAccept: @escaping () -> Void, onReject: @escaping () -> Void,
         onAcceptPartial: ((String) -> Void)? = nil) {
        self.originalContent = originalContent
        self.polishedContent = polishedContent
        self.siteName = siteName
        self.onAccept = onAccept
        self.onReject = onReject
        self.onAcceptPartial = onAcceptPartial
        self._editedContent = State(initialValue: polishedContent)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            Divider()
            
            // Stats Bar
            statsBar
            
            Divider()
            
            // Main Content
            HSplitView {
                // Original (Left)
                VStack(spacing: 0) {
                    panelHeader(title: "Original", icon: "doc.text", color: .secondary)
                    SyncedScrollTextView(
                        content: originalContent,
                        comparisonContent: showDiff ? polishedContent : nil,
                        isOriginal: true,
                        scrollPosition: $scrollPosition,
                        scrollViewRef: $leftScrollView
                    )
                }
                
                // Polished (Right)
                VStack(spacing: 0) {
                    panelHeader(title: isEditing ? "Editing" : "Polished", icon: isEditing ? "pencil" : "sparkles", color: .accentColor)
                    
                    if isEditing {
                        TextEditor(text: $editedContent)
                            .font(.system(.body, design: .monospaced))
                            .background(Color(NSColor.textBackgroundColor))
                    } else {
                        SyncedScrollTextView(
                            content: polishedContent,
                            comparisonContent: showDiff ? originalContent : nil,
                            isOriginal: false,
                            scrollPosition: $scrollPosition,
                            scrollViewRef: $rightScrollView
                        )
                    }
                }
            }
            
            Divider()
            
            // Footer Actions
            footer
        }
        .frame(minWidth: 900, minHeight: 600)
        .onAppear {
            calculateStats()
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Image(systemName: "arrow.left.arrow.right")
                .font(.title2)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Compare Changes")
                    .font(.title2.bold())
                Text(siteName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("Show Differences", isOn: $showDiff)
                .toggleStyle(.switch)
            
            Divider()
                .frame(height: 20)
            
            Toggle("Edit Mode", isOn: $isEditing)
                .toggleStyle(.switch)
                .disabled(onAcceptPartial == nil)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Stats Bar
    
    private var statsBar: some View {
        HStack(spacing: 24) {
            StatBadge(label: "Characters", value: "\(stats.originalChars) → \(stats.polishedChars)", icon: "character.cursor.ibeam")
            StatBadge(label: "Words", value: "\(stats.originalWords) → \(stats.polishedWords)", icon: "text.word.spacing")
            
            if stats.addedLines > 0 {
                StatBadge(label: "Added", value: "+\(stats.addedLines)", icon: "plus.circle.fill", color: .green)
            }
            if stats.removedLines > 0 {
                StatBadge(label: "Removed", value: "-\(stats.removedLines)", icon: "minus.circle.fill", color: .red)
            }
            if stats.changedLines > 0 {
                StatBadge(label: "Modified", value: "\(stats.changedLines)", icon: "arrow.triangle.2.circlepath", color: .orange)
            }
            
            Spacer()
            
            let changePercent = stats.originalChars > 0 ? Int((Float(abs(stats.polishedChars - stats.originalChars)) / Float(stats.originalChars)) * 100) : 0
            Text("\(changePercent)% change")
                .font(.caption.bold())
                .foregroundColor(changePercent > 20 ? .orange : .secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Panel Header
    
    private func panelHeader(title: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.headline)
            Spacer()
            
            Button(action: { copyToClipboard(title == "Original" ? originalContent : (isEditing ? editedContent : polishedContent)) }) {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.plain)
            .help("Copy to clipboard")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
    }
    
    // MARK: - Footer
    
    private var footer: some View {
        HStack {
            Button(action: onReject) {
                Label("Discard Changes", systemImage: "xmark.circle")
            }
            .keyboardShortcut(.cancelAction)
            
            Spacer()
            
            if isEditing && onAcceptPartial != nil {
                Button(action: { onAcceptPartial?(editedContent) }) {
                    Label("Accept Edited", systemImage: "checkmark.circle")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
            
            if #available(macOS 12.0, *) {
                Button(action: onAccept) {
                    Label("Accept Polished", systemImage: "sparkles")
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            } else {
                Button(action: onAccept) {
                    Label("Accept Polished", systemImage: "sparkles")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(6)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Helpers
    
    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
    
    private func calculateStats() {
        let originalLines = originalContent.components(separatedBy: .newlines)
        let polishedLines = polishedContent.components(separatedBy: .newlines)
        
        stats.originalChars = originalContent.count
        stats.polishedChars = polishedContent.count
        stats.originalWords = originalContent.split(separator: " ").count
        stats.polishedWords = polishedContent.split(separator: " ").count
        
        // Simple diff calculation
        let originalSet = Set(originalLines)
        let polishedSet = Set(polishedLines)
        
        stats.addedLines = polishedSet.subtracting(originalSet).count
        stats.removedLines = originalSet.subtracting(polishedSet).count
        stats.changedLines = min(stats.addedLines, stats.removedLines)
    }
}

// MARK: - Stats

struct DiffStats {
    var originalChars: Int = 0
    var polishedChars: Int = 0
    var originalWords: Int = 0
    var polishedWords: Int = 0
    var addedLines: Int = 0
    var removedLines: Int = 0
    var changedLines: Int = 0
}

struct StatBadge: View {
    let label: String
    let value: String
    let icon: String
    var color: Color = .secondary
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption.bold())
                .foregroundColor(color == .secondary ? .primary : color)
        }
    }
}

// MARK: - Synced Scroll Text View

struct SyncedScrollTextView: NSViewRepresentable {
    let content: String
    let comparisonContent: String?
    let isOriginal: Bool
    @Binding var scrollPosition: CGFloat
    @Binding var scrollViewRef: NSScrollView?
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        
        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        
        scrollView.documentView = textView
        
        // Set up sync observer
        context.coordinator.scrollView = scrollView
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.scrollViewDidScroll(_:)),
            name: NSView.boundsDidChangeNotification,
            object: scrollView.contentView
        )
        
        scrollView.contentView.postsBoundsChangedNotifications = true
        
        DispatchQueue.main.async {
            self.scrollViewRef = scrollView
        }
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        // Apply attributed content with diff highlighting
        let attributed = attributedContent(for: content, comparing: comparisonContent, isOriginal: isOriginal)
        textView.textStorage?.setAttributedString(attributed)
        
        // Sync scroll position
        if !context.coordinator.isScrolling {
            let maxScroll = max(0, (scrollView.documentView?.frame.height ?? 0) - scrollView.contentSize.height)
            let targetY = scrollPosition * maxScroll
            scrollView.contentView.setBoundsOrigin(NSPoint(x: 0, y: targetY))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scrollPosition: $scrollPosition)
    }
    
    class Coordinator: NSObject {
        var scrollView: NSScrollView?
        var scrollPosition: Binding<CGFloat>
        var isScrolling = false
        
        init(scrollPosition: Binding<CGFloat>) {
            self.scrollPosition = scrollPosition
        }
        
        @objc func scrollViewDidScroll(_ notification: Notification) {
            guard let scrollView = scrollView,
                  let contentView = notification.object as? NSClipView,
                  contentView === scrollView.contentView else { return }
            
            let maxScroll = max(1, (scrollView.documentView?.frame.height ?? 0) - scrollView.contentSize.height)
            let currentY = contentView.bounds.origin.y
            let newPosition = min(1, max(0, currentY / maxScroll))
            
            isScrolling = true
            DispatchQueue.main.async {
                self.scrollPosition.wrappedValue = newPosition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isScrolling = false
                }
            }
        }
    }
    
    // MARK: - Diff Highlighting
    
    private func attributedContent(for content: String, comparing comparison: String?, isOriginal: Bool) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        let defaultAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .foregroundColor: NSColor.textColor
        ]
        
        guard let comparison = comparison else {
            return NSAttributedString(string: content, attributes: defaultAttrs)
        }
        
        let contentLines = content.components(separatedBy: .newlines)
        let comparisonLines = comparison.components(separatedBy: .newlines)
        let comparisonSet = Set(comparisonLines)
        
        for (index, line) in contentLines.enumerated() {
            var attrs = defaultAttrs
            
            if !comparisonSet.contains(line) && !line.trimmingCharacters(in: .whitespaces).isEmpty {
                // This line is unique to this side
                if isOriginal {
                    // Removed in polished - highlight red
                    attrs[.backgroundColor] = NSColor.systemRed.withAlphaComponent(0.15)
                } else {
                    // Added in polished - highlight green
                    attrs[.backgroundColor] = NSColor.systemGreen.withAlphaComponent(0.15)
                }
            }
            
            result.append(NSAttributedString(string: line, attributes: attrs))
            if index < contentLines.count - 1 {
                result.append(NSAttributedString(string: "\n", attributes: defaultAttrs))
            }
        }
        
        return result
    }
}

// MARK: - Preview

#Preview {
    SideBySideComparisonView(
        originalContent: """
        <h1>Original Title</h1>
        <p>This is the original content.</p>
        <p>It has some text that will be changed.</p>
        """,
        polishedContent: """
        <h1>Polished Title</h1>
        <p>This is the polished content with improvements.</p>
        <p>The text has been enhanced for better readability.</p>
        <p>A new paragraph was added.</p>
        """,
        siteName: "Test Site",
        onAccept: {},
        onReject: {}
    )
}

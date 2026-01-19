//
//  LegalPagesView.swift
//  WebMakr
//
//  Legal Pages management with version control and editing
//  Compatible with macOS 11.0+
//

import SwiftUI

struct LegalPagesView: View {
    @Binding var site: Site
    @State private var selectedPageId: UUID?
    @State private var showAddPageSheet = false
    @State private var showRevisionHistory = false
    @State private var selectedRevision: LegalPageRevision?
    @State private var saveRevisionNote = ""
    @State private var showSaveRevisionAlert = false
    
    var body: some View {
        HSplitView {
            // Sidebar - Page List
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Legal Pages")
                        .font(.headline)
                    Spacer()
                    Button(action: { showAddPageSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Add Legal Page")
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
                
                // Page List
                List(selection: $selectedPageId) {
                    ForEach(legalPagesByStatus) { section in
                        Section(header: Text(section.status.rawValue)) {
                            ForEach(section.pages) { page in
                                LegalPageRow(page: page)
                                    .tag(page.id)
                            }
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            }
            .frame(minWidth: 220, maxWidth: 280)
            
            // Detail View
            if let pageId = selectedPageId, let pageIndex = site.legalPages.firstIndex(where: { $0.id == pageId }) {
                LegalPageEditor(
                    page: $site.legalPages[pageIndex],
                    showRevisionHistory: $showRevisionHistory,
                    onSaveRevision: { showSaveRevisionAlert = true },
                    onDelete: { deletePage(at: pageIndex) }
                )
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Select a legal page to edit")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("or add a new one")
                        .foregroundColor(.secondary)
                    Button("Add Legal Page") {
                        showAddPageSheet = true
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showAddPageSheet) {
            AddLegalPageSheet(site: $site, selectedPageId: $selectedPageId, isPresented: $showAddPageSheet)
        }
        .sheet(isPresented: $showRevisionHistory) {
            if let pageId = selectedPageId, let pageIndex = site.legalPages.firstIndex(where: { $0.id == pageId }) {
                RevisionHistorySheet(
                    page: $site.legalPages[pageIndex],
                    isPresented: $showRevisionHistory
                )
            }
        }
        .alert(isPresented: $showSaveRevisionAlert) {
            Alert(
                title: Text("Save Revision"),
                message: Text("This will save the current content as a new version."),
                primaryButton: .default(Text("Save")) {
                    if let pageId = selectedPageId, let pageIndex = site.legalPages.firstIndex(where: { $0.id == pageId }) {
                        site.legalPages[pageIndex].saveRevision(note: saveRevisionNote)
                        saveRevisionNote = ""
                    }
                },
                secondaryButton: .cancel {
                    saveRevisionNote = ""
                }
            )
        }
    }
    
    // Group pages by status
    private var legalPagesByStatus: [LegalPageSection] {
        var sections: [LegalPageSection] = []
        
        let published = site.legalPages.filter { $0.status == .published }
        if !published.isEmpty {
            sections.append(LegalPageSection(status: .published, pages: published))
        }
        
        let drafts = site.legalPages.filter { $0.status == .draft }
        if !drafts.isEmpty {
            sections.append(LegalPageSection(status: .draft, pages: drafts))
        }
        
        let archived = site.legalPages.filter { $0.status == .archived }
        if !archived.isEmpty {
            sections.append(LegalPageSection(status: .archived, pages: archived))
        }
        
        return sections
    }
    
    private func deletePage(at index: Int) {
        let page = site.legalPages[index]
        if selectedPageId == page.id {
            selectedPageId = nil
        }
        site.legalPages.remove(at: index)
    }
}

// Helper struct for grouping pages
struct LegalPageSection: Identifiable {
    let id = UUID()
    let status: LegalPageStatus
    let pages: [LegalPage]
}

// MARK: - Page Row

struct LegalPageRow: View {
    let page: LegalPage
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: page.pageType.icon)
                .foregroundColor(statusColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(page.title)
                    .font(.system(.body, design: .default))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text("v\(page.version)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // Status badge
                    Text(page.status.rawValue.uppercased())
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(3)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle()) // Makes entire row clickable
    }
    
    private var statusColor: Color {
        switch page.status {
        case .published: return .green
        case .draft: return .orange
        case .archived: return .gray
        }
    }
}

// MARK: - Page Editor

struct LegalPageEditor: View {
    @Binding var page: LegalPage
    @Binding var showRevisionHistory: Bool
    var onSaveRevision: () -> Void
    var onDelete: () -> Void
    
    @State private var showDeleteConfirmation = false
    @State private var isPreviewMode = false
    @State private var previousStatus: LegalPageStatus?
    @State private var statusMessage: String?
    @State private var showStatusToast = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Toolbar
                HStack(alignment: .center, spacing: 16) {
                    Image(systemName: page.pageType.icon)
                        .font(.title2)
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        TextField("Page Title", text: $page.title)
                            .font(.title2.bold())
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        HStack(spacing: 12) {
                            Text("Version \(page.version)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Modified: \(page.modifiedAt, style: .date)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text("/\(page.pageType.slug).html")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    // Status Picker - Fixed alignment
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Status").font(.caption).foregroundColor(.secondary)
                        Picker("", selection: $page.status) {
                            ForEach(LegalPageStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 240)
                        .labelsHidden()
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
                
                // Action Bar
                HStack {
                    Toggle("Preview", isOn: $isPreviewMode)
                        .toggleStyle(SwitchToggleStyle())
                    
                    Spacer()
                    
                    Button(action: { showRevisionHistory = true }) {
                        Label("History (\(page.revisions.count))", systemImage: "clock.arrow.circlepath")
                    }
                    .help("View revision history")
                    
                    Button(action: onSaveRevision) {
                        Label("Save Version", systemImage: "doc.badge.plus")
                    }
                    .help("Save current content as a new version")
                    
                    Button(action: { page.contentHTML = page.pageType.defaultContent }) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                    .help("Reset to default template")
                    
                    Button(action: { showDeleteConfirmation = true }) {
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    .help("Delete this page")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                
                Divider()
                
                // Content Area
                if isPreviewMode {
                    LegalPagePreview(content: page.contentHTML, title: page.title)
                } else {
                    LegalPageHTMLEditor(content: $page.contentHTML)
                }
            }
            
            // Status Toast
            if showStatusToast, let message = statusMessage {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: statusIcon)
                            .foregroundColor(.white)
                        Text(message)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(statusToastColor)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: showStatusToast)
            }
        }
        .onAppear {
            previousStatus = page.status
        }
        .onChange(of: page.status) { newStatus in
            if let prev = previousStatus, prev != newStatus {
                // Auto-save revision when status changes
                page.saveRevision(note: "Status changed from \(prev.rawValue) to \(newStatus.rawValue)")
                
                // Show toast
                switch newStatus {
                case .published:
                    statusMessage = "✓ Page is now PUBLISHED"
                case .draft:
                    statusMessage = "Page moved to DRAFT"
                case .archived:
                    statusMessage = "Page has been ARCHIVED"
                }
                
                withAnimation {
                    showStatusToast = true
                }
                
                // Hide toast after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showStatusToast = false
                    }
                }
            }
            previousStatus = newStatus
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Page?"),
                message: Text("This will permanently delete \"\(page.title)\" and all its revisions."),
                primaryButton: .destructive(Text("Delete"), action: onDelete),
                secondaryButton: .cancel()
            )
        }
    }
    
    private var statusIcon: String {
        switch page.status {
        case .published: return "checkmark.circle.fill"
        case .draft: return "pencil.circle"
        case .archived: return "archivebox"
        }
    }
    
    private var statusToastColor: Color {
        switch page.status {
        case .published: return .green
        case .draft: return .orange
        case .archived: return .gray
        }
    }
}

// MARK: - HTML Editor

struct LegalPageHTMLEditor: View {
    @Binding var content: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Formatting toolbar
            HStack(spacing: 12) {
                ForEach(HTMLTag.commonTags, id: \.self) { tag in
                    Button(tag.label) {
                        insertTag(tag)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(4)
                }
                
                Spacer()
                
                Button(action: insertDatePlaceholder) {
                    Label("Insert Date", systemImage: "calendar")
                        .font(.caption)
                }
            }
            .padding(8)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Editor
            TextEditor(text: $content)
                .font(.system(.body, design: .monospaced))
                .background(Color(NSColor.textBackgroundColor))
        }
    }
    
    private func insertTag(_ tag: HTMLTag) {
        content += "\n\(tag.openTag)\(tag.placeholder)\(tag.closeTag)"
    }
    
    private func insertDatePlaceholder() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        content = content.replacingOccurrences(of: "[DATE]", with: formatter.string(from: Date()))
    }
}

struct HTMLTag: Hashable {
    let label: String
    let openTag: String
    let closeTag: String
    let placeholder: String
    
    static let commonTags: [HTMLTag] = [
        HTMLTag(label: "H2", openTag: "<h2>", closeTag: "</h2>", placeholder: "Heading"),
        HTMLTag(label: "H3", openTag: "<h3>", closeTag: "</h3>", placeholder: "Subheading"),
        HTMLTag(label: "P", openTag: "<p>", closeTag: "</p>", placeholder: "Paragraph text"),
        HTMLTag(label: "Bold", openTag: "<strong>", closeTag: "</strong>", placeholder: "bold text"),
        HTMLTag(label: "List", openTag: "<ul>\n  <li>", closeTag: "</li>\n</ul>", placeholder: "List item"),
        HTMLTag(label: "Link", openTag: "<a href=\"#\">", closeTag: "</a>", placeholder: "link text")
    ]
}

// MARK: - Preview

struct LegalPagePreview: View {
    let content: String
    let title: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Simulated page header
                VStack(spacing: 8) {
                    Text(title)
                        .font(.largeTitle.bold())
                    Divider()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(NSColor.controlBackgroundColor))
                
                // Content preview (simplified HTML rendering)
                Text(strippedContent)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(NSColor.textBackgroundColor))
    }
    
    // Simple HTML stripping for preview (uses plain String for macOS 11 compatibility)
    private var strippedContent: String {
        var text = content
        // Strip basic HTML tags for preview
        let patterns: [(String, String)] = [
            ("<h2>", "\n\n"),
            ("</h2>", "\n"),
            ("<h3>", "\n\n"),
            ("</h3>", "\n"),
            ("<p>", ""),
            ("</p>", "\n\n"),
            ("<strong>", ""),
            ("</strong>", ""),
            ("<em>", ""),
            ("</em>", ""),
            ("<ul>", "\n"),
            ("</ul>", "\n"),
            ("<li>", "• "),
            ("</li>", "\n"),
            ("</a>", ""),
            ("<br>", "\n")
        ]
        
        for (pattern, replacement) in patterns {
            text = text.replacingOccurrences(of: pattern, with: replacement)
        }
        
        // Remove remaining anchor tags with regex
        if let regex = try? NSRegularExpression(pattern: "<a[^>]*>", options: .caseInsensitive) {
            text = regex.stringByReplacingMatches(in: text, range: NSRange(text.startIndex..., in: text), withTemplate: "")
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Add Page Sheet

struct AddLegalPageSheet: View {
    @Binding var site: Site
    @Binding var selectedPageId: UUID?
    @Binding var isPresented: Bool
    
    @State private var selectedType: LegalPageType = .privacyPolicy
    
    var availableTypes: [LegalPageType] {
        // Filter out types that already exist
        let existingTypes = Set(site.legalPages.map { $0.pageType })
        return LegalPageType.allCases.filter { !existingTypes.contains($0) }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Legal Page")
                .font(.title2.bold())
            
            if availableTypes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    Text("All legal page types have been added!")
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select page type:")
                        .font(.headline)
                    
                    ForEach(availableTypes) { type in
                        Button(action: { selectedType = type }) {
                            HStack {
                                Image(systemName: type.icon)
                                    .frame(width: 24)
                                Text(type.rawValue)
                                Spacer()
                                if selectedType == type {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding()
                            .background(selectedType == type ? Color.accentColor.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(width: 350)
            }
            
            Divider()
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                if !availableTypes.isEmpty {
                    Button("Add Page") {
                        let newPage = LegalPage(pageType: selectedType)
                        site.legalPages.append(newPage)
                        selectedPageId = newPage.id
                        isPresented = false
                    }
                    .keyboardShortcut(.defaultAction)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding(24)
        .frame(width: 400)
        .onAppear {
            if let first = availableTypes.first {
                selectedType = first
            }
        }
    }
}

// MARK: - Revision History Sheet

struct RevisionHistorySheet: View {
    @Binding var page: LegalPage
    @Binding var isPresented: Bool
    
    @State private var selectedRevisionId: UUID?
    @State private var confirmRestore = false
    
    private var selectedRevision: LegalPageRevision? {
        page.revisions.first { $0.id == selectedRevisionId }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Revision History")
                    .font(.title2.bold())
                Spacer()
                Button("Done") { isPresented = false }
                    .keyboardShortcut(.defaultAction)
            }
            .padding()
            
            Divider()
            
            if page.revisions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No revisions yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Save a version to create a revision point.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HSplitView {
                    // Revision List
                    List(selection: $selectedRevisionId) {
                        ForEach(page.revisions.reversed()) { revision in
                            RevisionRow(revision: revision)
                                .tag(revision.id)
                        }
                    }
                    .frame(minWidth: 200, maxWidth: 280)
                    
                    // Preview
                    if let revision = selectedRevision {
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Version \(revision.version)")
                                        .font(.headline)
                                    Text(revision.createdAt, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if !revision.note.isEmpty {
                                        Text(revision.note)
                                            .font(.caption)
                                            .italic()
                                    }
                                }
                                
                                Spacer()
                                
                                Button("Restore This Version") {
                                    confirmRestore = true
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            
                            Divider()
                            
                            ScrollView {
                                Text(revision.contentHTML)
                                    .font(.system(.body, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
                        }
                    } else {
                        VStack {
                            Text("Select a revision to preview")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .frame(width: 800, height: 500)
        .alert(isPresented: $confirmRestore) {
            Alert(
                title: Text("Restore Version?"),
                message: Text("This will replace the current content with version \(selectedRevision?.version ?? 0). Your current content will be saved as a new revision first."),
                primaryButton: .default(Text("Restore")) {
                    if let revision = selectedRevision {
                        page.restoreRevision(revision)
                        isPresented = false
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct RevisionRow: View {
    let revision: LegalPageRevision
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Version \(revision.version)")
                    .font(.headline)
                Spacer()
            }
            Text(revision.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            if !revision.note.isEmpty {
                Text(revision.note)
                    .font(.caption)
                    .italic()
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#if DEBUG
struct LegalPagesView_Previews: PreviewProvider {
    static var previews: some View {
        LegalPagesView(site: .constant(Site.sampleMacDiskFull))
    }
}
#endif

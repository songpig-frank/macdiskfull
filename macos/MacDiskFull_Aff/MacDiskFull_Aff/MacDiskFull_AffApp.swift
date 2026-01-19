//
//  WebMakrApp.swift
//  WebMakr
//
//  Native Website Builder for macOS
//  Build comparison sites without code
//  Compatible with macOS 11.0 (Big Sur) and later
//

import SwiftUI
import AppKit

@main
struct WebMakrApp: App {
    @StateObject private var store = SiteStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    DispatchQueue.main.async {
                        if let window = NSApplication.shared.windows.first {
                            window.setFrame(NSScreen.main?.visibleFrame ?? .zero, display: true)
                            window.makeKeyAndOrderFront(nil)
                        }
                    }
                }
        }
        .commands {
            // File Menu
            CommandGroup(replacing: .newItem) {
                Button("New Project") {
                    store.showTemplatePicker = true
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Divider()
                
                Button("Open Project…") {
                    openProject()
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Import Site…") {
                    importSite()
                }
                .keyboardShortcut("i", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Save as Template…") {
                    store.showSaveTemplateView = true
                }
                
                Button("Save Project As…") {
                    saveProjectAs()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
                
                Button("Export Site…") {
                    exportSite()
                }
                .keyboardShortcut("e", modifiers: .command)
            }
            
            // Help menu
            CommandGroup(replacing: .help) {
                Link("WebMakr Documentation", destination: URL(string: "https://webmakr.app/docs")!)
                Divider()
                Link("Report an Issue", destination: URL(string: "https://webmakr.app/support")!)
            }
        }
    }
    
    // MARK: - File Menu Actions
    
    private func openProject() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["json"]
        panel.allowsMultipleSelection = false
        panel.message = "Select a WebMakr project file"
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            do {
                try store.importProject(from: url)
            } catch {
                showError("Failed to open project: \(error.localizedDescription)")
            }
        }
    }
    
    private func importSite() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["json"]
        panel.allowsMultipleSelection = false
        panel.message = "Select a site JSON file to import"
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            do {
                let report = try store.importSite(from: url)
                showImportReport(report)
            } catch {
                showError("Failed to import site: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveProjectAs() {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["json"]
        panel.nameFieldStringValue = "\(store.currentProject.displayName).json"
        panel.message = "Save project as…"
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            do {
                try store.exportProject(to: url)
            } catch {
                showError("Failed to save project: \(error.localizedDescription)")
            }
        }
    }
    
    private func exportSite() {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["json"]
        panel.nameFieldStringValue = "\(store.site.name.replacingOccurrences(of: " ", with: "_"))_site.json"
        panel.message = "Export site configuration…"
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            do {
                try store.exportSite(to: url)
            } catch {
                showError("Failed to export site: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Dialogs
    
    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showImportReport(_ report: ImportReport) {
        let alert = NSAlert()
        alert.messageText = "Import Complete"
        alert.informativeText = report.summary
        
        if !report.warnings.isEmpty {
            alert.informativeText += "\n\nWarnings:\n" + report.warnings.joined(separator: "\n")
        }
        
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

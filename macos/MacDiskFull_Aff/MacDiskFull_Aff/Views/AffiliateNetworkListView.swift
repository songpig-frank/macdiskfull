//
//  AffiliateNetworkListView.swift
//  WebMakr
//
//  Rich catalog of affiliate networks with sync
//  Compatible with macOS 11.0 (Big Sur) and later
//

import SwiftUI

struct AffiliateNetworkListView: View {
    @ObservedObject var database = AffiliateDatabase.shared
    @Binding var enabledNetworks: [String: String] // Maps Program Name -> Affiliate ID
    
    @State private var selectedCategory: ProgramCategory? = .software
    @State private var searchText = ""
    @State private var lastUpdateResult: String?
    
    var body: some View {
        HSplitView {
            // Sidebar: Categories
            VStack(spacing: 0) {
                Text("Categories")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                
                List(selection: $selectedCategory) {
                    ForEach(ProgramCategory.allCases, id: \.self) { category in
                        NavigationLink(destination: EmptyView()) { // Hack for selection style
                            Label(category.rawValue, systemImage: icon(for: category))
                        }
                        .tag(category)
                    }
                }
                .listStyle(SidebarListStyle())
            }
            .frame(minWidth: 200, maxWidth: 250)
            
            // Content: Programs
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "globe")
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text(selectedCategory?.rawValue ?? "All Networks")
                            .font(.headline)
                        Text("\(filteredPrograms.count) available programs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let result = lastUpdateResult {
                        Text(result)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: checkForUpdates) {
                        Label(database.isSyncing ? "Updating..." : "Check for Updates", 
                              systemImage: "arrow.triangle.2.circlepath")
                    }
                    .disabled(database.isSyncing)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
                
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search programs...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                
                Divider()
                
                // List
                List {
                    ForEach(filteredPrograms) { program in
                        NetworkRowView(program: program, affiliateId: Binding(
                            get: { enabledNetworks[program.name] ?? "" },
                            set: { newValue in
                                if newValue.isEmpty {
                                    enabledNetworks.removeValue(forKey: program.name)
                                } else {
                                    enabledNetworks[program.name] = newValue
                                }
                            }
                        ))
                    }
                }
            }
        }
        .frame(minWidth: 700, minHeight: 400)
    }
    
    var filteredPrograms: [AffiliateProgram] {
        var programs = database.programs
        
        if let category = selectedCategory {
            programs = programs.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            programs = programs.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return programs.sorted { $0.name < $1.name }
    }
    
    func checkForUpdates() {
        lastUpdateResult = "Checking..."
        database.checkForUpdates { result in
            switch result {
            case .success(let count):
                lastUpdateResult = count > 0 ? "Added \(count) new programs!" : "Database is up to date."
            case .failure(let error):
                lastUpdateResult = "Update failed: \(error.localizedDescription)"
            }
        }
    }
    
    func icon(for category: ProgramCategory) -> String {
        switch category {
        case .retail: return "cart"
        case .software: return "desktopcomputer"
        case .finance: return "banknote"
        case .insurance: return "shield"
        case .hosting: return "server.rack"
        case .other: return "square.grid.2x2"
        }
    }
}

struct NetworkRowView: View {
    let program: AffiliateProgram
    @Binding var affiliateId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(program.name)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        if let url = URL(string: program.website) {
                            Link("Website", destination: url)
                                .font(.caption)
                        }
                        Text("•")
                        Text(program.regions.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Badges
                    HStack(spacing: 6) {
                        if let diff = program.difficulty {
                            Text(diff.rawValue)
                                .font(.system(size: 10, weight: .semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(diffColor(diff).opacity(0.15))
                                .foregroundColor(diffColor(diff))
                                .cornerRadius(4)
                        }
                        
                        if let speed = program.approvalSpeed {
                            Text(speed.rawValue)
                                .font(.system(size: 10, weight: .medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
                
                Link("Sign Up", destination: URL(string: program.signupURL)!)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }
            
            // Insider Tips
            if let tips = program.tips {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(tips)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.yellow.opacity(0.05))
                .cornerRadius(4)
            }
            
            HStack {
                Text(program.idPlaceholder)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading)
                
                TextField("Enter your ID to enable", text: $affiliateId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding(.vertical, 6)
    }
    
    func diffColor(_ diff: ProgramDifficulty) -> Color {
        switch diff {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

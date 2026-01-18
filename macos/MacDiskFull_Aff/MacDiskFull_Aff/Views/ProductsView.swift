//
//  ProductsView.swift
//  WebMakr
//
//  MVP Product Editor - Add/Edit/Delete products with pros/cons
//  Compatible with macOS 11.0 (Big Sur) and later
//

import SwiftUI
import Combine

struct ProductsView: View {
    @ObservedObject var store: SiteStore
    
    var body: some View {
        HSplitView {
            // Left: Product List
            ProductListView(store: store)
                .frame(minWidth: 250, maxWidth: 350)
            
            // Right: Product Editor
            if let product = store.selectedProduct {
                ProductEditorView(
                    product: Binding(
                        get: { product },
                        set: { store.selectedProduct = $0 }
                    ),
                    settings: store.site.affiliateSettings,
                    onDelete: { store.deleteProduct(product) }
                )
            } else {
                EmptyProductView(onAdd: store.addProduct)
            }
        }
    }
}

// MARK: - Product List

struct ProductListView: View {
    @ObservedObject var store: SiteStore
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Products")
                    .font(.headline)
                Spacer()
                Text("\(store.site.products.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // List
            List(selection: $store.selectedProductId) {
                ForEach(store.sortedProducts) { product in
                    ProductRowView(product: product)
                        .tag(product.id)
                }
                .onMove(perform: store.moveProduct)
            }
            .listStyle(SidebarListStyle())
            
            Divider()
            
            // Add Button
            HStack {
                Button(action: store.addProduct) {
                    Label("Add Product", systemImage: "plus")
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct ProductRowView: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 12) {
            // Type indicator
            Circle()
                .fill(typeColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(product.name)
                        .font(product.isRecommended ? .body.weight(.bold) : .body)
                        .lineLimit(1)
                    
                    if product.isRecommended {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                HStack(spacing: 8) {
                    Text(product.starRating)
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text(product.price)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var typeColor: Color {
        switch product.productType {
        case .ownProduct: return .green
        case .amazonAffiliate: return .orange
        case .otherAffiliate: return .blue
        case .competitor: return .gray
        }
    }
}

// MARK: - Empty State

struct EmptyProductView: View {
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cube.box")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Product Selected")
                .font(.title2.weight(.semibold))
            
            Text("Select a product from the list or add a new one")
                .foregroundColor(.secondary)
            
            Button(action: onAdd) {
                Label("Add Product", systemImage: "plus")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Product Editor

struct ProductEditorView: View {
    @Binding var product: Product
    let settings: AffiliateSettings
    let onDelete: () -> Void
    @State private var showDeleteConfirm = false
    
    var allNetworkNames: [String] {
        let standard = AffiliateNetwork.allCases.map { $0.rawValue }
        let enabled = Array(settings.globalAffiliateIds.keys)
        return Array(Set(standard + enabled)).sorted()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Edit Product")
                            .font(.largeTitle.weight(.bold))
                        Text(product.name)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    Button(action: { showDeleteConfirm = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                // Basic Info
                GroupBox(label: Label("Basic Information", systemImage: "info.circle")) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Product Name")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Name", text: $product.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Short Description")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Description", text: $product.shortDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        HStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Price")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("$19.99", text: $product.price)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 120)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rating")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Slider(value: $product.rating, in: 1...5, step: 0.5)
                                        .frame(width: 120)
                                    Text(String(format: "%.1f", product.rating))
                                        .foregroundColor(.secondary)
                                    Text(product.starRating)
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        
                    }
                    .padding()
                }
                
                // Affiliate Link Builder
                GroupBox(label: Label("Affiliate Link", systemImage: "link")) {
                    VStack(alignment: .leading, spacing: 12) {
                        
                        // Network Picker
                        HStack {
                            Text("Network")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            
                            Picker("", selection: Binding(
                                get: { product.affiliateNetworkId ?? "Custom Link" },
                                set: { product.affiliateNetworkId = $0 }
                            )) {
                                ForEach(allNetworkNames, id: \.self) { name in
                                    Text(name).tag(name)
                                }
                            }
                            .labelsHidden()
                        }
                        
                        if let networkId = product.affiliateNetworkId,
                           let network = AffiliateNetwork(rawValue: networkId),
                           network != .custom {
                            
                            // Builder Fields
                            HStack {
                                Text("Product ID")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 80, alignment: .leading)
                                
                                TextField(AffiliateLinkBuilder.placeholder(for: network), text: Binding(
                                    get: { product.externalId ?? "" },
                                    set: { product.externalId = $0 }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            HStack {
                                Text("Campaign")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 80, alignment: .leading)
                                
                                TextField("Optional campaign slug", text: Binding(
                                    get: { product.campaignOverride ?? "" },
                                    set: { product.campaignOverride = $0 }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // Generate Button
                            HStack {
                                Spacer()
                                Button(action: {
                                    let link = AffiliateLinkBuilder.buildLink(
                                        network: network,
                                        productId: product.externalId ?? "",
                                        affiliateId: settings.globalAffiliateIds[network.rawValue] ?? "",
                                        campaign: product.campaignOverride ?? ""
                                    )
                                    product.affiliateLink = link
                                }) {
                                    Label("Generate Link", systemImage: "wand.and.stars")
                                }
                                .disabled((product.externalId ?? "").isEmpty)
                            }
                        }
                        
                        Divider()
                        
                        // Final Link
                        HStack {
                            Text("Final Link")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            
                            TextField("https://...", text: $product.affiliateLink)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                if let url = URL(string: product.affiliateLink) {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Image(systemName: "arrow.up.right.square")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                
                // Type & Badges
                GroupBox(label: Label("Type & Visibility", systemImage: "tag")) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Product Type")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("Type", selection: $product.productType) {
                                ForEach(ProductType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        Toggle("⭐ Mark as Recommended (Best Choice)", isOn: $product.isRecommended)
                            .toggleStyle(SwitchToggleStyle())
                    }
                    .padding()
                }
                
                // Pros
                GroupBox(label: Label("Pros", systemImage: "hand.thumbsup")) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(product.pros.indices, id: \.self) { index in
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                TextField("Pro", text: $product.pros[index])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button(action: { product.pros.remove(at: index) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        Button(action: { product.pros.append("") }) {
                            Label("Add Pro", systemImage: "plus")
                        }
                    }
                    .padding()
                }
                
                // Cons
                GroupBox(label: Label("Cons", systemImage: "hand.thumbsdown")) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(product.cons.indices, id: \.self) { index in
                            HStack {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                TextField("Con", text: $product.cons[index])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button(action: { product.cons.remove(at: index) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        Button(action: { product.cons.append("") }) {
                            Label("Add Con", systemImage: "plus")
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
        }
        .alert(isPresented: $showDeleteConfirm) {
            Alert(
                title: Text("Delete Product?"),
                message: Text("Are you sure you want to delete \"\(product.name)\"? This cannot be undone."),
                primaryButton: .destructive(Text("Delete"), action: onDelete),
                secondaryButton: .cancel()
            )
        }
    }
}

struct ProductsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsView(store: SiteStore())
    }
}

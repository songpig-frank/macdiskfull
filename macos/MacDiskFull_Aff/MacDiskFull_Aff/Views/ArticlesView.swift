
//
//  ArticlesView.swift
//  WebMakr
//
//  Manage Blog Articles (CMS)
//

import SwiftUI

struct ArticlesView: View {
    @Binding var site: Site
    @State private var editingArticleId: UUID?
    
    var body: some View {
        List {
            ForEach(site.articles) { article in
                Button(action: { editingArticleId = article.id }) {
                    VStack(alignment: .leading) {
                        Text(article.title)
                            .font(.headline)
                        Text(article.slug)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .onDelete(perform: delete)
        }
        .listStyle(InsetListStyle())
        .navigationTitle("Articles")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: addArticle) {
                    Label("Add Article", systemImage: "plus")
                }
            }
        }
        .sheet(item: Binding(
            get: { editingArticleId.map { WrappedUUID(uuid: $0) } },
            set: { editingArticleId = $0?.uuid }
        )) { wrappedId in
            if let index = site.articles.firstIndex(where: { $0.id == wrappedId.uuid }) {
                NavigationView {
                    ArticleEditorView(article: $site.articles[index])
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { editingArticleId = nil }
                            }
                        }
                }
                .frame(width: 800, height: 600)
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        site.articles.remove(atOffsets: offsets)
    }
    
    func addArticle() {
        let newArticle = Article(
            title: "New Post",
            slug: "new-post-\(Int(Date().timeIntervalSince1970))",
            summary: "Short summary...",
            contentHTML: "<p>Content</p>"
        )
        site.articles.append(newArticle)
        editingArticleId = newArticle.id // Auto-open
    }
}

// UUID wrapper for Sheet .item
struct WrappedUUID: Identifiable {
    let uuid: UUID
    var id: UUID { uuid }
}

struct ArticleEditorView: View {
    @Binding var article: Article
    
    var body: some View {
        VStack(spacing: 16) {
            GroupBox(label: Text("Metadata")) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Title:")
                            .frame(width: 60, alignment: .trailing)
                        TextField("Title", text: $article.title)
                    }
                    HStack {
                        Text("Slug:")
                            .frame(width: 60, alignment: .trailing)
                        TextField("Slug (URL)", text: $article.slug)
                    }
                    HStack {
                        Text("Author:")
                            .frame(width: 60, alignment: .trailing)
                        TextField("Author", text: $article.author)
                    }
                    HStack(alignment: .top) {
                         Text("Summary:")
                            .frame(width: 60, alignment: .trailing)
                        TextEditor(text: $article.summary)
                            .frame(height: 60)
                            .border(Color.gray.opacity(0.2))
                    }
                }
                .padding()
            }
            
            GroupBox(label: Text("Content (HTML)")) {
                TextEditor(text: $article.contentHTML)
                    .font(.system(.body, design: .monospaced))
                    .disableAutocorrection(true)
                    .padding(4)
            }
            
            Text("Tip: Use <h3> for headings, <p> for paragraphs.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("Edit Article")
    }
}

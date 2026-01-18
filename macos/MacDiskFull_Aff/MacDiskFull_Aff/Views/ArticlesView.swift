
//
//  ArticlesView.swift
//  WebMakr
//
//  Manage Blog Articles (CMS)
//

import SwiftUI

struct ArticlesView: View {
    @Binding var site: Site
    
    var body: some View {
        List {
            ForEach($site.articles) { $article in
                NavigationLink(destination: ArticleEditorView(article: $article)) {
                    VStack(alignment: .leading) {
                        Text(article.title)
                            .font(.headline)
                        Text(article.slug)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
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
    }
    
    func delete(at offsets: IndexSet) {
        site.articles.remove(atOffsets: offsets)
    }
    
    func addArticle() {
        let newArticle = Article(
            title: "New Post",
            slug: "new-post-\(Date().timeIntervalSince1970)",
            summary: "Short summary here...",
            contentHTML: "<p>Start writing your content...</p>"
        )
        site.articles.append(newArticle)
    }
}

struct ArticleEditorView: View {
    @Binding var article: Article
    
    var body: some View {
        Form {
            Section(header: Text("Metadata")) {
                TextField("Title", text: $article.title)
                TextField("Slug (URL)", text: $article.slug)
                TextField("Author", text: $article.author)
            }
            
            Section(header: Text("SEO Summary")) {
                TextEditor(text: $article.summary)
                    .frame(height: 80)
            }
            
            Section(header: Text("Content (HTML)")) {
                TextEditor(text: $article.contentHTML)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 400)
            }
            
            Section(header: Text("Preview")) {
                // Formatting tips
                Text("Use <h3> for headings, <p> for paragraphs.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .navigationTitle("Edit Article")
    }
}

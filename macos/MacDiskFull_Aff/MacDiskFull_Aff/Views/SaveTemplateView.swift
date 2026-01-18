//
//  SaveTemplateView.swift
//  WebMakr
//
//  Dialog to save current project as a template
//  Compatible with macOS 11.0 (Big Sur) and later
//

import SwiftUI

struct SaveTemplateView: View {
    @ObservedObject var store: SiteStore
    @Binding var isPresented: Bool
    
    @State private var templateName: String = ""
    @State private var templateDescription: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Save as Template")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                LabeledTextField(label: "Template Name", text: $templateName, placeholder: store.currentProject.displayName)
                
                LabeledTextField(label: "Description", text: $templateDescription, placeholder: "Brief description of this template", isMultiLine: true)
            }
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)
                
                Button("Save Template") {
                    saveTemplate()
                }
                .buttonStyle(DefaultButtonStyle())
                .keyboardShortcut(.return)
                .disabled(templateName.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            templateName = store.currentProject.displayName
        }
    }
    
    private func saveTemplate() {
        store.saveAsTemplate(name: templateName, description: templateDescription)
        isPresented = false
    }
}

struct SaveTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        SaveTemplateView(store: SiteStore(), isPresented: .constant(true))
    }
}

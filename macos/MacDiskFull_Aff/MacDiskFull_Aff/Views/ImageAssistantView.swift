
import SwiftUI
import AppKit

struct ImageAssistantView: View {
    @Binding var contentHTML: String
    let site: Site
    var onClose: () -> Void
    
    @State private var placeholders: [DetectedImage] = []
    @State private var isScanning = true
    @State private var processingImageId: UUID? = nil
    @State private var lastError: String? = nil
    
    struct DetectedImage: Identifiable {
        let id = UUID()
        let fullTag: String
        let altText: String
        let src: String
        let width: Int
        let height: Int
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Image Assistant")
                    .font(.headline)
                Spacer()
                Button("Done") { onClose() }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // API Key Warning Banner
            if site.openAIKey.isEmpty || site.openAIKey.hasPrefix("sk-or-") {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                         Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                         Text("OpenAI API Key Required")
                            .bold()
                    }
                    Text("Image Magic (DALL-E 3) requires a direct OpenAI API Key. OpenRouter keys are not supported for this feature.")
                        .font(.caption)
                    
                    HStack {
                         Link("Get OpenAI Key", destination: URL(string: "https://platform.openai.com/api-keys")!)
                         .font(.caption)
                         .foregroundColor(.blue)
                         
                         Text("•").foregroundColor(.secondary)
                         
                         Text("Add it in Settings")
                             .font(.caption)
                             .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.1))
                .border(Color.orange.opacity(0.3), width: 1)
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            if isScanning {
                ProgressView("Scanning for placeholders...")
                    .padding()
            } else if placeholders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No Placeholders Found")
                        .font(.headline)
                    Text("Ask the AI to Polish your article first,\nor manually add <img src=\"https://placehold.co/...\"> tags.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Button("Scan Again") { scanContent() }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(placeholders) { img in
                    HStack(alignment: .top, spacing: 16) {
                        // Thumbnail / Placeholder
                        if #available(macOS 12.0, *) {
                            AsyncImage(url: URL(string: img.src)) { image in
                                 image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                 Color.gray.opacity(0.3)
                            }
                            .frame(width: 100, height: 60)
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.2)))
                        } else {
                            // Fallback for macOS 11
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 60)
                                .cornerRadius(6)
                                .overlay(Text("Img").font(.caption))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Request: \(img.width)x\(img.height)")
                                    .font(.caption)
                                    .padding(2)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                                
                                Text("Image Request")
                                    .font(.caption2).bold().foregroundColor(.secondary)
                            }
                            Text(img.altText)
                                .font(.system(size: 13, weight: .medium))
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            if processingImageId == img.id {
                                ProgressView().scaleEffect(0.5)
                            } else {
                                HStack(spacing: 10) {
                                    // Action Buttons
                                    
                                    // 1. Generate AI
                                    if !site.openAIKey.isEmpty {
                                        Button(action: { startGeneration(for: img) }) {
                                            Label("Generate (DALL-E)", systemImage: "sparkles")
                                        }
                                        .controlSize(.small)
                                    }
                                    
                                    // 2. Search Unsplash
                                    Button(action: { searchUnsplash(term: img.altText) }) {
                                        Label("Unsplash", systemImage: "magnifyingglass")
                                    }
                                    .controlSize(.small)
                                    
                                    // 3. Search Pexels
                                    Button(action: { searchPexels(term: img.altText) }) {
                                        Label("Pexels", systemImage: "photo.fill")
                                    }
                                    .controlSize(.small)
                                    
                                    Spacer()
                                    
                                    // 4. Manual Replace (just info)
                                    Text("Drag & Drop to Editor to Replace")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.top, 4)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            if let error = lastError {
                Text(error)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
                    .padding()
            }
        }
        .frame(minWidth: 600, minHeight: 400)
        .onAppear { scanContent() }
    }
    
    func scanContent() {
        isScanning = true
        placeholders = []
        lastError = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Robust Regex for ALL <img> tags
            let imgPattern = "<img\\s+[^>]*>"
            
            do {
                let regex = try NSRegularExpression(pattern: imgPattern, options: .caseInsensitive)
                // Access contentHTML directly if possible, or pass capture list
                let content = self.contentHTML
                let matches = regex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
                
                var found: [DetectedImage] = []
                
                for match in matches {
                    if let range = Range(match.range, in: content) {
                        let fullTag = String(content[range])
                        
                        // Extract Src (Single or Double Quotes)
                        var src = ""
                        if let srcMatch = self.extractAttribute(from: fullTag, attr: "src", quote: "\"") { src = srcMatch }
                        else if let srcMatch = self.extractAttribute(from: fullTag, attr: "src", quote: "'") { src = srcMatch }
                        
                        // Check if it's a placeholder
                        if src.contains("placehold.co") {
                            // Extract Alt
                            var alt = "Image"
                            if let altMatch = self.extractAttribute(from: fullTag, attr: "alt", quote: "\"") { alt = altMatch }
                            else if let altMatch = self.extractAttribute(from: fullTag, attr: "alt", quote: "'") { alt = altMatch }
                            
                            // Dimensions
                            var w = 1024
                            var h = 1024
                            if let dimRange = src.range(of: "placehold.co/(\\d+)x(\\d+)", options: .regularExpression) {
                                 let dimStr = String(src[dimRange]).replacingOccurrences(of: "placehold.co/", with: "")
                                 let parts = dimStr.split(separator: "x")
                                 if parts.count == 2 {
                                     w = Int(parts[0]) ?? 1024
                                     h = Int(parts[1]) ?? 1024
                                 }
                            }
                            
                            found.append(DetectedImage(fullTag: fullTag, altText: alt, src: src, width: w, height: h))
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.placeholders = found
                    self.isScanning = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isScanning = false
                }
            }
        }
    }
    
    private func extractAttribute(from tag: String, attr: String, quote: String) -> String? {
        let pattern = "\(attr)=\(quote)([^\(quote)]+)\(quote)"
        if let range = tag.range(of: pattern, options: .regularExpression) {
             let raw = String(tag[range])
             return raw.replacingOccurrences(of: "\(attr)=\(quote)", with: "").replacingOccurrences(of: quote, with: "")
        }
        return nil
    }
    
    func startGeneration(for img: DetectedImage) {
        processingImageId = img.id
        lastError = nil
        
        if site.openAIKey.isEmpty {
             lastError = "Missing API Key: Please add your OpenAI or OpenRouter API Key in Site Settings to use Image Magic."
             processingImageId = nil
             return
        }
        
        let prompt = img.altText.replacingOccurrences(of: "PROMPT:", with: "").trimmingCharacters(in: .whitespaces)
        
        // Smart Sizing for DALL-E 3
        // Supports 1024x1024, 1792x1024 (Wide), 1024x1792 (Tall)
        var size = "1024x1024"
        if img.width > Int(Double(img.height) * 1.2) {
            size = "1792x1024" // Wide
        } else if img.height > Int(Double(img.width) * 1.2) {
            size = "1024x1792" // Tall
        }
        
        AIContentService.shared.generateImage(prompt: prompt, size: size, apiKey: site.openAIKey) { result in
            DispatchQueue.main.async {
                processingImageId = nil
                
                switch result {
                case .success(let url):
                    // Replace the tag in HTML
                    // We simply replace 'src="old"' with 'src="new"' or the whole tag.
                    replaceImage(original: img, newURL: url)
                    
                case .failure(let error):
                    lastError = "Generation failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func replaceImage(original: DetectedImage, newURL: String) {
        // Simple string replacement (careful if duplicates exist, but usually unique enough context)
        // We will construct the new tag.
        
        // Use regex to replace src attribute in the fullTag
        let newTag = original.fullTag.replacingOccurrences(of: original.src, with: newURL)
        
        if let range = contentHTML.range(of: original.fullTag) {
            contentHTML.replaceSubrange(range, with: newTag)
            // Re-scan
            scanContent()
        } else {
             lastError = "Could not find original tag to replace. Content changed?"
        }
    }
    
    func searchUnsplash(term: String) {
        let cleanTerm = term.replacingOccurrences(of: "PROMPT:", with: "")
                            // Remove generic words if needed, but search engines are smart
                            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://unsplash.com/s/photos/\(cleanTerm)")!
        NSWorkspace.shared.open(url)
    }
    
    func searchPexels(term: String) {
        let cleanTerm = term.replacingOccurrences(of: "PROMPT:", with: "")
                            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://www.pexels.com/search/\(cleanTerm)/")!
        NSWorkspace.shared.open(url)
    }
}

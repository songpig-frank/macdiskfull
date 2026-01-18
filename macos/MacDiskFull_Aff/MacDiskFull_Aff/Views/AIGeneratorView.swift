
import SwiftUI

struct AIGeneratorView: View {
    @Binding var site: Site
    var onSave: (Article) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var topic = "Mac Mini M4 Teardown"
    @State private var urlString = ""
    @State private var transcript = ""
    @State private var videoTitle = ""
    @State private var videoChannel = ""
    @State private var videoDate = ""
    
    @State private var isGenerating = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("AI Article Writer")
                    .font(.title2).bold()
                Spacer()
                Button("Cancel") { presentationMode.wrappedValue.dismiss() }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            Form {
                Section(header: Text("Configuration")) {
                    SecureField("API Key (Required)", text: $site.openAIKey)
                    if site.openAIKey.isEmpty {
                        Text("Get a key from platform.openai.com or openrouter.ai").font(.caption).foregroundColor(.red)
                    }
                    
                    Picker("Provider", selection: $site.aiProvider) {
                        Text("OpenAI").tag("OpenAI")
                        Text("OpenRouter").tag("OpenRouter")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if site.aiProvider == "OpenAI" {
                        Picker("Model", selection: $site.aiModel) {
                            Text("GPT-4o").tag("gpt-4o")
                            Text("GPT-4 Turbo").tag("gpt-4-turbo")
                            Text("GPT-3.5 Turbo").tag("gpt-3.5-turbo")
                        }
                    } else {
                        Picker("Model", selection: $site.aiModel) {
                            Text("Claude 3.5 Sonnet").tag("anthropic/claude-3.5-sonnet")
                            Text("GPT-4o (via OR)").tag("openai/gpt-4o")
                            Text("Llama 3 70B").tag("meta-llama/llama-3-70b-instruct")
                            Text("Mixtral 8x22B").tag("mistralai/mixtral-8x22b")
                            Text("Gemini Pro 1.5").tag("google/gemini-pro-1.5")
                        }
                    }
                }
                
                Section(header: Text("Step 1: Research")) {
                    TextField("Topic", text: $topic)
                    Link(destination: URL(string: "https://www.youtube.com/results?search_query=\(topic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Search YouTube for '\(topic)'")
                        }
                    }
                }
                
                Section(header: Text("Step 2: Source Info")) {
                    TextField("YouTube URL", text: $urlString)
                    HStack {
                        Button("Fetch Title") { fetchInfo() }
                            .disabled(urlString.isEmpty)
                        if !videoTitle.isEmpty {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        }
                    }
                    
                    TextField("Video Title", text: $videoTitle)
                    TextField("Channel Name", text: $videoChannel)
                    TextField("Publish Date", text: $videoDate)
                    
                    VStack(alignment: .leading) {
                        Text("Transcript / Notes")
                        TextEditor(text: $transcript)
                            .frame(height: 120)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.2)))
                        Text("Tip: Click 'Show Transcript' on YouTube and copy/paste here.")
                            .font(.caption).foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: generate) {
                        HStack {
                            if isGenerating { ProgressView().scaleEffect(0.5) }
                            Text(isGenerating ? "Generating..." : "Generate Draft Article")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(site.openAIKey.isEmpty || transcript.isEmpty)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
        .frame(width: 500, height: 800)
    }
    
    func fetchInfo() {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let html = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    // Simple Regex for Title
                    if let range = html.range(of: "<title>(.*?)</title>", options: .regularExpression) {
                        let raw = String(html[range])
                        let clean = raw.replacingOccurrences(of: "<title>", with: "").replacingOccurrences(of: " - YouTube</title>", with: "").replacingOccurrences(of: "</title>", with: "")
                        self.videoTitle = clean
                    }
                }
            }
        }.resume()
    }
    
    func generate() {
        isGenerating = true
        errorMessage = ""
        
        let meta = VideoMetadata(
            title: videoTitle.isEmpty ? "New Article" : videoTitle,
            channel: videoChannel.isEmpty ? "Unknown Source" : videoChannel,
            date: videoDate.isEmpty ? "Recent" : videoDate,
            url: urlString
        )
        
        AIContentService.shared.generateArticle(
            transcript: transcript,
            metadata: meta,
            apiKey: site.openAIKey,
            provider: site.aiProvider,
            model: site.aiModel
        ) { result in
            DispatchQueue.main.async {
                isGenerating = false
                switch result {
                case .success(let article):
                    onSave(article)
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

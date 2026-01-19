
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
    
    @State private var includeNoTranscript = false
    @State private var isSearching = false
    @State private var searchResults: [VideoCandidate] = []
    
    struct VideoCandidate: Decodable, Identifiable {
        var id: String
        var title: String
        var channel: String
        var published: String
        var url: String
        var score: Double
    }
    
    @State private var isGenerating = false
    @State private var errorMessage = ""
    @State private var connectionStatus = ""
    @State private var isTestingInfo = false
    @State private var fetchStatus = ""
    
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
                    Picker("Provider", selection: $site.aiProvider) {
                        Text("OpenAI").tag("OpenAI")
                        Text("Anthropic").tag("Anthropic")
                        Text("Ollama (Local)").tag("Ollama")
                        Text("OpenRouter").tag("OpenRouter")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Provider Specific Fields
                    if site.aiProvider == "OpenAI" {
                        SecureField("OpenAI API Key", text: $site.openAIKey)
                        Picker("Model", selection: $site.aiModel) {
                            Text("GPT-4o").tag("gpt-4o")
                            Text("GPT-4 Turbo").tag("gpt-4-turbo")
                            Text("GPT-3.5 Turbo").tag("gpt-3.5-turbo")
                        }
                    } else if site.aiProvider == "Anthropic" {
                        SecureField("Anthropic API Key", text: $site.anthropicKey)
                        Picker("Model", selection: $site.aiModel) {
                            Text("Claude 3.5 Sonnet").tag("claude-3-5-sonnet-20240620")
                            Text("Claude 3 Opus").tag("claude-3-opus-20240229")
                            Text("Claude 3 Haiku").tag("claude-3-haiku-20240307")
                        }
                    } else if site.aiProvider == "Ollama" {
                        TextField("Base URL", text: $site.ollamaURL)
                        TextField("Model Name (e.g. llama3)", text: $site.aiModel)
                        Text("Ensure 'ollama serve' is running.").font(.caption)
                    } else if site.aiProvider == "OpenRouter" {
                        SecureField("OpenRouter Key", text: $site.openAIKey)
                        Picker("Model", selection: $site.aiModel) {
                             Text("Claude 3.5 Sonnet").tag("anthropic/claude-3.5-sonnet")
                             Text("GPT-4o").tag("openai/gpt-4o")
                             Text("Llama 3 70B").tag("meta-llama/llama-3-70b-instruct")
                             Text("Mixtral 8x22B").tag("mistralai/mixtral-8x22b")
                             Text("Gemini Pro 1.5").tag("google/gemini-pro-1.5")
                        }
                    }
                    
                    // Test Button
                    HStack {
                        Button("Test Connection") { testConnection() }
                        if !connectionStatus.isEmpty {
                            Text(connectionStatus)
                                .foregroundColor(connectionStatus.contains("Success") ? .green : .red)
                                .font(.caption)
                        }
                    }
                }
                
                Section(header: Text("Step 1: Research")) {
                    TextField("Topic", text: $topic)
                    
                    if isSearching {
                        ProgressView("Finding best videos with transcripts...")
                    } else {
                        Button("Find Best Videos (Auto-Ranked)") {
                            findBestVideos()
                        }
                        Toggle("Include videos without transcripts", isOn: $includeNoTranscript)
                            .font(.caption)
                    }
                    
                    if !searchResults.isEmpty {
                        List(searchResults) { video in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading) {
                                    Text(video.title)
                                        .font(.system(size: 14, weight: .medium))
                                        .lineLimit(2)
                                    Text(video.channel)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Open in Browser
                                Button(action: {
                                    if let url = URL(string: video.url) { NSWorkspace.shared.open(url) }
                                }) {
                                    Image(systemName: "safari")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .help("Open in Browser")
                                
                                // Select Button
                                Button("Use This") {
                                    selectVideo(video)
                                }
                                // .buttonStyle(BorderedProminentButtonStyle()) // Removed for macOS 11 compat
                            }
                            .padding(.vertical, 4)
                        }
                        .frame(height: 250)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                    }
                    
                    Link(destination: URL(string: "https://www.youtube.com/results?search_query=\(topic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Manual Search on YouTube")
                                .font(.caption)
                        }
                    }
                }
                
                Section(header: HStack {
                    Text("Step 2: Source Info")
                    Spacer()
                    Button("Debug: Fill Sample") {
                        self.urlString = "https://www.youtube.com/watch?v=jfKfPfyJRdk" // Lofi Girl (Always alive)
                        self.videoTitle = "lofi hip hop radio - beats to relax/study to"
                        self.videoChannel = "Lofi Girl"
                        self.videoDate = "2024-01-01"
                        self.transcript = "[SAMPLE TRANSCRIPT]\nIn this video, we listen to relaxing beats. The music is chill, lo-fi hip hop. It is great for studying and working. The stream runs 24/7. (This is a sample to prove the AI Writer works)."
                    }
                    .font(.caption)
                }) {
                    TextField("YouTube URL", text: $urlString)
                    HStack {
                        Button("Fetch Info") { fetchInfo() }
                            .disabled(urlString.isEmpty)
                        Text(fetchStatus)
                            .font(.caption)
                            .foregroundColor(fetchStatus.contains("Fail") || fetchStatus.contains("hidden") || fetchStatus.contains("Error") ? .orange : .gray)
                        

                        
                        if !videoTitle.isEmpty && fetchStatus.isEmpty {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        TextField("Video Title", text: $videoTitle)
                        TextField("Channel Name", text: $videoChannel)
                        HStack {
                            Text("Date:")
                                .frame(width: 40, alignment: .leading)
                            TextField("Publish Date", text: $videoDate)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Transcript / Notes")
                            Spacer()
                            if !videoTitle.isEmpty {
                                Button("Fetch Transcript (Optional)") { fetchTranscriptSmart() }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        TextEditor(text: $transcript)
                            .frame(height: 200) // Taller for manual input
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.2)))
                        Text("Paste your notes, article text, or valid transcript here.")
                            .font(.caption).foregroundColor(.secondary)
                    }
                }
                // Removed Debug Alert
                
                Section {
                    Button(action: generate) {
                        HStack {
                            if isGenerating { ProgressView().scaleEffect(0.5) }
                            Text(isGenerating ? "Generating..." : "Generate Draft Article")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(transcript.isEmpty)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
        .frame(width: 550, height: 850)
        .overlay(
            isTestingInfo ?
            ZStack {
                Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    Text("Dev Quick Start")
                        .font(.title).bold()
                    Text("Pre-load a known working video to test the AI pipeline?")
                        .multilineTextAlignment(.center)
                    HStack {
                        Button("Cancel") { isTestingInfo = false }
                            .padding()
                        Button("Load Sample Data") {
                            self.urlString = "https://www.youtube.com/watch?v=jfKfPfyJRdk"
                            self.videoTitle = "lofi hip hop radio - beats to relax/study to"
                            self.videoChannel = "Lofi Girl"
                            self.videoDate = "2024-01-01"
                            self.transcript = "[SAMPLE TRANSCRIPT]\nIn this video, we listen to relaxing beats. The music is chill, lo-fi hip hop. It is great for studying and working. The stream runs 24/7. (This is a sample to prove the AI Writer works)."
                            isTestingInfo = false
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding(40)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(12)
                .shadow(radius: 20)
            } : nil
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.urlString.isEmpty {
                    self.isTestingInfo = true
                }
            }
        }
    }
    
    func testConnection() {
        connectionStatus = "Testing..."
        // Determine Key based on provider
        var key = site.openAIKey
        if site.aiProvider == "Anthropic" { key = site.anthropicKey }
        // Ollama uses URL not key (usually)
        
        AIContentService.shared.testConnection(
            provider: site.aiProvider,
            apiKey: key,
            model: site.aiModel,
            endpointURL: site.ollamaURL
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    connectionStatus = "Success! Connected."
                case .failure(let err):
                    connectionStatus = "Failed: \(err.localizedDescription)"
                }
            }
        }
    }
    

    func fetchInfo() {
        fetchStatus = "Fetching metadata..."
        
        // Convert Shorts URL to Watch URL for better scraping
        var targetURLString = urlString
        if urlString.contains("/shorts/") {
            targetURLString = urlString.replacingOccurrences(of: "/shorts/", with: "/watch?v=")
        }
        
        guard let url = URL(string: targetURLString) else {
            fetchStatus = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.addValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data, let html = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    var foundMeta = false
                    
                    // 1. Fetch Title
                    if let range = html.range(of: "<title>(.*?)</title>", options: .regularExpression) {
                        let raw = String(html[range])
                        let clean = raw.replacingOccurrences(of: "<title>", with: "").replacingOccurrences(of: " - YouTube</title>", with: "").replacingOccurrences(of: "</title>", with: "")
                        self.videoTitle = clean
                        foundMeta = true
                    }
                    
                    // 2. Fetch Channel
                    if let range = html.range(of: "<link itemprop=\"name\" content=\"(.*?)\"", options: .regularExpression) {
                        let raw = String(html[range])
                        if let content = raw.components(separatedBy: "content=\"").last?.dropLast() {
                             self.videoChannel = String(content)
                        }
                    }
                    
                    // 3. Fetch Date
                    if let range = html.range(of: "<meta itemprop=\"datePublished\" content=\"(.*?)\"", options: .regularExpression) {
                        let raw = String(html[range])
                        if let content = raw.components(separatedBy: "content=\"").last?.dropLast() {
                             self.videoDate = String(content)
                        }
                    }
                    
                    if foundMeta {
                        self.fetchStatus = "Metadata found. Checking for transcript..."
                    } else {
                        self.fetchStatus = "Could not parse page (YouTube blocking?)"
                    }
                    
                    // 4. Try Fetch Transcript
                    var transcriptFound = false
                    if let range = html.range(of: "\"captionTracks\":\\[\\{\"baseUrl\":\"(.*?)\"", options: .regularExpression) {
                        let match = String(html[range])
                        if let urlStart = match.components(separatedBy: "\"baseUrl\":\"").last {
                            let urlString = urlStart.replacingOccurrences(of: "\\u0026", with: "&").replacingOccurrences(of: "\\", with: "")
                            
                            if let captionURL = URL(string: urlString) {
                                print("Found Caption URL: \(captionURL)")
                                self.fetchTranscriptXML(url: captionURL)
                                transcriptFound = true
                            }
                        }
                    }
                    
                    if !transcriptFound && foundMeta {
                         self.fetchStatus = "Data found. Transcript hidden/auto-generated (Copy Manually)."
                    }
                }
            } else {
                DispatchQueue.main.async { self.fetchStatus = "Network Error" }
            }
        }.resume()
    }
    
    func fetchTranscriptXML(url: URL) {
        self.fetchStatus = "Downloading captions..."
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let xml = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    do {
                        let regex = try NSRegularExpression(pattern: "<text.*?>(.*?)</text>", options: [])
                        let matches = regex.matches(in: xml, options: [], range: NSRange(location: 0, length: xml.count))
                        
                        var fullText = ""
                        for match in matches {
                            if let range = Range(match.range(at: 1), in: xml) {
                                let line = String(xml[range])
                                fullText += line.replacingOccurrences(of: "&amp;", with: "&")
                                                .replacingOccurrences(of: "&#39;", with: "'")
                                                .replacingOccurrences(of: "&quot;", with: "\"")
                                                + " "
                            }
                        }
                        
                        if !fullText.isEmpty {
                            self.transcript = fullText
                            self.fetchStatus = "Success: Transcript extracted!"
                        } else {
                            self.fetchStatus = "Captions found but empty."
                        }
                    } catch {
                        self.fetchStatus = "Caption parse error."
                    }
                }
            }
        }.resume()
    }

    
    func fetchTranscriptSmart() {
        self.fetchStatus = "Fetching transcript (Native)..."
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.addValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async { self.fetchStatus = "Network Error" }
                return
            }
            
            // 1. Find Caption Tracks
            // Pattern: "captionTracks":[{"baseUrl":"..."
            if let range = html.range(of: "\"captionTracks\":[{\"baseUrl\":\"") {
                let suffix = String(html[range.upperBound...])
                if let endRange = suffix.range(of: "\"") {
                    let captionUrlString = String(suffix[..<endRange.lowerBound]).replacingOccurrences(of: "\\u0026", with: "&")
                    
                    if let captionUrl = URL(string: captionUrlString) {
                        self.fetchCaptionXML(url: captionUrl)
                        return
                    }
                }
            }
            
            // If failed, try Python fallback (only if Native fails)
            DispatchQueue.main.async {
                self.fetchStatus = "Native fetch failed. Trying Python..."
                self.fetchTranscriptPythonFallback()
            }
        }.resume()
    }
    
    @State private var lastRawResponse = ""
    @State private var showingRawData = false

    func fetchCaptionXML(url: URL) {
        print("Fetching Captions from: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
         request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.addValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data, let content = String(data: data, encoding: .utf8) else { return }
            
            print("RAW CAPTION DATA (\(content.count) chars): \(content.prefix(500))...")
            DispatchQueue.main.async { self.lastRawResponse = content }
            
            var fullText = ""
            
            // Format 1: JSON
            if content.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("{") {
                if let jsonData = content.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                   let events = json["events"] as? [[String: Any]] {
                    for event in events {
                        if let segs = event["segs"] as? [[String: Any]] {
                            for seg in segs {
                                if let text = seg["utf8"] as? String { fullText += text }
                            }
                            fullText += " "
                        }
                    }
                }
            } else {
                // Format 2: XML
                 do {
                    let regex = try NSRegularExpression(pattern: "<text.*?>(.*?)</text>", options: [])
                    let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
                    for match in matches {
                        if let r = Range(match.range(at: 1), in: content) {
                            let text = String(content[r])
                                .replacingOccurrences(of: "&#39;", with: "'")
                                .replacingOccurrences(of: "&quot;", with: "\"")
                                .replacingOccurrences(of: "&amp;", with: "&")
                            fullText += text + " "
                        }
                    }
                } catch { }
            }
            
            DispatchQueue.main.async {
                if fullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.fetchStatus = "Empty. Tap to View Raw."
                } else {
                    self.transcript = fullText
                    self.fetchStatus = "Success! (Native)"
                }
            }
        }.resume()
    }

    func fetchTranscriptPythonFallback() {
        // ... (Keep existing Python logic here as backup)
        // For brevity in this edit, I'm renaming the old function or calling it.
        // Actually, I'll just keep the old body here if I can, or rely on the fact that I'm replacing the old 'fetchTranscriptPython'
        
        // RE-INSERTING THE PYTHON LOGIC AS FALLBACK
        let shellPath = "/bin/sh"
        let scriptPath = "/Users/nc/macdiskfull_affiliate/macos/MacDiskFull_Aff/MacDiskFull_Aff/Services/scripts/get_transcript.py"
        
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: shellPath)
            let command = "python3 \"\(scriptPath)\" \"\(self.urlString)\""
            task.arguments = ["-c", command]
            
            // ... (rest of python logic)
            // If it fails here, we report error.
             var env = ProcessInfo.processInfo.environment
            env["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
            task.environment = env
            
            let outPipe = Pipe()
            let errPipe = Pipe()
            task.standardOutput = outPipe
            task.standardError = errPipe
            
            do {
                try task.run()
                task.waitUntilExit()
                
                let data = outPipe.fileHandleForReading.readDataToEndOfFile()
                let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
                
                if let jsonStr = String(data: data, encoding: .utf8) {
                    if let jsonData = jsonStr.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                        if let text = json["text"] as? String {
                             DispatchQueue.main.async {
                                 self.transcript = text
                                 self.fetchStatus = "Success (Python)!"
                             }
                        } else {
                             // Finally give up
                             DispatchQueue.main.async { 
                                 let err = json["error"] as? String ?? "Unknown"
                                 self.fetchStatus = "Failed: \(err). Copy manually?" 
                             }
                        }
                    }
                }
            } catch {
                 DispatchQueue.main.async { self.fetchStatus = "Sandbox Blocked. Copy manually." }
            }
        }
    }
    
    func findBestVideos() {
        isSearching = true
        searchResults = []
        
        guard let encodedQuery = topic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.youtube.com/results?search_query=\(encodedQuery)") else {
            isSearching = false
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.addValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                defer { DispatchQueue.main.async { self.isSearching = false } }
                return
            }
            
            // 1. Initial Parse
            let components = html.components(separatedBy: "videoRenderer\":{\"videoId\":\"")
            var potentialCandidates: [VideoCandidate] = []
            
            for (index, component) in components.enumerated() {
                if index == 0 { continue }
                
                let vidID = String(component.prefix(11))
                var title = "Unknown Title"
                
                if let titleStart = component.range(of: "\"title\":{\"runs\":[{\"text\":\"") {
                    let suffix = String(component[titleStart.upperBound...])
                    if let titleEnd = suffix.range(of: "\"}") {
                        title = String(suffix[..<titleEnd.lowerBound])
                    }
                }
                
                if vidID.count == 11 {
                    potentialCandidates.append(VideoCandidate(
                        id: vidID,
                        title: title,
                        channel: "YouTube",
                        published: "",
                        url: "https://www.youtube.com/watch?v=\(vidID)",
                        score: 1.0
                    ))
                }
                if potentialCandidates.count >= 8 { break } // Limit to 8 checks
            }
            
            // 2. Parallel Verification
            let group = DispatchGroup()
            var verifiedCandidates: [VideoCandidate] = []
            let lock = NSLock()
            
            for candidate in potentialCandidates {
                if self.includeNoTranscript {
                     lock.lock()
                     verifiedCandidates.append(candidate)
                     lock.unlock()
                } else {
                    group.enter()
                    self.checkTranscriptAvailability(videoID: candidate.id) { available in
                        if available {
                            lock.lock()
                            verifiedCandidates.append(candidate)
                            lock.unlock()
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.isSearching = false
                self.searchResults = verifiedCandidates
                if verifiedCandidates.isEmpty {
                     self.videoTitle = "No videos with transcripts found."
                }
            }
        }.resume()
    }
    
    func checkTranscriptAvailability(videoID: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") else {
            completion(false); return
        }
        var request = URLRequest(url: url)
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                completion(false); return
            }
            // Check for captionTracks present in the video page
            let hasCaptions = html.contains("\"captionTracks\":[{\"baseUrl\":\"")
            completion(hasCaptions)
        }.resume()
    }
    
    func selectVideo(_ video: VideoCandidate) {
        self.urlString = video.url
        self.videoTitle = video.title
        self.videoChannel = video.channel
        self.videoDate = video.published
        self.searchResults = []
        
        // Auto-Fetch Transcript (Smart Native First)
        fetchTranscriptSmart()
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
        
        var key = site.openAIKey
        if site.aiProvider == "Anthropic" { key = site.anthropicKey }
        
        AIContentService.shared.generateArticle(
            transcript: transcript,
            metadata: meta,
            apiKey: key,
            provider: site.aiProvider,
            model: site.aiModel,
            endpointURL: site.ollamaURL
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

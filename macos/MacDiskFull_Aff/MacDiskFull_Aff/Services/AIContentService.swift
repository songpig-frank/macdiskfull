
import Foundation

struct VideoMetadata {
    var title: String
    var channel: String
    var date: String
    var url: String
}

struct ScoreComponent: Decodable {
    let criterion: String
    let score: Int
        let score_breakdown: [ScoreComponent]?
    let max_score: Int
    let reasoning: String
}

struct PolishedResult: Decodable {
    let title: String
    let slug: String // SEO friendly URL slug
    let summary: String // Meta description / Excerpt
    let html: String
    let original_score: Int // Score of the input content
    let seo_score: Int // Technical SEO Score
    let marketing_score: Int // Creative/Marketing Impact Score
    let score_breakdown: [ScoreComponent]? // Detailed breakdown
    let keywords: [String]
    let analysis: String
    let recommendations: [String] // Steps to reach 100%
    let conflict_resolution: String? // Advice if SEO and AI conflict
}

class AIContentService {
    static let shared = AIContentService()
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 180 // 3 minutes timeout for long generations
        config.timeoutIntervalForResource = 180
        self.session = URLSession(configuration: config)
    }
    
    // DEBUG LOGGING
    static func logDebug(_ message: String) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = formatter.string(from: date)
        let logMessage = "[\(timestamp)] \(message)\n"
        
        print("📝 \(logMessage.trimmingCharacters(in: .whitespacesAndNewlines))") // Also print to console
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("WebMakr_Debug.log")
        
        // Print the command ONCE so the user sees it
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            print("\n🔍 TO VIEW LOGS RUN:\ntail -f \(fileURL.path)\n")
        }
            
        if let handle = try? FileHandle(forWritingTo: fileURL) {
            handle.seekToEndOfFile()
            handle.write(logMessage.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? logMessage.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }
    
    enum AIError: Error, LocalizedError {
        case missingKey
        case invalidResponse
        case apiError(String)
        case jsonParsingFailed(String, String) // Error, RawJSON
        
        var errorDescription: String? {
            switch self {
            case .missingKey: return "API Key is missing."
            case .invalidResponse: return "Invalid response from API."
            case .apiError(let msg): return "API Error: \(msg)"
            case .jsonParsingFailed(let err, _): return "Failed to parse JSON: \(err)"
            }
        }
    }
    
    // Test Connection
    func testConnection(provider: String, apiKey: String, model: String, endpointURL: String = "", completion: @escaping (Result<String, Error>) -> Void) {
        let prompt = "Say 'OK' if you can hear me."
        // We reuse generateArticle logic but with short prompt and raw output
        // For simplicity, we create a specialized request
        
        generateRaw(prompt: prompt, system: "You are a test bot.", provider: provider, apiKey: apiKey, model: model, endpointURL: endpointURL) { result in
             switch result {
             case .success(let content):
                 completion(.success(content))
             case .failure(let error):
                 completion(.failure(error))
             }
        }
    }
    
    func generateArticle(transcript: String, metadata: VideoMetadata, apiKey: String, provider: String = "OpenAI", model: String = "gpt-4o", endpointURL: String = "", completion: @escaping (Result<Article, Error>) -> Void) {
        
        let systemPrompt = "You are an expert tech journalist. Output raw HTML content (no ```html wrappers)."
        let userPrompt = """
        Write a detailed, authoritative blog post based on this YouTube transcript.
        
        Title: \(metadata.title)
        Channel: \(metadata.channel)
        
        Instructions:
        1. Write a catchy Title.
        2. Body must be HTML (<h3>, <p>, <ul>). No <html> tags.
        3. Reference the YouTuber.
        4. End with "||SUMMARY||" followed by a 2-sentence meta description.
        
        Transcript:
        \(transcript.prefix(25000))
        """
        
        generateRaw(prompt: userPrompt, system: systemPrompt, provider: provider, apiKey: apiKey, model: model, endpointURL: endpointURL) { result in
            switch result {
            case .success(let content):
                 // Parse
                 var clean = content.replacingOccurrences(of: "```html", with: "").replacingOccurrences(of: "```", with: "")
                 
                 var summary = "Generated by AI"
                 if let range = clean.range(of: "||SUMMARY||") {
                     summary = String(clean[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                     clean = String(clean[..<range.lowerBound])
                 }
                 
                 // Heuristic Title extraction if in text
                 var title = metadata.title
                 let lines = clean.components(separatedBy: "\n").filter { !$0.isEmpty }
                 if let first = lines.first, first.lowercased().hasPrefix("title:") {
                     title = first.replacingOccurrences(of: "Title:", with: "").trimmingCharacters(in: .whitespaces)
                     clean = clean.replacingOccurrences(of: first, with: "")
                 }
                 
                 let article = Article(
                     title: title,
                     slug: metadata.title.lowercased().filter { "abcdefghijklmnopqrstuvwxyz0123456789".contains($0) } + "-" + String(Int(Date().timeIntervalSince1970)),
                     summary: summary,
                     contentHTML: clean,
                     author: "AI"
                 )
                 completion(.success(article))
                 
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    struct ContentAnalysis: Decodable {
        let score: Int // Technical SEO
        let marketing_score: Int // Creative/Marketing
        let score_breakdown: [ScoreComponent]?
        let analysis: String
        let recommendations: [String]
    }

    func analyzeContent(contentHTML: String, siteName: String, siteTagline: String, apiKey: String, provider: String = "OpenAI", model: String = "gpt-4o", endpointURL: String = "", completion: @escaping (Result<ContentAnalysis, Error>) -> Void) {
        let systemPrompt = "You are an elite SEO Evaluator. Output valid JSON only."
        let userPrompt = """
        Evaluate the following blog post for the website "\(siteName)" (\(siteTagline)).
        Return a JSON object:
        {
            "score": 0-100, // Technical SEO Score
            "marketing_score": 0-100, // AI Visibility Score (Likelihood to be cited by LLMs)
            "score_breakdown": [
                { "criterion": "LLM Optimization", "score": 15, "max_score": 20, "reasoning": "Clear direct answers." }
            ],
            "analysis": "Short explanation of the score.",
            "recommendations": ["Point 1", "Point 2"]
        }
        
        CRITERIA (Sum max 20 each): 
        1. Title Impact
        2. Uniqueness
        3. Keywords
        4. Structure (bonus for <img>)
        5. Engagement (visuals = points)
        
        CONTENT:
        \(contentHTML.prefix(15000))
        """
        
        generateRaw(prompt: userPrompt, system: systemPrompt, provider: provider, apiKey: apiKey, model: model, endpointURL: endpointURL) { result in
            switch result {
            case .success(let jsonString):
                 AIContentService.logDebug("[analyzeContent] Received response")
                 var clean = jsonString
                 if let start = jsonString.range(of: "{"), let end = jsonString.range(of: "}", options: .backwards) {
                     clean = String(jsonString[start.lowerBound...end.lowerBound])
                 }
                 
                 if let data = clean.data(using: .utf8) {
                     do {
                        let analysis = try JSONDecoder().decode(ContentAnalysis.self, from: data)
                        completion(.success(analysis))
                     } catch {
                        AIContentService.logDebug("[analyzeContent] JSON Decode Error: \(error)")
                        completion(.failure(AIError.jsonParsingFailed("Invalid JSON", clean)))
                     }
                 } else {
                     completion(.failure(AIError.jsonParsingFailed("Invalid JSON Data", clean)))
                 }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func polishArticle(contentHTML: String, siteName: String, siteTagline: String, existingTitles: [String], customRules: String, apiKey: String, provider: String = "OpenAI", model: String = "gpt-4o", endpointURL: String = "", completion: @escaping (Result<PolishedResult, Error>) -> Void) {
        
        AIContentService.logDebug("[polishArticle] Initiated. Provider: \(provider), Model: \(model)")
        
        let systemPrompt = "You are an elite SEO & AI Optimization Expert. Output valid JSON only."
        
        // Format existing titles
        let forbiddenTitles = existingTitles.prefix(50).joined(separator: "\n- ")
        
        let userPrompt = """
        Analyze, Optimize, and Polish the following blog post. Return a JSON object with this structure:
        {
          "title": "A Viral, High-CTR, SEO-Optimized Title (Max 60 chars)",
          "slug": "clean-keyword-rich-url-slug",
          "summary": "Compelling meta description (1-2 sentences)",
          "original_score": 45, // EVALUATE the input content score (0-100) BEFORE changes
          "seo_score": 95, // Technical SEO Score
          "marketing_score": 92, // AI Visibility / LLM Citation Score
          "score_breakdown": [
            { "criterion": "Title & Hooks", "score": 9, "max_score": 10, "reasoning": "Great clickability" },
            { "criterion": "Content Depth", "score": 18, "max_score": 20, "reasoning": "Comprehensive" },
            { "criterion": "Visuals", "score": 5, "max_score": 20, "reasoning": "Needs real images" },
            { "criterion": "Keyword Optimization", "score": 10, "max_score": 10, "reasoning": "Targeting 'mac storage' well" }
          ],
          "html": "The polished HTML body content (MUST ESCAPE ALL QUOTES)",
          "keywords": ["keyword1", "keyword2"], // Target keywords found/added
          "analysis": "EDUCATIONAL BREAKDOWN:\n- PROBLEM: [Analysis]\n- SOLUTION: [Solution]",
          "recommendations": ["Step 1", "Step 2"],
          "conflict_resolution": "Verdict on SEO vs AI conflicts"
        }
        
        IMPORTANT: Your output parsing depends on VALID JSON.
        - You MUST escape all double quotes inside the "html" string (e.g. <img src=\"...\" />).
        - Do not output markdown code blocks. Just the raw JSON string.
        
        CONTEXT:
        Site Name: \(siteName)
        Tagline: \(siteTagline)
        
        EXISTING TITLES (DO NOT DUPLICATE):
        - \(forbiddenTitles)

        Instructions:
        1. **Relevance Check**: The target website is "\(siteName)" (\(siteTagline)). 
           - If the input content is NOT related to this niche, **SCORE IT 0** in `original_score`, `seo_score`, and `marketing_score`.
           - Do not polish it. Just return the analysis explaining why it is irrelevant.
        2. **Title Magic**: Create a unique, viral title that ranks. 
           - CRITICAL: It MUST NOT be in the "EXISTING TITLES" list.
        3. **Slug & Summary**: 
           - Generate a SEO-friendly `slug` (kebab-case) from your new title.
           - Generate a compelling `summary` (1-2 sentences) for the meta description.
        4. **REMOVE ALL AI ARTIFACTS**: Delete any of these patterns:
           - "Here is the article...", "Here's a...", "I've written..."
           - "I hope this helps!", "Let me know if you need..."
           - "Sources:", "References:", "Citations:"
           - "Sure!", "Certainly!", "Of course!"
           - "As an AI...", "As a language model..."
           - Any meta-commentary about the writing process
           - Markdown headers like "# Title" if they duplicate the title field
        5. **Strict Scoring Logic**: 
           - **SEO Score** (0-100): Evaluate Google ranking potential (Keywords, Metadata, Length, Image Tags).
           - **AI Visibility Score** (0-100): Evaluate likelihood of being cited by ChatGPT/Perplexity (GEO).
             - **Direct Answers**: Does it answer user queries immediately? (No fluff).
             - **Structure**: Uses clear Bullet Points, Tables, and Headers that LLMs can parse easily.
             - **Authority**: High fact density and unique insights.
           - Use the criteria list for `score_breakdown` to support these scores.
           - If `<img>` tags are missing, BOTH scores should be penalized.
        6. **Visuals (CRITICAL)**: 
           - **EXISTING IMAGES**: Preserve exact `<img>` tags. Do not touch them.
           - **MISSING IMAGES**: You MUST insert `<img src="https://placehold.co/600x400/png" alt="PROMPT: Describe image here" />` placeholders where potential images should go.
           - **RULE**: Every 300-400 words (or every major section) NEEDS a visual.
           - **The User doesn't know what images to add - YOU must tell them via these placeholders.**
        7. **Score (REALITY CHECK)**:
           - **PLACEHOLDERS = LOW SCORE**: If the content contains `placehold.co` or generic placeholders, `seo_score` MUST NOT exceed 70. `marketing_score` can be higher if text is excellent. Comment: "Replace placeholders with real images."
           - **REAL IMAGES = HIGH SCORE**: You can only award 90+ if the `<img>` tags point to real, specific image files/URLs (not placeholders).
           - This ensures we grade the *visual reality* of the page, not just the text.
        \(customRules)
        
        Content:
        \(contentHTML.prefix(25000))
        """
        
        generateRaw(prompt: userPrompt, system: systemPrompt, provider: provider, apiKey: apiKey, model: model, endpointURL: endpointURL) { result in
             switch result {

             case .success(let content):
                  AIContentService.logDebug("[polishArticle] Received content from generateRaw: \(content.count) chars")
                  print("📥 [AI Raw Response] First 500 chars:")
                  print(String(content.prefix(500)))
                  
                  // Try to find JSON block
                  var jsonString = content
                  if let start = content.range(of: "{"), let end = content.range(of: "}", options: .backwards) {
                       jsonString = String(content[start.lowerBound...end.lowerBound])
                  }
                  
                  AIContentService.logDebug("[polishArticle] JSON Extracted: \(jsonString.count) chars")
                  
                  if let data = jsonString.data(using: .utf8) {
                       do {
                            let result = try JSONDecoder().decode(PolishedResult.self, from: data)
                            AIContentService.logDebug("[polishArticle] parsing SUCCESS")
                            completion(.success(result))
                       } catch {
                            AIContentService.logDebug("[polishArticle] JSON parsing FAILED: \(error)")
                            let snippet = String(jsonString.prefix(1000))
                            print("❌ [JSON Parse] JSON was: \(snippet)")
                            completion(.failure(AIError.jsonParsingFailed(error.localizedDescription, snippet)))
                       }
                  } else {
                       print("❌ [JSON Parse] Failed to convert to Data")
                       completion(.failure(AIError.apiError("Failed to parse JSON response")))
                  }
             case .failure(let error):
                  print("❌ [AI Request] Failed: \(error)")
                  completion(.failure(error))
             }
        }
    }
    
    // Unified Backend
    private func generateRaw(prompt: String, system: String, provider: String, apiKey: String, model: String, endpointURL: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        if provider != "Ollama" && apiKey.isEmpty {
            completion(.failure(AIError.missingKey))
            return
        }
        
        if provider == "Anthropic" {
            generateAnthropic(prompt: prompt, system: system, apiKey: apiKey, model: model, completion: completion)
            return
        }
        
        // OpenAI / OpenRouter / Ollama (OpenAI Compatible)
        var baseURL = ""
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        
        switch provider {
        case "OpenAI":
            baseURL = "https://api.openai.com/v1/chat/completions"
        case "OpenRouter":
            baseURL = "https://openrouter.ai/api/v1/chat/completions"
            headers["HTTP-Referer"] = "https://webmakr.app"
            headers["X-Title"] = "WebMakr"
        case "Ollama":
            // Use provided URL or default
            let base = endpointURL.isEmpty ? "http://localhost:11434" : endpointURL
            // Ensure /v1/chat/completions attached
            if base.hasSuffix("/v1/chat/completions") {
                baseURL = base
            } else if base.hasSuffix("/") {
                 baseURL = base + "v1/chat/completions"
            } else {
                 baseURL = base + "/v1/chat/completions"
            }
            headers["Authorization"] = "Bearer ollama" // Not always needed but innocuous
        default:
             baseURL = "https://api.openai.com/v1/chat/completions"
        }
        
        AIContentService.logDebug("[generateRaw] Starting request to \(baseURL) with model: \(model)")
        
        guard let url = URL(string: baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        for (k, v) in headers { request.addValue(v, forHTTPHeaderField: k) }
        
        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        AIContentService.logDebug("[generateRaw] Request built, sending via session...")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                AIContentService.logDebug("[generateRaw] ERROR: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let data = data else {
                AIContentService.logDebug("[generateRaw] ERROR: No data received")
                completion(.failure(AIError.invalidResponse))
                return
            }
            
            AIContentService.logDebug("[generateRaw] Response received: \(data.count) bytes")
            if let str = String(data: data, encoding: .utf8) { 
                print("Raw API: \(str.prefix(500))...") 
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                     // Check Error
                     if let errorObj = json["error"] as? [String: Any], let msg = errorObj["message"] as? String {
                         completion(.failure(AIError.apiError(msg)))
                         return
                     }
                     if let msg = json["error"] as? String { // Ollama simple error
                          completion(.failure(AIError.apiError(msg)))
                          return
                     }
                    
                     if let choices = json["choices"] as? [[String: Any]],
                        let first = choices.first,
                        let message = first["message"] as? [String: Any],
                        let content = message["content"] as? String {
                         completion(.success(content))
                     } else {
                         completion(.failure(AIError.apiError("No content in response")))
                     }
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func generateAnthropic(prompt: String, system: String, apiKey: String, model: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        let body: [String: Any] = [
            "model": model,
            "max_tokens": 4096,
            "system": system,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        session.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(AIError.invalidResponse)); return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let type = json["type"] as? String, type == "error" {
                        if let errObj = json["error"] as? [String: Any], let msg = errObj["message"] as? String {
                            completion(.failure(AIError.apiError(msg)))
                            return
                        }
                    }
                    
                    if let contentArr = json["content"] as? [[String: Any]],
                       let first = contentArr.first,
                       let text = first["text"] as? String {
                        completion(.success(text))
                    } else {
                        completion(.failure(AIError.apiError("Invalid Anthropic Response")))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Image Generation (DALL-E 3)
    
    func generateImage(prompt: String, size: String = "1024x1024", apiKey: String, completion: @escaping (Result<String, Error>) -> Void) {
        let isOpenRouter = apiKey.hasPrefix("sk-or-")
        let urlString = isOpenRouter ? "https://openrouter.ai/api/v1/images/generations" : "https://api.openai.com/v1/images/generations"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if isOpenRouter {
            request.addValue("https://macdiskfull.com", forHTTPHeaderField: "HTTP-Referer") // Required by OpenRouter
            request.addValue("WebMakr", forHTTPHeaderField: "X-Title")
        }
        
        // DALL-E 3 Request
        // OpenRouter requires 'openai/dall-e-3', OpenAI requires 'dall-e-3'
        let model = isOpenRouter ? "openai/dall-e-3" : "dall-e-3"
        
        let body: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "n": 1,
            "size": size,
            "quality": "standard", // or "hd"
            "response_format": "url"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("🎨 [DALL-E] Generating: \(prompt.prefix(50))...")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(AIError.invalidResponse)); return }
            
            // DEBUG: Print raw response
            if let rawString = String(data: data, encoding: .utf8) {
                print("🎨 [DALL-E/OpenRouter] Raw Response: \(rawString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let errorObj = json["error"] as? [String: Any], let msg = errorObj["message"] as? String {
                        completion(.failure(AIError.apiError(msg)))
                        return
                    }
                    
                    if let dataArr = json["data"] as? [[String: Any]],
                       let first = dataArr.first,
                       let urlStr = first["url"] as? String {
                        completion(.success(urlStr))
                    } else {
                        // Check for OpenRouter specific error format if OpenAI format failed
                        print("🎨 [DALL-E/OpenRouter] Unexpected JSON structure: \(json)")
                        completion(.failure(AIError.apiError("No image URL in response")))
                    }
                }
            } catch {
                print("🎨 [DALL-E/OpenRouter] JSON Parse Error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}

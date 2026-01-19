# Technical Debt & TODOs

## Pending Features
- [ ] **Automatic YouTube Transcript Fetching**:
  - Current Status: Blocked by macOS App Sandbox (Network permission for `URLSession` to `timedtext` endpoints is flaky or blocked by YouTube signatures).
  - Failed Approaches: Python script (Sandbox exec deny), Native Swift Regex (0-byte response from YouTube).
  - Next Steps: Consider using `WKWebView` (Headless) to fetch content as a browser, or move this logic to a backend server.

- [ ] **Image Preview & Retry**:
  - Feature Request: In Image Assistant, allow user to preview 3-4 variations before selecting one to replace the placeholder.
  - Currently: Generates 1 and replaces immediately.
  - Future: Add "Preview Reel" or "Retry" button before committing to HTML.

- [ ] **Site-Wide Scaffolding Awareness**:
  - Goal: AI should understand the full site structure, not just individual articles.
  - Features: Automatic internal linking between related articles, content cluster suggestions, and ensuring new content fits the navigational hierarchy.
  
## Current Focus
- Manual Article Creation: User provides high-quality source text, AI formats it.

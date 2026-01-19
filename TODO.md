# Technical Debt & TODOs

## Pending Features
- [ ] **Automatic YouTube Transcript Fetching**:
  - Current Status: Blocked by macOS App Sandbox (Network permission for `URLSession` to `timedtext` endpoints is flaky or blocked by YouTube signatures).
  - Failed Approaches: Python script (Sandbox exec deny), Native Swift Regex (0-byte response from YouTube).
  - Next Steps: Consider using `WKWebView` (Headless) to fetch content as a browser, or move this logic to a backend server.

## Current Focus
- Manual Article Creation: User provides high-quality source text, AI formats it.

#!/usr/bin/env python3
import sys, json, re
from urllib.parse import urlparse, parse_qs

# Try importing. If missing, print JSON error so Swift can capture it.
try:
    from youtube_transcript_api import YouTubeTranscriptApi, TranscriptsDisabled, NoTranscriptFound
except ImportError:
    print(json.dumps({"error": "Missing library. Run: pip3 install youtube-transcript-api"}), file=sys.stdout)
    sys.exit(0)

def video_id_from_url(url: str) -> str:
    u = url.strip()
    p = urlparse(u)
    if p.netloc in ("youtu.be", "www.youtu.be"):
        return p.path.strip("/").split("/")[0]
    if p.netloc.endswith("youtube.com"):
        if p.path == "/watch":
            q = parse_qs(p.query)
            return (q.get("v") or [""])[0]
        m = re.match(r"^/(shorts|embed)/([^/?#]+)", p.path)
        if m: return m.group(2)
    if re.fullmatch(r"[A-Za-z0-9_-]{11}", u): return u
    return ""

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "No URL provided"}), file=sys.stdout)
        sys.exit(0)

    url = sys.argv[1]
    vid = video_id_from_url(url)
    
    if not vid:
        print(json.dumps({"error": "Invalid Video ID"}), file=sys.stdout)
        sys.exit(0)

    try:
        # 1. Fetch available transcripts list
        transcript_list = YouTubeTranscriptApi.list_transcripts(vid)
        
        # 2. Smart Logic: Prefer English (Manual > Auto), else Translate
        try:
            transcript = transcript_list.find_manually_created_transcript(['en', 'en-US', 'en-GB'])
        except:
            try:
                transcript = transcript_list.find_generated_transcript(['en', 'en-US', 'en-GB'])
            except:
                # Fallback: Get ANY transcript and translate to English
                try:
                    first_available = next(iter(transcript_list))
                    transcript = first_available.translate('en')
                except:
                     raise Exception("No adaptable transcript found.")

        # 3. Fetch the actual text
        data = transcript.fetch()
        
        # 4. Format
        text_content = " ".join([x['text'].replace("\n", " ") for x in data])
        
        print(json.dumps({
            "video_id": vid,
            "text": text_content,
            "language": transcript.language_code,
            "is_generated": transcript.is_generated
        }, ensure_ascii=False))

    except Exception as e:
        print(json.dumps({"error": str(e)}), file=sys.stdout)

if __name__ == "__main__":
    main()

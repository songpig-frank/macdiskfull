#!/usr/bin/env python3
import sys, json, re
from urllib.parse import urlparse, parse_qs
from youtube_transcript_api import YouTubeTranscriptApi
from youtube_transcript_api._errors import (
    TranscriptsDisabled, NoTranscriptFound, VideoUnavailable, TooManyRequests
)

def video_id_from_url(url: str) -> str:
    u = url.strip()
    p = urlparse(u)

    if p.netloc in ("youtu.be", "www.youtu.be"):
        vid = p.path.strip("/").split("/")[0]
        if vid: return vid

    if p.netloc.endswith("youtube.com"):
        if p.path == "/watch":
            q = parse_qs(p.query)
            vid = (q.get("v") or [""])[0]
            if vid: return vid
        m = re.match(r"^/(shorts|embed)/([^/?#]+)", p.path)
        if m: return m.group(2)

    if re.fullmatch(r"[A-Za-z0-9_-]{11}", u):
        return u

    raise ValueError("Could not extract YouTube video id from URL")

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Missing URL"}), file=sys.stdout)
        sys.exit(1)

    url_or_id = sys.argv[1]
    preferred_lang = sys.argv[2] if len(sys.argv) >= 3 else "en"

    try:
        vid = video_id_from_url(url_or_id)
        
        try:
            items = YouTubeTranscriptApi.get_transcript(vid, languages=[preferred_lang])
        except NoTranscriptFound:
            items = YouTubeTranscriptApi.get_transcript(vid)

        text = " ".join([x.get("text","").replace("\n"," ").strip() for x in items]).strip()

        print(json.dumps({
            "video_id": vid,
            "text": text
        }, ensure_ascii=False))
        
    except Exception as e:
        print(json.dumps({
            "error": str(e)
        }, ensure_ascii=False))
        sys.exit(1)

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
import sys, json, re
from youtubesearchpython import VideosSearch
try:
    from youtube_transcript_api import YouTubeTranscriptApi, TranscriptsDisabled, NoTranscriptFound
except ImportError:
    pass

def check_transcript_exists(video_id):
    try:
        # Just check list, don't fetch full text yet (speed)
        # 0.6.2 method
        YouTubeTranscriptApi.list_transcripts(video_id)
        return True
    except:
        return False

def parse_views(view_text):
    # "1.2M views", "500K views", "10 views"
    if not view_text: return 0
    t = view_text.lower().replace(" views", "").replace(" view", "")
    multiplier = 1
    if "k" in t:
        multiplier = 1000
        t = t.replace("k", "")
    elif "m" in t:
        multiplier = 1000000
        t = t.replace("m", "")
    elif "b" in t:
        multiplier = 1000000000
        t = t.replace("b", "")
    
    try:
        return int(float(t) * multiplier)
    except:
        return 0

def score_video(video, topic_is_timeless=False):
    # Recency Parsing (Rough heuristic)
    pub = video.get('publishedTime', '').lower()
    days_old = 365 # Default
    
    if 'hour' in pub or 'minute' in pub: days_old = 0
    elif 'day' in pub:
        try:
            days_old = int(re.search(r'\d+', pub).group())
        except: days_old = 1
    elif 'week' in pub:
        try:
            days_old = int(re.search(r'\d+', pub).group()) * 7
        except: days_old = 7
    elif 'month' in pub:
        try:
            days_old = int(re.search(r'\d+', pub).group()) * 30
        except: days_old = 30
    elif 'year' in pub:
        try:
            days_old = int(re.search(r'\d+', pub).group()) * 365
        except: days_old = 365
    
    views = parse_views(video.get('viewCount', {}).get('text', ''))
    
    # Scoring Algorithm
    # If topic is not timeless (e.g. tech news), punish age heavily.
    # Score = Views / (DaysOld + 1)
    
    if days_old == 0: days_old = 0.5 # Boost very fresh
    
    score = views / (days_old + 1)
    
    return score

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "No query"}), file=sys.stdout)
        sys.exit(0)
        
    query = sys.argv[1]
    
    # Search for 15 videos
    videosSearch = VideosSearch(query, limit=15)
    results = videosSearch.result()
    
    candidates = []
    
    for video in results.get('result', []):
        vid = video.get('id')
        title = video.get('title')
        
        # Transcript Check
        has_transcript = check_transcript_exists(vid)
        
        if has_transcript:
            candidates.append({
                "id": vid,
                "title": title,
                "channel": video.get('channel', {}).get('name'),
                "views": video.get('viewCount', {}).get('text'),
                "published": video.get('publishedTime'),
                "score": score_video(video),
                "url": video.get('link')
            })
            
    # If no verified candidates found, return raw results (fallback) so user sees SOMETHING
    if not candidates:
        for video in results.get('result', [])[:5]:
             candidates.append({
                "id": video.get('id'),
                "title": video.get('title') + " (Unverified)",
                "channel": video.get('channel', {}).get('name'),
                "views": video.get('viewCount', {}).get('text'),
                "published": video.get('publishedTime'),
                "score": 0,
                "url": video.get('link')
            })
    
    print(json.dumps(candidates[:5], ensure_ascii=False))

if __name__ == "__main__":
    main()

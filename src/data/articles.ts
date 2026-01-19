export interface Article {
    id: string;
    slug: string;
    title: string;
    excerpt: string;
    content: string;
    date: string;
    author: string;
    coverImage?: string;
}

export const articles: Article[] = [
    {
        id: 'mac-disk-full-do-this-first',
        slug: 'mac-disk-full-do-this-first',
        title: 'Mac Disk Full? Do This First (Fast Checklist That Works)',
        excerpt: 'If your Mac says “Your disk is almost full,” don’t panic. This guide gives you a safe “do this first” process to reclaim space quickly without breaking anything.',
        date: '2026-01-19',
        author: 'MacDiskFull Team',
        content: `
# Mac Disk Full? Do This First (Fast Checklist That Works)

*Last updated: January 2026*

If your Mac says “Your disk is almost full,” don’t panic and don’t start randomly deleting things. The fastest way to fix a full drive is to follow a short checklist in the right order—so you reclaim space quickly *without breaking anything important*.

This guide gives you a safe “do this first” process. Most people can free up space in 10–30 minutes, even if they’re not techy.

*Disclosure: Some links may be affiliate links. If you buy through them, we may earn a commission at no extra cost to you.*

---

## The 60-second plan (do these in order)

1. Check what’s actually using space (built-in Storage view)  
2. Empty Trash (and delete old installers)  
3. Clear the biggest easy wins (Downloads, videos, DMGs, ZIPs)  
4. Find and remove large files *safely* (preview-first)  
5. If you’re still tight: deal with “System Data” and pro-app caches  
6. Move large libraries to an external drive (optional)  

Then, if you want to make this easier next time, use a *visual* disk cleanup tool that helps you spot the junk faster than Finder.

---

## Step 1: Confirm how much space you actually have

Before deleting anything, check your current free space so you know what “success” looks like.

### macOS Ventura / Sonoma / Sequoia (modern macOS)
1. Open *System Settings*  
2. Click *General*  
3. Click *Storage*

You’ll see categories like Applications, Documents, Photos, System Data, etc.

### Older macOS
1. Click the Apple menu   
2. Choose *About This Mac*  
3. Click *Storage*

*Goal:* If you can get back to at least **15–25 GB free**, your Mac will behave better (updates, swaps, performance).

---

## Step 2: Empty Trash (and remove the “fake deletes”)

This is obvious, but it matters: moving files to Trash doesn’t free space until you empty it.

1. Right-click *Trash* (Dock)  
2. Click *Empty Trash*

Now do this too (it’s the hidden “why is my disk still full?” issue):

### Delete big installers you don’t need
Common space hogs:
- \`.dmg\` installer files (apps you already installed)
- \`.pkg\` installers
- \`.zip\` archives
- iOS firmware files you downloaded
- old “Photos Library copy” files

Where they usually live:
- *Downloads*
- *Desktop*
- random folders named “Installers”

*Tip:* If you see a DMG you installed weeks ago, you can usually delete it.

---

## Step 3: Clear the biggest “easy win” folders first

These are the places that fill up on almost every Mac:

### A) Downloads
Open Finder → *Downloads*  
Then sort by size:

1. In Finder, open *Downloads*  
2. Click the “list view” icon (four lines)  
3. Choose *View → Show View Options*  
4. Turn on *Calculate all sizes* (if available)  
5. Click the *Size* column to sort

Delete:
- old DMGs / ZIPs
- videos you no longer need
- duplicates (“file (1).zip”, “file (2).zip”)

### B) Desktop
People forget the Desktop counts as real storage.  
Remove:
- duplicate images
- screen recordings
- old work exports
- long ZIPs and DMGs

### C) Your Movies folder (especially screen recordings)
Finder → *Movies*  
Look for:
- Screen recordings
- Old exports from video editors
- Huge clips you already uploaded

### D) Messages attachments (if you get lots of photos/videos)
This can get huge. In Storage, look for “Messages” if it appears and review attachments.

---

## Step 4: Find large files safely (without deleting system stuff)

If your Mac is truly full, you need to locate the largest files and confirm what they are before deleting.

### The safe method (Finder search)
1. Open Finder  
2. Press \`Command + F\`  
3. Set search to “This Mac”  
4. Add a filter like *File Size is greater than 500 MB* (or 1 GB)

Then review large items one by one.

*What to delete safely:*
- Old exported videos you don’t need
- Duplicate downloads
- Old installers (DMG/PKG)
- ISO files
- Old project exports you already backed up

*What NOT to delete if you’re not sure:*
- Anything in *System* folders
- Random folders you don’t recognize inside Library
- Anything labeled as macOS-related

If you’re unsure, move it to a “To Review” folder first instead of deleting.

---

## Step 5: The big culprits most people miss

These categories are where space mysteriously disappears.

### A) “System Data” is huge
System Data includes caches, logs, app support files, and more. It’s not all “bad”—but it can grow out of control.

If System Data is huge:
- Restart your Mac (yes, really)
- Empty Trash
- Clear obvious app caches (see below)
- Remove old iPhone backups (if you have them)
- For creators: clear pro-app caches carefully

### B) iPhone / iPad backups
If you back up devices locally, backups can take 5–50 GB each.

Where to check:
- Finder → click your iPhone in the sidebar → Manage Backups (varies by macOS)
- Or search for “Backup” in Storage recommendations

### C) Photo library and duplicates
Photos can be massive. If you use iCloud Photos, your Mac may still store a lot locally.

A simple choice:
- If your library is huge and you trust iCloud, set Photos to *Optimize Mac Storage*.

### D) Pro apps (video and audio) cache files
If you edit video or record audio, cache files can balloon quickly.

Typical offenders:
- Video editor render files and cache
- Proxy media
- Audio sample libraries (very large)
- DAW project duplicates

If you’re a creator and you’re constantly full, skip ahead to the “Creator quick wins” section below.

---

## Step 6: Creator quick wins (Final Cut, DaVinci, Premiere, Logic, plugins)

If you do audio/video work, your SSD gets eaten by “invisible” files.

### Video editing: common space hogs
- Render files
- Cache files
- Proxy media
- Optimized media
- Old project exports

*Safe idea:* Clear cache inside the app’s settings (preferred) rather than digging through Library folders manually.

### Audio production: common space hogs
- Sample libraries
- Plugin installers
- Project backups
- Bounce/export folders
- Duplicate takes

*Best practice:* Put sample libraries on an external SSD and keep only active projects on the internal drive.

---

## Step 7: Move large libraries to an external drive (the long-term fix)

If your Mac has a small internal drive, cleanup alone may not be enough long-term.

Good candidates to move:
- Photos Library (advanced users only; do carefully)
- iMovie / Final Cut Libraries
- DAW sample libraries
- Large video project folders
- Old archives

Use a fast external SSD for best results.

*Important:* Don’t move random system folders. Stick to your own files and libraries.

---

## When Finder feels too slow: use a visual cleanup tool (optional)

Finder works, but it can be slow and tedious when you’re stressed and low on space. A good visual disk tool can help you:

- see big files instantly
- find duplicates and junk faster
- safely preview what you’re deleting
- avoid deleting the wrong thing

If you want a *no-subscription* option, GetDiskSpace is designed for quick “what is taking space?” answers plus a preview-first cleanup flow. (Disclosure: we may earn a commission if you purchase through our link.)

*Important:* Whatever tool you use, the key is *preview-first* and *non-destructive workflows*.

---

## Quick checklist you can bookmark

When your Mac is full, do this:

- [ ] Check Storage (see biggest category)  
- [ ] Empty Trash  
- [ ] Delete old DMGs/ZIPs in Downloads  
- [ ] Delete large screen recordings and exports  
- [ ] Finder search: files bigger than 500MB and review  
- [ ] Review iPhone backups  
- [ ] Clear pro-app caches (inside the app if possible)  
- [ ] Move large libraries to external SSD  

---

## FAQ

### How much free space should a Mac have?
Try to keep at least **15–25 GB free**, more if you do video/audio work.

### Why does my Mac say “disk full” but I already deleted stuff?
Because Trash wasn’t emptied, large files are still sitting in Downloads, or “System Data”/caches/backups are still huge.

### Should I delete System files?
No. If you’re unsure, don’t delete it. Focus on your own files first: downloads, videos, backups, caches managed by apps.

### Is it safe to delete DMG files?
Usually yes—after the app is installed, the DMG is just an installer copy.
`
    }
];

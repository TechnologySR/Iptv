# Iptv

This repository contains an M3U(HLS) playlist exported from the previous README.md.

What's changed
- The playlist content was moved from README.md into a proper playlist file: `playlist.m3u`
- This README explains the repo layout and how to use the playlist
- A basic GitHub Actions workflow to validate the playlist file on push
- A CONTRIBUTING.md and .gitignore were added for contributors

Usage
1. Open `playlist.m3u` with a compatible player (VLC, mpv, Kodi, etc.)
2. Or use the raw file URL once pushed: 

Notes
- Minimal normalization: moved the existing playlist content into `playlist.m3u` and removed the top-level repo title.
- I did not add a license (per your request).
- Some streams may be geo-blocked or offline. If you want, I can run a validation step to check which URLs return a 200/OK.

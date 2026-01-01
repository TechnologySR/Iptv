#!/usr/bin/env bash
set -euo pipefail

# Edit these if you want different branch names or source URLs
TARGET_REPO="https://github.com/TechnologySR/Iptv.git"
SOURCE_README_RAW="https://raw.githubusercontent.com/TechnologySR/M3U_Playlist/refs/heads/main/README.md"
BRANCH="tidy-playlist"
TMPDIR="$(mktemp -d)"
echo "Working in $TMPDIR"
cd "$TMPDIR"

# Clone target repo and create branch
git clone "$TARGET_REPO"
cd Iptv
git checkout -b "$BRANCH"

# Download source README (contains your raw playlist)
curl -fsSL "$SOURCE_README_RAW" -o /tmp/source_README.md

if ! grep -q "^#EXTM3U" /tmp/source_README.md; then
  echo "No #EXTM3U found in source README. Aborting." >&2
  exit 1
fi

# Extract from first #EXTM3U to end into playlist.m3u
awk 'BEGIN{p=0} /^#EXTM3U/{p=1} p{print}' /tmp/source_README.md > playlist.m3u

# Create tidy README (or preserve pre-playlist preamble if present)
# If you want to include a pre-playlist preamble from the source README, uncomment block below:
# csplit -z /tmp/source_README.md '/^#EXTM3U/' >/dev/null 2>&1 || true
# if [ -f xx00 ] && [ -s xx00 ]; then
#   cp xx00 README.md
#   sed -i '1s/^/# M3U_Playlist\n\nThis repository contains an M3U(HLS) playlist exported from the previous README.md.\n\n/' README.md
# else
cat > README.md <<'EOF'
# Iptv

This repository contains an M3U(HLS) playlist imported from TechnologySR/M3U_Playlist.

What's included
- playlist.m3u — the M3U/HLS playlist (extracted from the original README)
- A tidy README explaining usage
- CONTRIBUTING.md and .gitignore
- A small GitHub Actions workflow to validate the playlist header

Usage
1. Open `playlist.m3u` with a compatible player (VLC, mpv, Kodi, etc.)
2. Raw file URL (after push): https://raw.githubusercontent.com/TechnologySR/Iptv/tidy-playlist/playlist.m3u

Notes
- The playlist was moved verbatim into playlist.m3u. No aggressive deduplication or availability checks were performed.
- No license file was added (per request).
EOF
# fi

# Other files
cat > .gitignore <<'EOF'
# Ignore typical system files
.DS_Store
*.log
node_modules/
EOF

cat > CONTRIBUTING.md <<'EOF'
## Contributing

- To update the playlist: modify `playlist.m3u` or open an issue describing changes.
- Please keep `#EXTINF` and URL pairs together (metadata line followed by the URL).
- For large changes (formatting, de-duplication), open a branch and submit a PR.
EOF

mkdir -p .github/workflows
cat > .github/workflows/validate-playlist.yml <<'EOF'
name: Validate playlist
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check playlist header
        run: |
          if ! grep -q "^#EXTM3U" playlist.m3u; then
            echo "playlist.m3u missing #EXTM3U header" >&2
            exit 1
          fi
          echo "playlist.m3u header OK"
EOF

# Stage, commit and push
git add README.md playlist.m3u .gitignore CONTRIBUTING.md .github/workflows/validate-playlist.yml
git commit -m "Extract playlist into playlist.m3u; add README, CONTRIBUTING, .gitignore, and validation workflow"
git push -u origin "$BRANCH"

# Create PR if gh cli available
if command -v gh >/dev/null 2>&1; then
  gh pr create --title "Move playlist into playlist.m3u and tidy repository" \
    --body "This PR extracts the M3U playlist into playlist.m3u, adds a README, CONTRIBUTING.md, .gitignore, and a workflow to validate the playlist header. No license was added." \
    --base main --head "$BRANCH"
  echo "PR created (if gh was authenticated)."
else
  echo "Branch pushed: $BRANCH"
  echo "Open a PR at: https://github.com/TechnologySR/Iptv/compare/main...$BRANCH"
fi

echo "Done. The tidy branch has been pushed."

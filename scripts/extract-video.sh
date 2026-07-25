#!/usr/bin/env bash
# extract-video.sh — pull caption + transcript text from a cooking video URL.
# Used by meal-prep-discovery skill to get recipe content from TikTok/reels/YouTube.
# yt-dlp v2026.07.04 installed. Output = stdout; stage results in video-inbox/.
#
# Usage: bash extract-video.sh "https://www.tiktok.com/@user/video/123"
#   optional 2nd arg: extra yt-dlp flags
set -euo pipefail

URL="${1:-}"
[ -z "$URL" ] && { echo "usage: $0 <video-url>" >&2; exit 1; }

if ! command -v yt-dlp >/dev/null 2>&1; then
  echo "[extract-video] yt-dlp not installed." >&2
  echo "[extract-video] Install with:  brew install yt-dlp" >&2
  echo "[extract-video] (ffmpeg already present — good.)" >&2
  exit 2
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ponytail: prefer auto-subs (TikTok/IG auto-captions), fall back to manual subs,
# then to a quiet info dump. Never download the video body — we only want text.
echo "=== SOURCE ==="
echo "$URL"
echo
echo "=== TITLE ==="
yt-dlp --skip-download --print "%(title)s" "$URL" 2>/dev/null || echo "(no title)"
echo
echo "=== DESCRIPTION/CAPTION ==="
yt-dlp --skip-download --print "%(description)s" "$URL" 2>/dev/null || echo "(no description)"
echo

echo "=== TRANSCRIPT (auto-subs, cleaned) ==="
# Try auto subs first (vtt), then manual. Strip timestamps/tags, collapse blank lines.
if yt-dlp --skip-download --write-auto-subs --sub-format vtt --convert-subs vtt \
     -o "$TMP/sub" "${2:-}" "$URL" 2>/dev/null && [ -f "$TMP/sub.en.vtt" ]; then
  sub="$TMP/sub.en.vtt"
elif yt-dlp --skip-download --write-subs --sub-format vtt --convert-subs vtt \
     -o "$TMP/sub" "${2:-}" "$URL" 2>/dev/null && [ -f "$TMP/sub.en.vtt" ]; then
  sub="$TMP/sub.en.vtt"
else
  echo "(no captions available — ask user for a recipe page URL from the caption)" >&2
  exit 3
fi

# Clean VTT: drop header/timestamp/tags, dedupe adjacent lines, drop blank runs.
sed -e '1,/WEBVTT/d' -e 's/<[^>]*>//g' "$sub" \
  | grep -vE '^[0-9]{2}:[0-9]{2}\.[0-9]{3} -->|^[[:space:]]*$|^NOTE' \
  | awk '!seen[$0]++' \
  | sed '/^$/N;/^\n$/D'

# Video Inbox

Drop cooking-video links here (TikTok / Reels / YouTube Shorts). Each file is a **staging record**: URL + extracted transcript + status, promoted to a real recipe card in `../recipes/` once scored.

## Flow
1. **Capture** — run `../scripts/extract-video.sh "<url>"` and save output here, OR the skill writes here when you paste a link. Filename: `<YYYY-MM-DD>-<slug>.md`.
2. **Extract** — the skill parses transcript → fills the "Extracted recipe" block (ingredients, steps, yield).
3. **Promote** — skill scores it against the rubric and, if it passes, writes a scaled card to `../recipes/<date>-<slug>.md` and flips `status: promoted`. If it fails scoring, `status: rejected` with a one-line reason.

## Status values
- `pending` — URL captured, transcript not yet pulled
- `extracted` — transcript + recipe parsed, not yet scored
- `promoted` — scored and accepted → card exists in `../recipes/`
- `rejected` — failed rubric (note why)

Files here are the **queue**, not the library. `../recipes/` is the library.

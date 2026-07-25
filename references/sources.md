# Sources

How to pull candidates from each channel. Fan out independent fetches in parallel.

## 1. RSS feeds
`web_fetch` each URL with `format=raw`. Parse the `<item>` blocks for `title`, `link`, `category`. Most are WordPress `/feed/` and return clean RSS XML. Skim titles+categories for meal-prep / freezer / batch signals, then fetch the promising pages as markdown.

Curated list (meal-prep + freezer-friendly leaning):

```
https://www.budgetbytes.com/feed/
https://www.ambitiouskitchen.com/feed/
https://www.tasteofhome.com/feed/
https://www.allrecipes.com/feed/
https://www.seriouseats.com/feed
https://cookieandkate.com/feed/
https://www.minimalistbaker.com/feed/
https://www.simplyrecipes.com/feeds/full.rss
https://www.halfbakedharvest.com/feed/
https://www.skinnytaste.com/feed/
https://www.wellplated.com/feed/
https://theclevermeal.com/feed/
https://www.recipetineats.com/feed/
https://www.loveandlemons.com/feed/
```

Add/remove feeds here as you learn what the user likes. Ponytail: WordPress `/feed/` is the universal default — try appending it to any new food blog.

## 2. Web search
`web_search` with these query templates (swap in cuisines from the user's prefs):

```
site:tasteofhome.com freezer meal prep reheat
site:allrecipes.com meal prep freezer friendly
site:ambitiouskitchen.com freezer meal
"meal prep" reheat freezer {cuisine} recipe
best freezer meals that reheat well {protein}
easy batch cook {cuisine} 10 servings
slow cooker meal prep freezer friendly
sheet pan meal prep reheats well
```

Prefer results from: Taste of Home, Allrecipes, Ambitious Kitchen, Serious Eats, Budget Bytes, Cookie and Kate, Half Baked Harvest, Skinnytaste. These publish real yields + reheat notes.

## 3. Video (TikTok / Instagram Reel / YouTube Short)
**Do not** `web_fetch` extractor sites (reeltomeal, recipeextractor, cooking.guru) — they're JS-rendered, you'll get a blank shell.

Use the local transcript path:
```bash
bash "$(dirname "$SKILL_PATH")/scripts/extract-video.sh" "https://www.tiktok.com/@user/video/123"
```
Returns caption + auto-subtitle transcript to stdout. **Stage every video URL in `../video-inbox/`** (see `templates/video-staging.md`) so links don't get lost — fill the transcript + extracted-recipe blocks, set `status: extracted`, then score. If it passes the rubric, promote to a card in `../recipes/` and set `status: promoted`. If no usable captions, fall back to asking the user for a blog/recipe page URL from the caption and set `status: rejected`.

**yt-dlp installed** (v2026.07.04). Script works out of the box.

## 4. Recipe MCP server (optional, powerful)
The npm package `recipe-mcp` (v1.1.2) is a universal recipe MCP — 12 sources, 32 tools, 25+ food blogs, dietary adaptation, cook mode, pantry tracking. Run it via npx; no global install.

**One-time setup** (user-gated — ask before adding an MCP server):
1. Confirm Node 18+: `node -v`
2. Add to pi MCP config (or run standalone):
   ```jsonc
   {
     "mcpServers": {
       "recipe": {
         "command": "npx",
         "args": ["-y", "recipe-mcp"]
       }
     }
   }
   ```
3. Restart pi so the `recipe` server connects.
4. Verify: `mcp()` lists `recipe` server; `mcp({ server: "recipe" })` lists its tools.

**Status: configured, pending pi restart.** Added to `~/.claude.json` as server `recipes` (`npx -y -p recipe-mcp recipe-mcp-server`). Free tier: blog search (25+ food blogs — Half Baked Harvest, Budget Bytes, Skinnytaste, Smitten Kitchen, Pinch of Yum, …), extract-from-URL, TheMealDB, RecipePuppy. Plus tier ($8/yr) adds NYT/Spoonacular/Tasty/Instagram — not needed yet.

Once connected (after restart), prefer its search/browse tools for sourcing — they're structured (yields, tags, dietary filters) and save the web_fetch round-trips. Fall back to RSS/web if it's not installed.

## Source priority when all available
1. If user gave a URL → extract that only.
2. Recipe MCP (if connected) — structured, fastest.
3. RSS feeds — fresh, real-blog quality.
4. Web search — fills gaps / targets a specific cuisine.
5. Video transcript — only when user hands you a video.

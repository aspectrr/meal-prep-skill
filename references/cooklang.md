# CookLang Format

CookLang is a plain-text recipe format. A `.cook` file is human-readable and parseable by the `cook` CLI (for scaling + shopping lists). Write one when the user wants "both" formats or will cook a recipe often.

## Syntax cheat sheet

```
>> Recipe Title

A simple beef chili that scales up beautifully and reheats better on day 3.

= Beef Chili

& serves 10

? Dutch oven or large pot

@ ground beef{3%kg}
@ onion{2}, diced
@ garlic{4 cloves}, minced
@ canned diced tomato{2 cans}
@ kidney bean{2 cans}, drained
@ beef broth{500%ml}
@ chili powder{3%tbsp}
@ cumin{2%tbsp}
@ salt{1%tsp}

Brown the ground beef over medium-high heat until no pink remains. ~{5%minutes}
Add the onion and garlic and cook until softened. ~{5%minutes}
Stir in the tomatoes, beans, broth, and spices. Bring to a boil.
Reduce to a simmer, cover, and cook until thickened. ~{30%minutes}
Taste and adjust salt. 
```

## Tokens
| Symbol | Meaning | Example |
|---|---|---|
| `>>` | metadata line | `>> source: https://...` |
| `=` | recipe title | `= Beef Chili` |
| `&` | metadata key:value | `& serves 10` |
| `?` | cookware | `? Dutch oven` |
| `@` | ingredient | `@ onion{2}, diced` |
| `~{...}` | timer | `~{30%minutes}` |
| `{n%unit}` | quantity with unit | `{3%kg}`, `{500%ml}` |

## Scaling with the cook CLI (optional)
If `cook` is installed:
```bash
cook recipe "Beef Chili.cook"           # render
cook shopping-list "Beef Chili.cook"    # ingredient list
# cook scales servings via the & serves line / multiplier
```
Install: `brew install cooklang/cooklang/cook-cli` (user-gated).

## When to write .cook vs .md
- **.md always** — portable, no toolchain, your history.
- **.cook when**: user asked for both, OR a recipe scored ≥40/50 and will recur.
Keep `.cook` files next to the `.md` in `recipes/` with the same slug.

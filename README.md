# omnifocus-darkmode

A dark mode for **OmniFocus for the Web** (`https://web.omnifocus.com/`), delivered as a **[Stylus](https://github.com/openstyles/stylus)** userstyle.

OmniFocus for the Web has no native dark mode (it ignores `prefers-color-scheme` and always renders light), so this style adds one. The default palette is tuned to match the dark background of claude.ai (`#1f1e1e`).

## Why Stylus (and not a generic dark-mode extension)

This is **CSS only**. Stylus is a *style* manager: it **does not run JavaScript**, so the style has no network capability and **cannot read or exfiltrate your tasks** — the guarantee is structural, not a promise. Stylus is also open source (GPLv3) and was created as a telemetry-free fork of "Stylish". For sensitive data like your tasks, it's the most defensible option. All the code lives here, versioned and auditable.

## Installation

1. Install **[Stylus](https://github.com/openstyles/stylus)** from your browser's store.
   > Make sure it's **Stylus** (by `openstyles`), **not** "Stylish" (the original, which shipped telemetry).
2. Open the style to install it:
   [`omnifocus-dark.user.css`](https://raw.githubusercontent.com/meconecto/omnifocus-darkmode/main/omnifocus-dark.user.css)
   Stylus detects the UserCSS format and offers to install it (with auto-update).
3. Go to <https://web.omnifocus.com/>. It should be dark.

**Manual alternative (no auto-update):** in the Stylus dashboard → **"Write new style"** → paste the contents of [`omnifocus-dark.user.css`](omnifocus-dark.user.css) → **Save**.

> **Note on Brave/Chrome (Manifest V3):** since Chromium removed Manifest V2, the stable build of the Violentmonkey *userscript* manager no longer installs on Brave. Stylus is unaffected — it has a Manifest V3 build in the Chrome Web Store and installs cleanly.

## How it works

OmniFocus for the Web uses hashed CSS classes (styled-components) that change on
every build, so targeting specific selectors breaks often. To get a robust dark
mode that does **not** depend on those classes, the style **inverts the whole page
and rotates the hue by 180°** (so colors — tags, flags, links — keep their hue
instead of looking like a photo negative), then **re-inverts images, video and
icons** so they render normally.

### The key idea

Because **everything is inverted**, to make something look **dark** you must give it
a **light** color (the `invert()` turns it dark). This drives a few non-obvious
choices in the CSS:

- The page background is `#fff` — it inverts to near-black, seamlessly matching the
  app's own white content (which inverts the same way). Using a dark value here is a
  classic trap: it would invert to *light gray* and paint a bright frame around the
  content.
- `color-scheme` is `light` (not `dark`): this makes the browser paint native form
  controls (inputs, textareas) light, so the inversion turns them dark. With `dark`
  they were painted dark and the invert flipped them into bright white boxes.
- Scrollbars are styled with light values via `::-webkit-scrollbar`, so the inversion
  renders them dark.

## Adjustments

Edit the variables in `:root` (in Stylus, changes apply on save):

- **`--of-darkness`** (default `0.88`): how dark it gets. `0.88` → background `#1f1f1f`,
  matching claude.ai's `#1f1e1e`. Higher = closer to pure black; lower = softer gray.
- **`--of-warmth`** (default `0`): background warmth via `sepia()`. `0` = neutral gray
  (like claude.ai). Raise it (~`0.04`) for a warm tone; too much also tints the
  accent colors and lowers contrast.
- **Counter-invert list**: the selectors that get re-inverted so they don't look like
  a negative. If some icon/image looks wrong, add or remove a selector.

## Limitations

- The inversion technique is broad by design; a specific detail may not be perfect.
  It can be fine-tuned with targeted overrides once the real (logged-in) DOM is
  inspected.
- Tested against OmniFocus 4 for the Web.

## License

[MIT](LICENSE)

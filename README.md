# omnifocus-darkmode

A dark mode for **OmniFocus for the Web** (`https://web.omnifocus.com/`), delivered as a **[Stylus](https://github.com/openstyles/stylus)** userstyle.

OmniFocus for the Web has no native dark mode (it ignores `prefers-color-scheme` and always renders light), so this style adds one. The default palette is tuned to match the dark background of claude.ai (`#1f1e1e`).

## Why Stylus (and not a generic dark-mode extension)

This is **CSS only**. Stylus is a *style* manager: it **does not run JavaScript**, so the style has no network capability and **cannot read or exfiltrate your tasks** — the guarantee is structural, not a promise. Stylus is also open source (GPLv3) and was created as a telemetry-free fork of "Stylish". For sensitive data like your tasks, it's the most defensible option. All the code lives here, versioned and auditable. The optional unpacked Chromium extension in `extension/` is the same CSS with no JavaScript — not a generic dark-mode tool.

## Installation

1. Install **[Stylus](https://github.com/openstyles/stylus)** from your browser's store.
   > Make sure it's **Stylus** (by `openstyles`), **not** "Stylish" (the original, which shipped telemetry).
2. Open the style to install it:
   [`omnifocus-dark.user.css`](https://raw.githubusercontent.com/meconecto/omnifocus-darkmode/main/omnifocus-dark.user.css)
   Stylus detects the UserCSS format and offers to install it (with auto-update).
3. Go to <https://web.omnifocus.com/>. It should be dark.

**Manual alternative (no auto-update):** in the Stylus dashboard → **"Write new style"** → paste the contents of [`omnifocus-dark.user.css`](omnifocus-dark.user.css) → **Save**.

### Local Chrome / Brave extension (optional, no Stylus)

Same CSS, no JavaScript: a Manifest V3 unpacked extension in [`extension/`](extension/). Stylus remains the primary install path (auto-update). Do **not** enable both at once — the page would be inverted twice.

1. Clone this repo (or download the `extension/` folder together with its generated CSS).
2. Open `chrome://extensions` or `brave://extensions`.
3. Turn on **Developer mode**.
4. **Load unpacked** → select the `extension/` directory.
5. Open <https://web.omnifocus.com/>.

Chrome will still warn that the extension can "read and change your data" on that site: the browser does not distinguish CSS-only injection. The package has no `.js`, no background worker, and no extra permissions — that is the actual guarantee, same idea as Stylus. After pulling CSS changes, run `bash scripts/sincronizar-extension.sh` and click **Reload** on the extension card.

Edit `--of-darkness` / `--of-warmth` in [`omnifocus-dark.user.css`](omnifocus-dark.user.css), then regenerate; do not edit `extension/omnifocus-dark.css` by hand.

> **Note on Brave/Chrome (Manifest V3):** since Chromium removed Manifest V2, the stable build of the Violentmonkey *userscript* manager no longer installs on Brave. Stylus is unaffected — it has a Manifest V3 build in the Chrome Web Store and installs cleanly. The unpacked extension above is a CSS-only adapter, not a userscript.

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

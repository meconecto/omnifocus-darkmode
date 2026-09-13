# Changelog

Versions refer to `@version` in `omnifocus-dark.user.css` — the value Stylus uses to
decide whether to auto-update an installed copy. Reconstructed from the git history on
2026-08-09; it only records what the commits show.

## Adapter — 2026-09-13

Not a Stylus `@version` bump (the userstyle is unchanged).

- Optional CSS-only Chromium extension in `extension/` for local unpacked install in
  Chrome/Brave. Same CSS as the userstyle; no JavaScript. Stylus remains the primary
  distribution. ([ADR 0004](docs/decisiones/0004-extension-chromium-local-solo-css.md))

## 1.3.2 — 2026-07-09

- `--of-darkness` back to `0.88`, calibrated so the background lands on `#1f1f1f`, matching
  claude.ai's measured `#1f1e1e`. (`34460ca`)

## 1.3.1 — 2026-07-09

- `--of-warmth` default to `0` (neutral gray): sharper, and it no longer tints the accent
  colors. (`3ca1329`)

## 1.3.0 — 2026-07-09

- New `--of-warmth` variable (`sepia()`) for a warm, claude.ai-like background; default
  `0.08`. (`fd60e11`)
- `--of-darkness` from `0.88` to `0.85`.

## 1.2.0 — 2026-07-09

- Dark page background and dark scrollbars: both are written with *light* values so the
  global inversion renders them dark. Fixes the bright frame around the content.
  (`81ec7ab`)
- `--of-darkness` from `0.92` to `0.88`.

## 1.1.0 — 2026-07-09

- `color-scheme: light` instead of `dark`, so the browser paints native form controls
  light and the inversion turns them dark. With `dark` they came out bright white.
  (`04f78ba`)
- Softer default darkness: `1` → `0.92`.

## 1.0.0 — 2026-07-09

- Migrated to Stylus (UserCSS) and removed the userscript version: a style manager runs no
  JavaScript, so the style cannot read or exfiltrate your tasks. (`06a9669`)

---

Before 1.0.0 the project shipped as a Violentmonkey userscript (`9cbb87a`, 2026-07-08).
It carried no `@version` of its own and was removed, not superseded.

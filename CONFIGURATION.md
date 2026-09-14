| Field       | Subfield     | Description                                                          |
| ----------- | ------------ | -------------------------------------------------------------------- |
| `paper`     | `width`      | Page width. Default `21cm`.                                          |
|             | `height`     | Page height. Default `width * sqrt(2)` (A4 height).                  |
| `margin`    | `t`, `f`     | Top / bottom margins.                                                |
|             | `e`, `s`     | Outer / inner margins.                                               |
| `side`      | `half-gutter`| Gap between the text body and margin sidenotes. Default `0.3cm`.     |
|             | `margin`     | Extra margin-side spacing. Default `s / 3`.                          |
| `texts`     | `size`       | Body font size. Default `11pt`.                                      |
|             | `ascender`   | Ascender height of the body font at `size`; measured automatically.   |
|             | `step`       | Line-grid step used for vertical rhythm. Default `7.5pt`.            |
| `fonts`     | `body`       | Body font.                                                           |
|             | `math`       | Math font.                                                           |
|             | `sans`       | Sans-serif font.                                                     |
|             | `mono`       | Monospace font.                                                      |
| `headings`  | `h2`         | Level-2 heading style: `sym`, `dy`, `size`.                          |
|             | `h3`         | Level-3 heading style: `sym`, `dy`, `size`.                          |
|             | `thm`        | Theorem numbering: `base` (restart level, default `1`) and `numbering` (default `"1.1.1"`). |
| `theme`     | *(name)*     | Theme name from `theme.typ`, e.g. `"default"` or `"monochrome"`.     |

## Themes

Themes are defined in `theme.typ` and selected by name, e.g.
`init.with(theme: "monochrome")`. Each theme is a dictionary of colors/strokes:

| Theme key | Description                                                        |
| --------- | ------------------------------------------------------------------ |
| `page`    | Page background color.                                             |
| `text`    | Default text color.                                                |
| `line`    | Default line/stroke color (margin rule, decorations, outline dots).|
| `muted`   | Secondary text (blank-page note).                                  |
| `faint`   | Tertiary text (running header).                                    |
| `strong`  | Accent text (page number).                                         |
| `theorem` | Per-environment strokes: `theorem`, `proposition`, `corollary`, `lemma`, `definition`, `example`, `remark`. |

Built-in themes:

- `default` — full-color accents on white.
- `monochrome` — grayscale luma tones on white; striped (45° white stripes)
  strokes for `proposition`, `lemma`, `example`, `remark`.
- `flexoki-light`, `flexoki-dark` — Flexoki palettes.
- `solarized-light`, `github-light`, `one-light`, `everforest-light`,
  `catppuccin-latte`, `rose-pine-dawn` — light palettes.
- `rose-pine-moon`, `rose-pine` — dark palettes.

Add new themes by inserting entries into the `themes` dictionary in
`theme.typ`. Each `theorem` entry is a style: either a plain color, or
`(color: .., pattern: ..)` where `color` is the base color (used for the
margin label) and `pattern` is the bar paint (e.g. a striped tiling). The
bar thickness is fixed by the renderer.

## Package layout

| File            | Responsibility                                                  |
| --------------- | --------------------------------------------------------------- |
| `lib.typ`       | Public API: re-exports everything below.                        |
| `init.typ`      | `init`: applies the resolved settings as `set`/`show` rules.     |
| `settings.typ`  | Defaults, config merging, derived values, and the `settings` state. |
| `layout.typ`    | Layout primitives (`v-step`, `place-side`, …) and page chrome.   |
| `heading.typ`   | Heading and outline rules.                                      |
| `theorem.typ`   | Theorem environments, numbering, and references.                |
| `theme.typ`     | Color themes.                                                   |

Rendering code never reads user arguments directly: `init` resolves them once
and publishes the result through the `settings` state, which every module reads
with `settings.get()`.

# Configuration

## `sheet` arguments

| Argument            | Default            | Description |
| ------------------- | ------------------ | ----------- |
| `course`            | `none`             | Course name (title block, footer). |
| `number`            | `none`             | Sheet number (margin emblem, title, footer). |
| `title`             | `none`             | Sheet title, e.g. the topic. |
| `kind`              | `auto`             | `"Exercise Sheet"` / `"Übungsblatt"` by language; any text. |
| `authors`           | `()`               | Strings or `(name: .., id: ..)`; shown in the title block and in the header from page 2. |
| `group`, `tutor`    | `none`             | Optional metadata fields. |
| `due`               | `none`             | String or `datetime`. |
| `lang`              | `"en"`             | `"en"` or `"de"`; sets every label. Add languages in `labels.typ`. |
| `theme`             | `"default"`        | A theme name from `theme.typ`. |
| `show-title`        | `true`             | Draw the title block. |
| `show-points-table` | `false`            | Grading table after the title block. |
| `show-points-total` | `false`            | Σ column in that table. |

## Fine-tuning dictionaries

These are merged over the defaults in `settings.typ`, so pass only the keys you
want to change, e.g. `margin: (e: 3cm)`.

| Field      | Subfields                         | Description |
| ---------- | --------------------------------- | ----------- |
| `paper`    | `width`, `height`                 | A4 by default. |
| `margin`   | `t`, `f`, `e`, `s`                | Top, bottom, outer (label column), and inner margins. |
| `side`     | `half-gutter`, `margin`           | Gap between the body and the labels, and padding toward the paper edge. |
| `texts`    | `size`, `step`                    | Body size (11pt) and line-grid step (7pt). |
| `fonts`    | `body`, `math`, `sans`, `mono`    | Each a family name or a list of fallbacks. |
| `headings` | `h1`, `h2`                        | Margin symbol `sym` and `size` factor for optional headings. |
| `tasks`    | `numbering`, `part-numbering`, `thm-numbering`, `points-suffix` | Numbering patterns (`"1"`, `"(a)"`, `"1.1"`) and the text after points. |
| `code`     | `numbers`, `size`, `lang-label`   | Line numbers by default, code size, and whether the language shows in the margin. |
| `figures`  | `caption`                         | `"margin"` (default) or `"below"`. |

## Themes

`default`, `monochrome`, `flexoki-light`, `flexoki-dark`, `solarized-light`,
`github-light`, `one-light`, `everforest-light`, `catppuccin-latte`,
`rose-pine-dawn`, `rose-pine-moon`, `rose-pine`.

A theme is a dictionary with the keys `page`, `text`, `line`, `muted`, `faint`,
`strong`, and `theorem`, where `theorem` sets the per-environment colors.
Tasks and parts use the `theorem` color, `claim` uses `proposition`, `hint`
uses `remark`, and `note` uses `example`, unless a theme defines them itself.

## Package layout

| File           | Responsibility |
| -------------- | -------------- |
| `lib.typ`      | Public API. |
| `init.typ`     | `sheet`: resolves the settings and installs the rules. |
| `settings.typ` | Defaults, merging, and the `settings` state. |
| `labels.typ`   | Localized labels. |
| `layout.typ`   | Grid primitives, margin placement, header, and footer. |
| `title.typ`    | Title block and points table. |
| `theorem.typ`  | Tasks, parts, answers, callouts, theorem-likes, and references. |
| `code.typ`     | Code block and inline code styling. |
| `figure.typ`   | Figure/plot styling (captions in the margin) and `plot`. |
| `theme.typ`    | Color themes. |

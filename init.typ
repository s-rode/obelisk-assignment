// The template entry point:
//
//   #show: sheet.with(
//     course: "Algorithms and Data Structures",
//     number: 3,
//     authors: ((name: "Ada Lovelace", id: "123456"), "Alan Turing"),
//     due: "21.11.2026",
//   )

#import "settings.typ": def-theme, resolve-settings, settings
#import "layout.typ": page-background, page-footer, page-header, paper-margin, place-node
#import "theorem.typ": theorem-rules
#import "code.typ": code-rules
#import "figure.typ": figure-rules
#import "title.typ": points-table, title-block

#let sheet(
  it,
  // Sheet metadata — every field is optional and simply hidden when unset.
  course: none,
  number: none,
  title: none,
  kind: auto, // "Exercise Sheet" / "Übungsblatt", from `lang`
  authors: (), // "Name" or (name: "Name", id: "123456")
  group: none,
  tutor: none,
  due: none, // string or datetime
  lang: "en", // "en" or "de": all labels follow it
  // "questions": restate each question, answer below it with `answer`.
  // "answers": only write your answers; `part`s go inside their `task`.
  mode: "questions",
  // Look.
  theme: def-theme,
  show-title: true,
  show-points-table: false, // a grading table under the title block
  show-points-total: false, // add a Σ column to that table
  // Fine-tuning (dictionaries merged over the defaults in settings.typ).
  paper: none,
  margin: none,
  side: none,
  texts: none,
  fonts: none,
  headings: none,
  tasks: none,
  code: none,
  figures: none,
) = context {
  let authors = if type(authors) in (str, dictionary, content) { (authors,) } else { authors }
  let s = resolve-settings((
    paper: paper,
    margin: margin,
    side: side,
    texts: texts,
    fonts: fonts,
    headings: headings,
    tasks: (if tasks == none { (:) } else { tasks }) + (mode: mode),
    code: code,
    figures: figures,
    theme: theme,
    lang: lang,
    meta: (
      course: course,
      title: title,
      number: number,
      kind: kind,
      due: due,
      authors: authors,
      group: group,
      tutor: tutor,
    ),
  ))

  // The line grid is built around the ascender height of the body font.
  s.texts.ascender = measure(text(font: s.fonts.body, size: s.texts.size, "h")).height

  settings.update(_ => s)

  let (paper, margin, side, body, fonts, texts, headings, theme, meta) = s
  let step = texts.step

  set document(
    title: [#if course != none [#course -- ]#s.meta.kind #number],
    author: authors.map(a => if type(a) == dictionary { a.name } else if type(a) == str { a } else { "" }),
  )
  set page(
    width: paper.width,
    height: paper.height,
    fill: theme.page,
    margin: paper-margin(margin, texts),
    background: page-background(paper, margin, side, fonts, theme),
    header: page-header(meta, side, fonts, theme),
    footer: page-footer(body, margin, side, fonts, theme, meta),
  )

  set text(font: fonts.body, size: texts.size, fill: theme.text, lang: lang)
  set par(
    leading: step,
    spacing: (step + texts.ascender) * 1.3 - texts.ascender,
    justify: true,
  )
  set list(indent: 0.4em, body-indent: 0.6em, marker: text(fill: theme.muted)[•])
  set enum(indent: 0.4em, body-indent: 0.6em)
  set table(stroke: 0.5pt + theme.line)
  show link: set text(fill: theme.strong)

  show math.equation: set text(font: fonts.math)
  show math.equation.where(block: true): block.with(breakable: true)

  // Headings are optional on a sheet (tasks carry the structure), compact,
  // and unnumbered by default.
  show heading: set text(font: fonts.sans, weight: "semibold")
  show heading.where(level: 1): it => {
    set text(size: texts.size * headings.h1.size)
    set par(justify: false)
    block(above: step * 4, below: step * 2, breakable: false, sticky: true)[
      #place-node(text(fill: theme.line, size: 0.8em, $#headings.h1.sym$)) #it.body
    ]
  }
  show heading.where(level: 2): it => {
    set text(size: texts.size * headings.h2.size)
    set par(justify: false)
    block(above: step * 3, below: step * 1.5, breakable: false, sticky: true)[
      #place-node(text(fill: theme.line, $#headings.h2.sym$)) #it.body
    ]
  }

  show: theorem-rules
  show: code-rules
  show: figure-rules

  if show-title { title-block() }
  if show-points-table { points-table(total: show-points-total) }

  it
}

// Kept for compatibility with obelisk-lite: `#show: init.with(...)`.
#let init = sheet

// Package defaults, configuration merging, and the resolved `settings` state.

#import "theme.typ": def-theme, themes
#import "labels.typ": labels

// Paper: A4.
#let def-paper-width = 21cm
#let def-paper = (
  width: def-paper-width,
  height: def-paper-width * calc.sqrt(2),
)

// Margins. `e` (outer, left) hosts the margin labels; it is narrower than in
// the notes template so the answer column gets more room.
#let def-margin = (
  t: 2cm,
  f: 2.2cm,
  e: 3.6cm,
  s: 1.9cm,
)

#let def-side = (
  half-gutter: 0.3cm, // gap between the text body and the margin labels
  margin: 0.6cm, // extra spacing toward the paper edge
)

// `step` sets the line grid: consecutive baselines sit one step apart.
// `ascender` is not configurable — `init` measures it from the body font.
#let def-texts = (
  size: 11pt,
  step: 7pt,
)

// Each entry may be a single family or a list of fallbacks.
#let def-fonts = (
  body: ("XCharter", "Charter", "New Computer Modern"),
  math: ("XCharter Math", "New Computer Modern Math"),
  sans: ("Hanken Grotesk", "Avenir Next", "Helvetica Neue"),
  mono: ("IBM Plex Mono", "Fira Mono", "Menlo"),
)

#let def-headings = (
  h1: (sym: sym.circle.filled, size: 1.25),
  h2: (sym: sym.triangle.filled.small.b, size: 1.1),
)

#let def-tasks = (
  numbering: "1", // task numbers
  part-numbering: "(a)", // sub-task numbers, restart with every task
  subpart-numbering: "(i)", // `subpart` numbers, restart with every part
  thm-numbering: "1.1", // <task>.<n> for lemmas etc. inside answers
  points-suffix: auto, // auto: taken from the language labels
  // How questions and answers are told apart. Any of:
  //   "sans": questions in the sans font, answers in the body font
  //   "bars": answers get a thin bar and label in the task color, and a
  //          hairline separates tasks
  //   "tint": questions on a light background
  style: ("sans", "bars"),
  // Set through `sheet(mode: ..)`:
  //   "questions": task/part bodies are the question, answers go in `answer`
  //   "answers": task/part bodies are your answer, parts nested in the task
  mode: "questions",
)

#let def-code = (
  numbers: false, // line numbers on fenced code blocks
  size: 0.85em,
  lang-label: true, // print the language in the margin
)

#let def-tables = (
  header-case: "upper", // "upper" or "normal" (keep the header text as typed)
)

#let def-figures = (
  caption: "margin", // "margin" or "below"
)

// Sheet metadata, shown in the title block, header and footer.
#let def-meta = (
  course: none,
  title: none, // e.g. "Graph Algorithms"
  number: none, // sheet number
  kind: auto, // auto: "Exercise Sheet" / "Übungsblatt"
  due: none,
  authors: (), // strings, or (name: .., id: ..) dictionaries
  group: none,
  tutor: none,
)

// Recursively fill missing (or `none`) entries of `user` from `defaults`.
// Neither argument is mutated.
#let merge-defaults(user, defaults) = {
  if type(defaults) != dictionary {
    return if user == none { defaults } else { user }
  }
  if type(user) != dictionary {
    return defaults
  }
  let merged = (:)
  for (key, default) in defaults {
    merged.insert(key, merge-defaults(user.at(key, default: none), default))
  }
  for (key, value) in user {
    if not merged.keys().contains(key) {
      merged.insert(key, value)
    }
  }
  merged
}

// Merge the user's configuration with the defaults and derive the computed
// values: the text body, the margin-label width, the theme and the labels.
#let resolve-settings(user) = {
  let s = merge-defaults(
    user,
    (
      paper: def-paper,
      margin: def-margin,
      side: def-side,
      texts: def-texts,
      fonts: def-fonts,
      headings: def-headings,
      tasks: def-tasks,
      code: def-code,
      figures: def-figures,
      tables: def-tables,
      meta: def-meta,
      theme: def-theme,
      lang: "en",
    ),
  )

  if not themes.keys().contains(s.theme) {
    panic("Unknown theme: " + str(s.theme))
  }
  if not labels.keys().contains(s.lang) {
    panic("Unknown language: " + str(s.lang) + " (available: " + labels.keys().join(", ") + ")")
  }

  if s.tasks.mode not in ("questions", "answers") {
    panic("mode must be \"questions\" or \"answers\", got " + repr(s.tasks.mode))
  }

  s.side.width = s.margin.e - s.side.margin - s.side.half-gutter
  s.body = (
    width: s.paper.width - s.margin.s - s.margin.e,
    height: s.paper.height - s.margin.t - s.margin.f,
  )
  s.theme = themes.at(s.theme)
  s.labels = labels.at(s.lang)
  if s.tasks.points-suffix == auto { s.tasks.points-suffix = s.labels.points }
  if s.meta.kind == auto { s.meta.kind = s.labels.sheet }
  s
}

// Published by `init` and read by every other module.
#let settings = state("obelisk:settings", none)

// The compact title block at the top of the first page, and the points table.

#import "settings.typ": settings
#import "layout.typ": author-name, place-side
#import "theorem.typ": no-points, resolved-points

#let emblem-size = 34pt
#let emblem-stroke = 1.2pt

// Text drawn twice in the page color — once outlined, once filled — so it reads
// as a glyph with a bold inner border.
#let outlined-text(body, stroke: luma(180), ..args) = context {
  let page = settings.get().theme.page
  box(
    place(text(body, stroke: stroke, fill: page, ..args))
      + text(body, stroke: none, fill: page, ..args),
  )
}

// One "LABEL / value" cell of the metadata row.
#let meta-field(label, value, s) = {
  set par(leading: s.texts.step * 0.6, justify: false)
  stack(
    spacing: 0.45em,
    text(size: 0.7em, fill: s.theme.muted, tracking: 0.06em, upper(label)),
    text(size: 0.85em, value),
  )
}

#let author-line(a, s) = {
  if type(a) == dictionary and a.at("id", default: none) != none {
    [#a.name #h(0.4em) #text(font: s.fonts.mono, size: 0.9em, fill: s.theme.muted, str(a.id))]
  } else {
    author-name(a)
  }
}

#let title-block() = context {
  let s = settings.get()
  let m = s.meta
  let labels = s.labels
  set text(font: s.fonts.sans)

  // Sheet number in the margin: takes no vertical space.
  if m.number != none {
    place-side(
      dy: -s.texts.ascender,
      outlined-text(
        size: emblem-size,
        weight: "bold",
        stroke: emblem-stroke + s.theme.line,
        str(m.number),
      ),
    )
  }

  // Course line, then sheet kind + title.
  set par(justify: false, leading: s.texts.step * 0.8)
  if m.course != none {
    text(size: 0.8em, fill: s.theme.muted, tracking: 0.04em, upper(m.course))
    linebreak()
  }
  {
    set text(size: 1.45em)
    let kind = if m.number != none { [#m.kind #m.number] } else { m.kind }
    text(weight: "light", kind)
    if m.title != none {
      text(fill: s.theme.line)[#h(0.3em)/#h(0.3em)]
      text(weight: "semibold", m.title)
    }
  }

  // Metadata row: authors, group, tutor, due date.
  let fields = ()
  if m.authors.len() > 0 {
    fields.push(meta-field(
      labels.authors,
      m.authors.map(a => author-line(a, s)).join(linebreak()),
      s,
    ))
  }
  if m.group != none { fields.push(meta-field(labels.group, m.group, s)) }
  if m.tutor != none { fields.push(meta-field(labels.tutor, m.tutor, s)) }
  if m.due != none {
    let due = if type(m.due) == datetime { m.due.display("[day].[month].[year]") } else { m.due }
    fields.push(meta-field(labels.due, due, s))
  }
  if fields.len() > 0 {
    v(0.9em, weak: true)
    grid(
      columns: fields.len(),
      column-gutter: 2.2em,
      ..fields,
    )
  }

  // Closing rule, joined to the margin rule.
  v(0.7em, weak: true)
  block(
    above: 0pt,
    below: s.texts.step * 2.5,
    move(dx: -s.side.half-gutter, line(length: s.body.width + s.side.half-gutter, stroke: 0.75pt + s.theme.line)),
  )
}

// A grading table with one column per task: number, maximum points, and an
// empty row for the score. Reads the tasks of the whole document.
#let points-table(total: false) = context {
  let s = settings.get()
  let tasks = query(<obelisk-task>)
  if tasks.len() == 0 { return }
  let num = t => numbering(s.tasks.numbering, ..counter("obelisk:task").at(t.location()))
  let pts = tasks.map(resolved-points)
  let known = pts.filter(p => type(p) in (int, float))
  let total-pts = if known.len() > 0 { known.sum() } else { none }
  let extra = if total { 1 } else { 0 }

  set text(font: s.fonts.sans, size: 0.8em)
  let head = c => text(fill: s.theme.muted, c)
  let line-col = s.theme.line
  block(
    above: 0pt,
    below: s.texts.step * 1.5,
    table(
      columns: (auto,) + (2.6em,) * (tasks.len() + extra),
      align: (x, _) => if x == 0 { left } else { center },
      stroke: (x, y) => (
        left: if x > 0 { 0.5pt + line-col },
        top: if y > 0 { 0.5pt + line-col },
      ),
      inset: (x: 0.5em, y: 0.45em),
      head(s.labels.task), ..tasks.map(t => strong(num(t))), ..if total { (strong[Σ],) },
      head(s.labels.points-long),
      ..pts.map(p => if not no-points(p) { text(fill: s.theme.muted)[/#p] }),
      ..if total { (if total-pts != none { text(fill: s.theme.muted)[/#total-pts] },) },
      [], ..range(tasks.len() + extra).map(_ => v(0.9em)),
    ),
  )
}

// Layout primitives and page chrome, all reading the resolved `settings` state.

#import "settings.typ": settings

// Advance the cursor by `count` line-grid steps.
#let v-step(count) = context {
  let s = settings.get()
  v(count * (s.texts.step + s.texts.ascender))
}

// Place `it` in the outer margin, flush right. `dx`/`dy` shift it; the rest go
// to the wrapping box. Works from inside indented containers too: the offset
// is measured from the text body's left edge, not the container's.
#let place-side(it, dx: 0pt, dy: 0pt, ..box-args) = context {
  let s = settings.get()
  let half-gutter = s.side.half-gutter
  let indent = here().position().x - s.margin.e
  set par(justify: false)
  place(
    dx: -s.side.width - half-gutter - indent + dx,
    dy: dy,
    box(
      width: s.side.width,
      inset: (left: half-gutter, right: half-gutter),
      outset: (
        top: half-gutter + s.texts.ascender,
        bottom: half-gutter,
      ),
      ..box-args,
      align(right, it),
    ),
  )
}

// Center a small symbol (e.g. a heading marker) on the margin rule.
#let place-node(sym, dy: 0pt) = context {
  let s = settings.get()
  place-side(sym, dx: s.side.half-gutter + measure(sym).width / 2, dy: dy)
}

// Text on a proportionally smaller line grid.
#let small(it, scale: 2 / 3, size: 0.75em) = context {
  let s = settings.get()
  set par(leading: s.texts.step * scale)
  text(size, it)
}

// Page margins, one grid step taller at the top so the first baseline lands on
// the grid.
#let paper-margin(margin, texts) = (
  top: margin.t + texts.step,
  left: margin.e,
  right: margin.s,
  bottom: margin.f,
)

// "Course · Exercise Sheet 3", or whatever parts of it are set.
#let sheet-label(meta) = {
  let parts = ()
  if meta.course != none { parts.push(meta.course) }
  if meta.number != none { parts.push([#meta.kind #meta.number]) }
  parts.join[ · ]
}

#let author-name(a) = if type(a) == dictionary { a.name } else { a }

// Background: the hairline between the text body and the margin column, plus
// a patch that erases it where the page number sits.
#let page-background(paper, margin, side, fonts, theme) = {
  let rule-dx = margin.e - side.half-gutter
  place(
    top + left,
    dx: rule-dx,
    line(start: (0%, 0%), end: (0%, 100%), stroke: 0.75pt + theme.line),
  )
  place(
    bottom + center,
    dx: -paper.width / 2 + rule-dx,
    dy: -margin.f / 2,
    box(
      fill: theme.page,
      outset: (top: side.half-gutter, bottom: side.half-gutter),
      text(font: fonts.sans, size: 0.85em)[#h(2em)],
    ),
  )
}

// Header from page 2 on: the submitters, so loose pages stay attributable.
#let page-header(meta, side, fonts, theme) = context {
  if counter(page).get().first() <= 1 or meta.authors.len() == 0 { return }
  set text(font: fonts.sans, size: 0.75em, fill: theme.muted)
  align(right + bottom, meta.authors.map(author-name).join[, ])
}

// Footer: the page number on the margin rule, the sheet label beside it.
#let page-footer(body, margin, side, fonts, theme, meta) = context {
  let dy = -margin.f / 2 + 0.6em
  set text(font: fonts.sans, size: 0.85em)
  place(
    bottom + left,
    dx: -side.half-gutter - 1em,
    dy: dy,
    box(width: 2em, align(center, text(fill: theme.strong)[#counter(page).get().first()])),
  )
  let label = sheet-label(meta)
  if label != none {
    place(bottom + left, dx: side.half-gutter + 1em, dy: dy, text(fill: theme.muted, label))
  }
}

// A sidenote at the current position, in the outer margin.
#let sidenote(it, dy: 0pt) = context {
  let s = settings.get()
  let baseline-offset = s.texts.ascender * (2 / 3)
  sym.wj
  box(place-side(small(it), dy: dy - baseline-offset))
  h(0pt, weak: true)
}

// Tables: a tinted header row in the sans font, hairlines between rows, no
// vertical lines. Colors come from the theme, so dark themes work too.

#import "settings.typ": settings

#let table-rules(it) = context {
  let s = settings.get()
  let t = s.theme
  let tint = color.mix((t.faint, 45%), (t.page, 55%))
  let row-line = color.mix((t.faint, 70%), (t.page, 30%))

  set table(
    inset: (x: 0.65em, y: 0.42em),
    fill: (x, y) => if y == 0 { tint },
    stroke: (x, y) => (top: if y > 1 { 0.4pt + row-line }),
  )
  // Equal-width digits so numbers line up; no stretched spaces in cells.
  show table: set text(number-width: "tabular")
  show table: set par(justify: false)
  // Bottom hairline closing the table.
  show table: it => block(stroke: (bottom: 0.4pt + t.line), it)

  show table.cell.where(y: 0): it => {
    set text(font: s.fonts.sans, size: 0.78em, tracking: 0.05em, fill: t.muted, weight: "medium")
    if s.tables.header-case == "upper" { upper(it) } else { it }
  }

  it
}

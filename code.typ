// Code: styled fenced blocks (language or file name in the margin, optional
// line numbers) and inline code.

#import "settings.typ": settings
#import "layout.typ": place-side

// Set by `code(...)` for the raw block it wraps.
#let code-override = state("obelisk:code", none)

#let code-fill(theme) = color.mix((theme.faint, 45%), (theme.page, 55%))

/// Wrap a fenced block to give it a title (e.g. a file name) in the margin
/// and/or toggle line numbers for just this block:
///   #code(title: "dijkstra.py", numbers: true)[```py ...```]
#let code(title: none, numbers: auto, body) = {
  code-override.update((title: title, numbers: numbers))
  body
  code-override.update(none)
}

#let code-rules(it) = context {
  let s = settings.get()
  let fill = code-fill(s.theme)

  show raw: set text(font: s.fonts.mono, size: s.code.size)

  // Inline code: a light chip.
  show raw.where(block: false): it => box(
    fill: fill,
    inset: (x: 2.5pt),
    outset: (y: 2.5pt),
    radius: 1.5pt,
    it,
  )

  show raw.where(block: true): it => context {
    let o = code-override.get()
    let numbers = if o != none and o.numbers != auto { o.numbers } else { s.code.numbers }
    let title = if o != none and o.title != none {
      o.title
    } else if s.code.lang-label and it.lang != none {
      upper(it.lang)
    }
    let digits = str(it.lines.len()).len()

    show raw.line: line => {
      if numbers {
        box(width: (digits + 1) * 0.6em, align(right, text(fill: s.theme.muted, str(line.number))))
        h(0.9em)
      }
      line.body
    }
    set par(justify: false, leading: s.texts.step * 0.75)
    block(
      width: 100%,
      fill: fill,
      inset: (x: 0.8em, y: 0.65em),
      radius: 2pt,
      breakable: true,
      above: s.texts.step * 2,
      below: s.texts.step * 2,
    )[#if title != none {
        place-side(
          dx: -0.8em,
          dy: 0.15em,
          text(font: s.fonts.sans, size: 0.72em, fill: s.theme.muted, tracking: 0.05em, title),
        )
      }#it]
  }

  it
}

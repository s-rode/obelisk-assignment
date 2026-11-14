// Figures (matplotlib plots, diagrams, tables): the label and caption go into
// the margin column, so the figure itself costs no extra vertical space.

#import "settings.typ": settings
#import "layout.typ": place-side

/// Shorthand for a plot/picture. Pass the image itself so its path resolves
/// relative to *your* file:
///   #plot(image("loss.svg"), caption: [Training loss], width: 75%) <fig-loss>
#let plot(img, caption: none, width: 100%) = figure(
  block(width: width, { set image(width: 100%); img }),
  caption: caption,
  kind: image,
)

#let figure-rules(it) = context {
  let s = settings.get()

  show figure: set figure(gap: s.texts.step)
  show figure.where(kind: image): set figure(supplement: s.labels.figure)
  show figure.where(kind: table): set figure(supplement: s.labels.table)

  // Figures from this template's own environments are styled elsewhere.
  show figure: it => {
    if type(it.kind) == str and it.kind.starts-with("obelisk-") { return it }
    let number = if it.numbering != none { it.counter.display(it.numbering) }
    let label = text(font: s.fonts.sans, size: 0.72em, fill: s.theme.muted)[
      #text(tracking: 0.05em, upper[#it.supplement #number])#if it.caption != none [\ #it.caption.body]
    ]
    if s.figures.caption == "margin" {
      block(width: 100%, above: s.texts.step * 2, below: s.texts.step * 2, breakable: false)[
        #place-side(label, dy: 0.2em)
        #align(center, it.body)
      ]
    } else {
      block(width: 100%, above: s.texts.step * 2, below: s.texts.step * 2, breakable: false)[
        #align(center, it.body)
        #v(s.texts.step * 0.5)
        #align(center, label)
      ]
    }
  }

  it
}

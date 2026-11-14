// Sheet environments: tasks, parts, answers, callouts, and theorem-likes.
// All share one renderer: a label in the margin column and a bar on the rule.

#import "settings.typ": settings
#import "theme.typ": theorem-style
#import "layout.typ": place-side

#let task-counter = counter("obelisk:task")
#let part-counter = counter("obelisk:part")
// Theorem-likes are numbered <task>.<n> and restart with every task.
#let thm-counter = counter("obelisk:theorem")

// Environments take `[body]`, `[title][body]`, or nothing at all.
#let split-arguments(args, name) = {
  if args.len() == 0 {
    (none, none)
  } else if args.len() == 1 {
    (none, args.at(0))
  } else if args.len() == 2 {
    (args.at(0), args.at(1))
  } else {
    panic(name + " expects 0–2 positional arguments, got " + str(args.len()) + ".")
  }
}

#let points-text(points, s) = if points != none {
  let p = if type(points) in (int, float) { str(points) } else { points }
  text(fill: s.theme.muted, weight: "regular")[#p #s.tasks.points-suffix]
}

// Points of a task (given by its `<obelisk-task>` metadata `t`): its own
// `points`, or else the sum of its parts' points. `none` if neither is given.
#let resolved-points(t) = {
  if t.value.points != none { return t.value.points }
  let next = query(selector(<obelisk-task>).after(t.location(), inclusive: false))
  let sel = selector(<obelisk-part>).after(t.location())
  if next.len() > 0 { sel = sel.before(next.first().location()) }
  let pts = query(sel).map(p => p.value.points).filter(p => p != none)
  if pts.len() > 0 { pts.sum() }
}

// The shared renderer. `label` goes into the margin, `body` next to a bar of
// `thickness` painted with `paint`. `above`/`below` are in grid steps.
#let env-block(
  label,
  body,
  paint: none,
  thickness: 4pt,
  above: 1.5,
  below: 1.5,
  min-lines: 1,
) = context {
  let s = settings.get()
  let overshoot = s.texts.step / 2
  let step = s.texts.step + s.texts.ascender
  let label-box = block(width: s.side.width, text(font: s.fonts.sans, size: 0.85em, label))
  // An empty body still needs one line so the margin label has room.
  let content = if body == none or body == [] {
    box(height: s.texts.ascender + (min-lines - 1) * step)
  } else { body }
  block(
    block([#place-side(label-box) #content], width: 100%, breakable: true),
    width: 100%,
    breakable: true,
    above: step * above,
    below: step * below,
    outset: (
      left: s.side.half-gutter,
      top: overshoot,
      bottom: overshoot,
    ),
    stroke: if paint != none { (left: (paint: paint, thickness: thickness)) },
  )
}

// A bold run-in title in front of the body: `*Title.* body`.
// Returns `none` when there is nothing to show, so empty environments can be
// detected by the renderer.
#let run-in(title, body, fill) = {
  if title == none { return body }
  context text(font: settings.get().fonts.sans, weight: "semibold", fill: fill, title)
  if body != none [ #h(0.3em) #body]
}

// ---------------------------------------------------------------------------
// Tasks and parts

/// A task (exercise). `#task[question]`, `#task[Title][question]`, or just
/// `#task(points: 4)` when you don't restate the question.
#let task(..args, points: none) = {
  let (title, body) = split-arguments(args.pos(), "task")
  figure(
    kind: "obelisk-task",
    supplement: context settings.get().labels.task,
    caption: title,
    outlined: false,
    numbering: _ => none,
  )[#task-counter.step()#part-counter.update(0)#context thm-counter.update(task-counter.get())#metadata((points: points, title: title))<obelisk-task>#context {
    let s = settings.get()
    let style = theorem-style(s.theme, "task")
    let num = numbering(s.tasks.numbering, ..task-counter.get())
    let points = resolved-points(query(selector(<obelisk-task>).before(here())).last())
    env-block(
      text(fill: style.label)[*#s.labels.task-short #num*#if points != none [#h(0.45em)#points-text(points, s)]],
      run-in(title, body, style.label),
      paint: style.paint,
      thickness: 4pt,
      above: 2,
      below: 1,
    )
  }]
}

/// A sub-task: `(a)`, `(b)`, … restarting with every task.
#let part(..args, points: none) = {
  let (title, body) = split-arguments(args.pos(), "part")
  figure(
    kind: "obelisk-part",
    supplement: context settings.get().labels.part,
    caption: title,
    outlined: false,
    numbering: _ => none,
  )[#part-counter.step()#metadata((points: points))<obelisk-part>#context {
    let s = settings.get()
    let style = theorem-style(s.theme, "part")
    let num = numbering(s.tasks.part-numbering, ..part-counter.get())
    env-block(
      text(fill: style.label)[*#num*#if points != none [#h(0.45em)#points-text(points, s)]],
      run-in(title, body, style.label),
      paint: style.paint,
      thickness: 2pt,
      above: 1.5,
      below: 1,
    )
  }]
}

// ---------------------------------------------------------------------------
// Answers and callouts

/// Your answer. Labelled "Answer" in the margin; pass `label: none` to hide
/// it, or a title to name it: `#answer[Proof of (b)][...]`.
#let answer(..args, label: auto, key: "answer") = context {
  let (title, body) = split-arguments(args.pos(), "answer")
  let s = settings.get()
  let name = if label == auto { s.labels.at(key) } else { label }
  env-block(
    if name != none { text(fill: s.theme.muted, tracking: 0.05em, upper(name)) },
    run-in(title, body, s.theme.strong),
    paint: s.theme.line,
    thickness: 1pt,
    above: 1,
    below: 1.2,
  )
}

#let solution = answer.with(key: "solution")

// Unnumbered, slightly smaller callout.
#let callout(key, ..args) = context {
  let (title, body) = split-arguments(args.pos(), key)
  let s = settings.get()
  let style = theorem-style(s.theme, key)
  env-block(
    text(fill: style.label, tracking: 0.05em, upper(s.labels.at(key))),
    text(size: 0.92em, run-in(title, body, style.label)),
    paint: style.paint,
    thickness: 2pt,
    above: 1,
    below: 1,
  )
}

#let hint = callout.with("hint")
#let note = callout.with("note")

/// Frame a final result, inline or as its own paragraph.
#let result(body) = context {
  let s = settings.get()
  box(
    stroke: 0.75pt + theorem-style(s.theme, "task").label,
    inset: (x: 0.4em, y: 0.25em),
    outset: (y: 0.15em),
    radius: 2pt,
    body,
  )
}

// ---------------------------------------------------------------------------
// Theorem-likes (for lemmas etc. inside answers)

/// Build a numbered environment. `key` selects both its label (from the
/// language table, or pass `name: ("Full", "SHORT")`) and its theme color.
#let make-environment(key, name: none) = (..args) => {
  let (title, body) = split-arguments(args.pos(), key)
  let names = s => if name != none { name } else { s.labels.at(key) }
  figure(
    kind: "obelisk-theorem",
    supplement: context names(settings.get()).at(0),
    caption: title,
    outlined: false,
    numbering: _ => none,
  )[#thm-counter.step(level: 2)#context {
    let s = settings.get()
    let style = theorem-style(s.theme, key)
    let n = thm-counter.get()
    let num = if n.first() == 0 { str(n.last()) } else { numbering(s.tasks.thm-numbering, ..n) }
    env-block(
      text(fill: style.label)[*#names(s).at(1) #num*#if title != none [\ #title]],
      body,
      paint: style.paint,
      thickness: 3pt,
      above: 1,
      below: 1,
    )
  }]
}

#let theorem = make-environment("theorem")
#let proposition = make-environment("proposition")
#let corollary = make-environment("corollary")
#let lemma = make-environment("lemma")
#let claim = make-environment("claim")
#let definition = make-environment("definition")
#let example = make-environment("example")
#let remark = make-environment("remark")

#let proof(..args) = context {
  let (title, body) = split-arguments(args.pos(), "proof")
  let s = settings.get()
  block(width: 100%, breakable: true)[
    _#if title != none { title } else { s.labels.proof }._ #body #h(1fr) $square$
  ]
}

// ---------------------------------------------------------------------------
// Rules installed by `init`: plain figure layout and references.
//   @t1 → "Task 1",  @t1-b → "Task 1(b)",  @lem → "Lemma 1.2",
//   @x[!] → the environment's title.

#let theorem-rules(it) = {
  show figure.where(kind: "obelisk-task"): it => align(left, it.body)
  show figure.where(kind: "obelisk-part"): it => align(left, it.body)
  show figure.where(kind: "obelisk-theorem"): it => align(left, it.body)

  show ref: it => context {
    let el = it.element
    if el == none or el.func() != figure or type(el.kind) != str or not el.kind.starts-with("obelisk-") {
      return it
    }
    let loc = el.location()
    if it.supplement == [!] and el.caption != none {
      return link(loc, el.caption.body)
    }
    // The figure's location precedes the counter steps inside its body, so
    // read the counters one step ahead.
    let s = settings.get()
    let t = task-counter.at(loc).first()
    let label = if el.kind == "obelisk-task" {
      [#el.supplement #numbering(s.tasks.numbering, t + 1)]
    } else if el.kind == "obelisk-part" {
      let part-num = numbering(s.tasks.part-numbering, part-counter.at(loc).first() + 1)
      [#s.labels.task #numbering(s.tasks.numbering, t)#part-num]
    } else {
      let n = thm-counter.at(loc)
      let k = if n.len() > 1 { n.at(1) + 1 } else { 1 }
      let num = if n.first() == 0 { str(k) } else { numbering(s.tasks.thm-numbering, n.first(), k) }
      [#el.supplement #num]
    }
    link(loc, label)
  }

  it
}

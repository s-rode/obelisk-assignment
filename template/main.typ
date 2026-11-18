#import "@local/obelisk-assignment:0.1.0": *

#show: sheet.with(
  course: "Course name",
  number: 1,
  // title: "Topic",
  authors: ("Your Name",), // or (name: "Your Name", id: "123456")
  // group: "A-01",
  // tutor: "Tutor Name",
  // due: "01.01.2027",
  // lang: "de",            // German labels
  // theme: "flexoki-dark", // other themes: see README
  // mode: "answers",       // only write answers, see the second half below
)

// Mode "questions" (default): restate each question, answer below it.
// Points are optional everywhere.

#task(points: 4)[Title][Question text.]

#answer[Your answer.]

#task[Second task][]

#part(points: 2)[First sub-task.]
#answer[
  Math works as usual: $a^2 + b^2 = c^2$.
]

#part[Second sub-task, without points.]
#answer[
  #code(title: "solution.py", numbers: true)[```python
  print("hello")
  ```]
]

// Mode "answers": put the parts inside their task and write only your
// answers. With `mode: "answers"` set above, this would look like:
//
// #task(points: 5)[
//   #part(points: 2)[Answer to (a).]
//   #part(points: 3)[Answer to (b).]
// ]
// #task[Title][Answer to a task without parts.]
//
// Inside a part, `#subpart[...]` numbers sub-items (i), (ii), … and
// `#todo[...]` marks unfinished answers (the footer counts them).

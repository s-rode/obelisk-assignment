#import "lib.typ": *

#show: sheet.with(
  course: "Algorithms and Data Structures",
  number: 4,
  authors: (
    (name: "Ada Lovelace", id: "412345"),
    (name: "Alan Turing", id: "409876"),
  ),
  due: "28.11.2026",
  mode: "answers",
)

#task(points: 5)[
  #part(points: 2)[
    The vertices are finalized in the order $s, b, a, c, d$ with distances
    $0, 2, 3, 5, 6$.
  ]
  #part(points: 3)[
    At the start of every iteration, $d[v] = delta(s, v)$ for every finalized
    vertex $v$; for every other vertex, $d[v]$ is the length of a shortest
    $s$–$v$ path through finalized vertices only.
  ]
]

#task(points: 4)[Negative weights][
  Take $V = {s, a, b}$ with $w(s, a) = 2$, $w(s, b) = 3$, $w(b, a) = -2$.
  Dijkstra finalizes $a$ with $d[a] = 2$ before visiting $b$, although
  $delta(s, a) = 1$. Hence #result[$d[a] != delta(s, a)$].
]

#task[
  #part[
    Relaxing all edges $|V| - 1$ times suffices, since a shortest path has at
    most $|V| - 1$ edges:

    ```python
    for _ in range(len(V) - 1):
        for (u, v, w) in E:
            d[v] = min(d[v], d[u] + w)
    ```
  ]
  #part[The running time is $O(|V| dot |E|)$.]
]

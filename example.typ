#import "lib.typ": *

#show: sheet.with(
  course: "Algorithms and Data Structures",
  number: 3,
  title: "Graphs & Shortest Paths",
  authors: (
    (name: "Ada Lovelace", id: "412345"),
    (name: "Alan Turing", id: "409876"),
    "Grace Hopper",
  ),
  group: "B-07",
  tutor: "M. Mustermann",
  due: "21.11.2026",
  theme: "default",
  show-points-table: true, // off by default; graders often do this
)

#task[Dijkstra on a small graph][
  Let $G = (V, E)$ be the weighted graph from the lecture with source $s$.
  Run Dijkstra's algorithm and give the order in which the vertices are
  finalized.
]

#part(points: 2)[State the invariant maintained by the priority queue.]

#answer[
  At the start of every iteration, for every finalized vertex $v$ we have
  $d[v] = delta(s, v)$, and for every other vertex $d[v]$ is the length of a
  shortest $s$–$v$ path that uses only finalized vertices as inner vertices.
]

#part(points: 3)[Implement the algorithm.]

#answer[
  A direct translation with a binary heap; `heapq` gives
  $O((|V| + |E|) log |V|)$.

  #code(title: "dijkstra.py", numbers: true)[
  ```python
  import heapq

  def dijkstra(graph, s):
      dist = {v: float("inf") for v in graph}
      dist[s] = 0
      pq = [(0, s)]
      while pq:
          d, u = heapq.heappop(pq)
          if d > dist[u]:
              continue
          for v, w in graph[u]:
              if d + w < dist[v]:
                  dist[v] = d + w
                  heapq.heappush(pq, (dist[v], v))
      return dist
  ```]

  The heap pays off quickly, see @fig-runtime.

  #plot(image("figs/runtime.svg"), caption: [Operation counts of both variants.], width: 85%) <fig-runtime>
]

#task(points: 5)[Negative weights][
  Show that Dijkstra's algorithm can fail if $G$ contains negative edge
  weights, even without negative cycles.
] <t-neg>

#answer[
  We first need a small observation.

  #lemma[Finalization][Once a vertex is extracted from the queue, its distance label is never changed again.] <lem-final>

  #proof[Immediate from the `if d > dist[u]` guard: extracted vertices are skipped.]

  Consider $V = {s, a, b}$ with $w(s, a) = 2$, $w(s, b) = 3$, $w(b, a) = -2$.
  Dijkstra finalizes $a$ with $d[a] = 2$ before visiting $b$, and by
  @lem-final never corrects it, although $delta(s, a) = 1$. Hence
  #result[$d[a] = 2 != 1 = delta(s, a)$].
]

#hint[Bellman–Ford handles negative weights in $O(|V| dot |E|)$.]

#task(points: 3)

#answer[
  Without restating the question: by @t-neg we need a different algorithm,
  e.g. Bellman–Ford, with the recurrence
  $
    d_k (v) = min{ d_(k-1)(v), min_((u, v) in E) d_(k-1)(u) + w(u, v) }.
  $
  A shell one-liner for checking: `python3 -m doctest bf.py`.

  ```rust
  fn relax(d: &mut [i64], u: usize, v: usize, w: i64) -> bool {
      if d[u] + w < d[v] { d[v] = d[u] + w; true } else { false }
  }
  ```
]

#note[All graphs are assumed to be simple unless stated otherwise.]

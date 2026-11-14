# Example figure for example.typ:  uv run --with matplotlib figs/make_plot.py
import math
import matplotlib.pyplot as plt

plt.rcParams.update({"font.family": "serif", "font.size": 9, "svg.fonttype": "none"})

n = list(range(1, 2001, 25))
fig, ax = plt.subplots(figsize=(4.8, 2.4))
ax.plot(n, [k * math.log2(k) for k in n], label=r"$n \log n$ (Dijkstra, heap)")
ax.plot(n, [k * k / 40 for k in n], label=r"$n^2 / 40$ (Dijkstra, array)")
ax.set_xlabel("$n$")
ax.set_ylabel("operations")
ax.spines[["top", "right"]].set_visible(False)
ax.legend(frameon=False)
fig.savefig("figs/runtime.svg", bbox_inches="tight", transparent=True)

#!/usr/bin/env python3
"""Noisy three-group spleen-size scatter for the Week 1 stats slide."""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "pics" / "biology" / "spleen_scatter_groups.png"


def main() -> None:
    np.random.seed(11)
    n = 32
    # Means still ~1.0 vs ~1.45, but SD large enough that groups overlap
    saluan = np.random.normal(1.00, 0.26, n)
    bajau_nd = np.random.normal(1.42, 0.28, n)
    bajau_d = np.random.normal(1.48, 0.27, n)
    rng = np.random.default_rng(5)

    fig, ax = plt.subplots(figsize=(8.4, 4.7), dpi=140)

    def swarm(vals, x0, color, label):
        xx = x0 + rng.uniform(-0.14, 0.14, size=len(vals))
        ax.scatter(
            xx,
            vals,
            s=40,
            c=color,
            alpha=0.78,
            edgecolors="white",
            linewidths=0.35,
            label=label,
            zorder=3,
        )
        m = float(vals.mean())
        ax.hlines(m, x0 - 0.22, x0 + 0.22, colors="#222", linewidths=2.0, zorder=4)

    swarm(saluan, 1, "#7f8c8d", "Saluan")
    swarm(bajau_nd, 2, "#5dade2", "Bajau, nicht tauchend")
    swarm(bajau_d, 3, "#1a5276", "Bajau, tauchend")

    ax.set_xticks([1, 2, 3])
    ax.set_xticklabels(["Saluan\n(Nachbar)", "Bajau\nnicht tauchend", "Bajau\ntauchend"])
    ax.set_ylabel("Relative Milzgrösse (Lehrdaten)")
    ax.set_ylim(0.35, 2.25)
    ax.set_xlim(0.5, 3.5)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.set_title(
        "Milzgrösse streut — Gruppenvergleich braucht Statistik",
        loc="left",
        fontsize=12,
        pad=10,
    )
    ax.axhline(1.0, color="#bbb", ls="--", lw=1, zorder=1)
    fig.tight_layout()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(OUT, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print(
        f"wrote {OUT}  "
        f"means={saluan.mean():.2f}, {bajau_nd.mean():.2f}, {bajau_d.mean():.2f}"
    )


if __name__ == "__main__":
    main()

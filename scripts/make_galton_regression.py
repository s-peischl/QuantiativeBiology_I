#!/usr/bin/env python3
"""Galton parent–child height scatter for Week 1 regression slide."""

from __future__ import annotations

import csv
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data" / "galton_families.csv"
OUT = ROOT / "pics" / "biology" / "regression_example.png"

INCH_TO_CM = 2.54


def load_cm() -> tuple[np.ndarray, np.ndarray]:
    mid, child = [], []
    with DATA.open(newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            mid.append(float(row["midparentHeight"]) * INCH_TO_CM)
            child.append(float(row["childHeight"]) * INCH_TO_CM)
    return np.asarray(mid), np.asarray(child)


def main() -> None:
    x, y = load_cm()
    slope, intercept = np.polyfit(x, y, 1)
    x_line = np.linspace(x.min(), x.max(), 100)
    y_line = slope * x_line + intercept

    fig, ax = plt.subplots(figsize=(8.2, 5.2), dpi=160)
    ax.scatter(
        x,
        y,
        s=22,
        alpha=0.45,
        c="#5d6d7e",
        edgecolors="none",
        label="Kinder (n = %d)" % len(x),
    )
    ax.plot(
        x_line,
        y_line,
        color="#c0392b",
        lw=2.4,
        label="Regression (Galton)",
    )
    # Population mean of children — visual cue for "toward the mean"
    y_mean = float(y.mean())
    ax.axhline(y_mean, color="#27ae60", ls="--", lw=1.4, alpha=0.85, label="Mittel der Kinder")

    ax.set_xlabel("Mittlere Elternhöhe (cm)", fontsize=12)
    ax.set_ylabel("Körperhöhe Kind (cm)", fontsize=12)
    ax.set_title("Galton: Körperhöhe Eltern → Kind", fontsize=14, pad=10)
    ax.legend(frameon=False, fontsize=10, loc="upper left")
    ax.grid(True, alpha=0.25)
    ax.set_axisbelow(True)
    for spine in ("top", "right"):
        ax.spines[spine].set_visible(False)

    fig.tight_layout()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(OUT, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print(f"Wrote {OUT}  (slope={slope:.3f}, intercept={intercept:.1f})")


if __name__ == "__main__":
    main()

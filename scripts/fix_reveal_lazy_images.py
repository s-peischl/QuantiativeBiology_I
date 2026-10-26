#!/usr/bin/env python3
"""Reveal + embed-resources puts images in data-src for lazy load.

If Reveal's ready event already fired (or preview skips JS), slides stay blank.
Copy data-src → src on every img that lacks src, for all Reveal HTML under _site.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "_site"
IMG_TAG = re.compile(r"<img\b[^>]*>", re.I)


def fix_html(text: str) -> tuple[str, int]:
    n = 0

    def repl(m: re.Match[str]) -> str:
        nonlocal n
        tag = m.group(0)
        if re.search(r"\ssrc=", tag):
            return tag
        ds = re.search(r'\sdata-src="([^"]*)"', tag)
        if not ds:
            return tag
        n += 1
        return tag.replace("data-src=", f'src="{ds.group(1)}" data-src=', 1)

    return IMG_TAG.sub(repl, text), n


def main() -> int:
    if not SITE.is_dir():
        print("no _site/; skip", file=sys.stderr)
        return 0
    total = 0
    for path in sorted(SITE.rglob("slides.html")):
        original = path.read_text(encoding="utf-8")
        fixed, n = fix_html(original)
        if n:
            path.write_text(fixed, encoding="utf-8")
            print(f"{path.relative_to(ROOT)}: fixed {n} img(s)")
            total += n
    print(f"done; {total} image(s) patched")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

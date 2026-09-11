#!/usr/bin/env python3
"""Write PDF copies of published Reveal decks under _site/.

Used after `quarto render` (CI and local). Requires:

    python3 -m pip install playwright
    python3 -m playwright install chromium
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


def export_one(page, html: Path, pdf: Path) -> None:
    url = html.resolve().as_uri() + "?print-pdf"
    page.goto(url, wait_until="networkidle", timeout=180_000)
    page.wait_for_function(
        "() => typeof Reveal !== 'undefined'",
        timeout=20_000,
    )
    page.wait_for_function(
        "() => document.documentElement.classList.contains('print-pdf')",
        timeout=20_000,
    )
    page.wait_for_function(
        "() => [...document.images].every((img) => img.complete)",
        timeout=60_000,
    )
    pdf.parent.mkdir(parents=True, exist_ok=True)
    page.pdf(
        path=str(pdf),
        print_background=True,
        prefer_css_page_size=True,
        landscape=True,
        margin={"top": "0", "right": "0", "bottom": "0", "left": "0"},
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--site",
        type=Path,
        default=Path("_site"),
        help="Quarto output directory (default: _site)",
    )
    args = parser.parse_args()
    slides = sorted(args.site.glob("weeks/week-*/slides.html"))
    if not slides:
        print(f"No slides.html under {args.site}/weeks/", file=sys.stderr)
        return 1

    from playwright.sync_api import sync_playwright

    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        failed = 0
        for html in slides:
            pdf = html.with_suffix(".pdf")
            print(f"PDF {html} -> {pdf}", flush=True)
            try:
                export_one(page, html, pdf)
            except Exception as exc:
                print(f"  FAILED: {exc}", file=sys.stderr, flush=True)
                failed += 1
                continue
            print(f"  {pdf.stat().st_size} bytes", flush=True)
        browser.close()
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())

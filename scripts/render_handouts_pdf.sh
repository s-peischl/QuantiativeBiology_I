#!/usr/bin/env bash
# Build student handout PDFs (ILIAS + hub download).
# Quarto PDF is not used: TeX Live 2016 rejects Quarto's babel bidi options.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

author="Stephan Peischl, Loraine Hablützel und Emma Ochsner"

render_simple() {
  local src="$1" out="$2" title="$3" subtitle="$4"
  python3 - "$src" "$tmp/body.md" <<'PY'
from pathlib import Path
import sys
text = Path(sys.argv[1]).read_text()
if text.startswith("---"):
    text = text.split("---", 2)[2]
Path(sys.argv[2]).write_text(text.lstrip("\n"))
PY
  pandoc "$tmp/body.md" \
    -o "$out" \
    --pdf-engine=pdflatex \
    -V geometry:margin=2.2cm \
    -V fontsize=11pt \
    -V colorlinks=true \
    --metadata title="$title" \
    --metadata subtitle="$subtitle" \
    --metadata author="$author"
  echo "Wrote $out"
}

render_simple \
  "$root/docs/kursinfo.qmd" \
  "$root/docs/kursinfo.pdf" \
  "Quantitative Biologie I" \
  "Kursinformationen · Herbstsemester 2026"

python3 - "$root/docs/course-outline.qmd" "$tmp/kursplan.md" <<'PY'
import re
from pathlib import Path
import sys

text = Path(sys.argv[1]).read_text()
if text.startswith("---"):
    text = text.split("---", 2)[2]

# Drop hub-status / collaborator / repo sections.
text = re.sub(
    r"^- 14 Wochen; derzeit veröffentlicht:.*\n",
    "- 14 Wochen\n",
    text,
)
text = re.sub(r"\n### Navigation in den Folien\n.*?(?=\n---\n)", "\n", text, flags=re.S)
text = re.sub(r"\n## Prioritäten für Mitwirkende\n.*", "\n", text, flags=re.S)
text = re.sub(r"\n## Materialübersicht\n.*", "\n", text, flags=re.S)
text = re.sub(r" \{#[^}]+\}", "", text)
text = text.replace("×", "x")
text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
text = "\n".join(line.rstrip() for line in text.splitlines()).strip() + "\n"
Path(sys.argv[2]).write_text(text)
PY

pandoc "$tmp/kursplan.md" \
  -o "$root/docs/kursplan.pdf" \
  --pdf-engine=pdflatex \
  --toc \
  --toc-depth=2 \
  -V toc-title=Inhalt \
  -V geometry:margin=2cm \
  -V fontsize=10pt \
  -V colorlinks=true \
  --metadata title="Quantitative Biologie I" \
  --metadata subtitle="Kursplan · Herbstsemester 2026" \
  --metadata author="$author"

echo "Wrote $root/docs/kursplan.pdf"

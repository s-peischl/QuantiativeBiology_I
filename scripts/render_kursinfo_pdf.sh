#!/usr/bin/env bash
# Back-compat wrapper; both handouts are built together.
exec "$(cd "$(dirname "$0")" && pwd)/render_handouts_pdf.sh"

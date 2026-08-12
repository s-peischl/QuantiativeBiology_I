# Week 4 data — field cycles & classic series

Real time series for **qualitative** model–data comparison (not formal fitting).

| File | System | Why it’s here | Source |
|---|---|---|---|
| `isle_royale_moose_wolf.csv` | Moose (*Alces*) + wolf (*Canis*), Isle Royale | Main classroom opener: real predator–prey in the wild | `gauseR::mclaren_1994_f03` (McLaren & Peterson 1994 *Science*) |
| `huffaker_mites.csv` | Mite prey + predatory mite (60-week run) | Lab predator–prey with longer persistence / spatial structure story | `gauseR::huffaker_1963` |
| `hudson_bay_lynx.csv` | Canadian lynx pelt counts 1821–1934 | Famous ~10-year cycles (lynx only; hares not in this file) | R `datasets::lynx` |

## Suggested classroom use

1. Start with **Isle Royale** (two columns: moose & wolf).
2. Ask: trend, lag, crashes, noise?
3. Compare to a simple LV / LV+\(K\) simulation from Weeks 2–3.
4. Optional: Huffaker (refuges / own-model prompt) or lynx cycles.

## Citations

- McLaren, B. E., & Peterson, R. O. (1994). Wolves, moose, and tree rings on Isle Royale. *Science*.
- Huffaker, C. B. (classic mite experiments; see `gauseR` documentation for figure notes).
- Lynx series: Hudson’s Bay Company records as distributed in R `datasets::lynx`.

## Re-export

```bash
Rscript weeks/week-03/data/export_datasets.R
```

(That script also writes the Week 4 CSVs.)

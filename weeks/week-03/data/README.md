# Week 3 data — Gause competition (*Paramecium*)

Real digitized experiments from **Gause (1934)** via [`gauseR`](https://cran.r-project.org/package=gauseR).

**Biological motivation:** both species grow when alone (logistic / carrying capacity), but together one wins — classic **competitive exclusion**. Motivates adding \(K\) and a second competing species to last week’s engine.

| File | Content | Source |
|---|---|---|
| `paramecium_caudatum_alone.csv` | *P. caudatum* monoculture (volume) | `gause_1934_book_f22` Treatment `Pc` |
| `paramecium_aurelia_alone.csv` | *P. aurelia* monoculture (volume) | `gause_1934_book_f22` Treatment `Pa` |
| `paramecium_competition.csv` | Mixture (wide: day, caudatum, aurelia) | `gause_1934_book_f22` Treatment `Mixture` |
| `paramecium_competition_long.csv` | Alone + mixture in long form | same |

Units are **culture volume** (as digitized), not raw cell counts — fine for qualitative pattern comparison.

## Citation

- Gause, G. F. (1934). *The Struggle for Existence*. Williams & Wilkins. Fig. 22.
- Digitization: R package **gauseR**.

## Re-export

```bash
Rscript weeks/week-03/data/export_datasets.R
```

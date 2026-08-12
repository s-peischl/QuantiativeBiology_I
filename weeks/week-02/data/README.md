# Week 2 data — real Gause experiments

Digitized from **Gause (1934)** via the R package [`gauseR`](https://cran.r-project.org/package=gauseR).

| File | Content | Source in `gauseR` |
|---|---|---|
| `paramecium_alone.csv` | *Paramecium caudatum* monoculture growth | `gause_1934_book_f21` (complete Individuals only) |
| `paramecium_with_didinium.csv` | *Paramecium* + *Didinium* (immigration pulses marked) | `gause_1934_book_f32` |
| `paramecium_didinium_extinction.csv` | *Paramecium* + *Didinium* crash (Osterhout medium) | `gause_1934_book_f30` |

## Citations

- Gause, G. F. (1934). *The Struggle for Existence*. Williams & Wilkins.
- Digitization / packaging: Karakoç, C., et al., R package **gauseR**.

## Re-export

```r
Rscript weeks/week-02/data/export_gause.R
```

(Requires `install.packages("gauseR")`.)

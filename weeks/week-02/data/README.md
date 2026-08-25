# Daten zu Woche 2 — reale Experimente von Gause

Aus **Gause (1934)** mithilfe des R-Pakets [`gauseR`](https://cran.r-project.org/package=gauseR) digitalisiert.

| Datei | Inhalt | Quelle in `gauseR` |
|---|---|---|
| `paramecium_alone.csv` | Wachstum einer Monokultur von *Paramecium caudatum* | `gause_1934_book_f21` (nur vollständige Individuen) |
| `paramecium_with_didinium.csv` | *Paramecium* + *Didinium* (Immigrationsereignisse markiert) | `gause_1934_book_f32` |
| `paramecium_didinium_extinction.csv` | Zusammenbruch von *Paramecium* + *Didinium* (Osterhout-Medium) | `gause_1934_book_f30` |

## Literaturangaben

- Gause, G. F. (1934). *The Struggle for Existence*. Williams & Wilkins.
- Digitalisierung / Paketierung: Karakoç, C., et al., R-Paket **gauseR**.

## Erneuter Export

```r
Rscript weeks/week-02/data/export_gause.R
```

(Erfordert `install.packages("gauseR")`.)

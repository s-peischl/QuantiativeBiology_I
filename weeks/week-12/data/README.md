# Rottensand grasshopper counts, 2019 and 2024 (weeks 12–13)

Field course *Conservation Biology*, University of Bern. Rottensand
(Pfynwald, Valais): a grid of 10 × 10 m plots between the Rhône and the
pine forest. Late July 2019 and late July 2024, every plot visited four
times; grasshoppers and praying mantises counted (2024 also lizards and
wasp spiders); habitat cover mapped once per plot.

Used with permission of the course owners (Nov 2026).

## Files

| File | Rows | Columns | Source |
|---|---|---|---|
| `rottensand_2019.csv` | 540 | 178 | Excel `Rottensand_data_2019_final.xlsx`, sheet `Rottensand_data_tot_2019` |
| `rottensand_2024.csv` | 540 | 136 | `Rottensand_data_tot_2024.csv` |

Made by `scripts/make_rottensand_data.R` from the originals in
`../examples/ConservationBio/` (outside the repo). The script does two
things only:

1. Writes 2019 as CSV. In the Excel file missing values are the text
   `"NA"`, which turns every numeric column into text when read naively.
2. Replaces observer initials (`observ1`–`observ4`) by team codes
   (`Team A`, …; `alle` = whole class). Codes are per year.

Everything else is raw on purpose (teaching material for week 12).

## Structure

- One row per plot **and** quarter: `quarter` is `SW`, `NW`, `NE`, `SE`
  or `tot` (whole plot). Habitat cover was mapped in two quarters only.
- Plots never visited have `NA` everywhere (2019: `habitat.type` =
  `NotSampled`).
- Counts: one column per species and visit, e.g. `OedCae1`–`OedCae4`.
- Cover columns (`grass`, `forb`, `soil`, `gravel`, `stone`, `rock`,
  `litter`, …) in percent; `cover.sum` should be 100.

Species used in the course: `OedCae` *Oedipoda caerulescens*, `CalIta`
*Calliptamus italicus*, `OedGer` *Oedipoda germanica*, `SphCae`
*Sphingonotus caerulans*, `PlaAlb` *Platycleis albopunctata*, `ManRel`
*Mantis religiosa*.

## Known quirks (left in on purpose)

- 2019: plot 51 has `cover.sum` 50, plot 104 has 105.
- Habitat names differ: 2024 adds `rhone` and `riverbed`.
- Times are text in mixed formats (`09h30`, `9h50`).
- 2019 has 92 visited plots, 2024 has 90; 83 are in both years.
- Species columns differ between years (`Liz`, `ArgBru` only 2024;
  `TetVir`, `UndetBlue`, `UndetRed` only 2019).

Week 13 uses an identical copy in `weeks/week-13/data/`.

Axis labels in R plots: ASCII only (`Ost (m)`, `Nord (m)`, `Tiere pro Plot`).

# Week 9 pond inversion counts

## `pond-chrxi.csv`

Allele-copy counts for the **chromosome XI freshwater orientation** in
three UBC experimental ponds (ponds 2, 7 and 14). Introduction at
year 0 used heterozygous marine carriers, so \(p_0 = 0.5\). Later years
are F1–F4 samples (spring 2023–2026). Pond 7 has no year-4 sample.

| Column | Meaning |
|---|---|
| `pond` | Replicate pond (2, 7, 14) |
| `year` | Years since introduction |
| `k` | Count of the freshwater orientation (allele copies) |
| `n` | Allele copies scored (`2` × individuals) |
| `p` | Frequency `k / n` |

**Source.** Katie Peichel (Bern) and Dolph Schluter (UBC). Unpublished
teaching extract from the ongoing pond experiment. Use on the public course
hub approved by the data owners (Nov 2026). Cite as "unveröffentlicht, mit
freundlicher Genehmigung". Pond photos in `pics/pond-experiment/` are **not**
covered by this and stay local.

Axis labels in plots: `Jahr`, `Frequenz` (no umlauts in the R script).

# Week 9 pond inversion counts

## `pond-chrxi.csv`

Chromosome XI inversion in three UBC experimental ponds (ponds 2, 7
and 14). In 2022 marine sticklebacks were caught in Oyster Lagoon and
genotyped by PCR (fin clip); heterozygous carriers (about 25 per pond)
were released into the ponds, so \(p_0 = 0.5\). They reproduced in the
ponds; later years are samples of the F1–F4 generations (spring
2023–2026), every fish PCR-genotyped. Pond 7 has no year-4 sample.

| Column | Meaning |
|---|---|
| `pond` | Replicate pond (2, 7, 14) |
| `year` | Years since introduction (0 = released fish) |
| `fish` | Fish genotyped (numbers printed on Katie Peichel's figure; years 1–4 sum to 1044) |
| `n` | Allele copies scored, `2 × fish` |
| `k` | Copies with the freshwater orientation, `round(p × n)` |
| `p` | Frequency `k / n` |

**How the numbers were made.** The owners' figure gives the number of
fish per sample and the frequency as a point. `p` was read off that
figure (digitised), `k` follows from it. Exact genotype counts are not
in this extract. An earlier version of this file wrongly treated the
fish numbers as freshwater-copy counts (`k`) and back-computed `n`; the
frequencies were right, the sample sizes were not (fixed Nov 2026).

**Source.** Katie Peichel (Bern) and Dolph Schluter (UBC). Unpublished
teaching extract from the ongoing pond experiment. Use on the public course
hub approved by the data owners (Nov 2026). Cite as "unveröffentlicht, mit
freundlicher Genehmigung". Pond photos in `pics/pond-experiment/` are **not**
covered by this and stay local.

Axis labels in plots: `Jahr`, `Frequenz` (no umlauts in the R script).

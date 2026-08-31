# Week 5 genotype data

## `hapmap_chb_chr1.csv`

Genotype counts (`AA`, `AB`, `BB`) for 225 polymorphic SNPs without
missing genotypes on chromosome 1 in 84 Han Chinese individuals from
Beijing (CHB). Generic SNP labels preserve the source row order.

- The International HapMap Consortium (2007). *Nature* 449: 851–861.
  <https://doi.org/10.1038/nature06258>
- Distributed as `HapMapCHBChr1` in CRAN **HardyWeinberg** 1.7.9.
- Rebuild with `prepare_hapmap_data.R`.

## `famous_snps.csv`

CEU (n = 99) and YRI (n = 108) genotype counts for three well-known
SNPs, from 1000 Genomes Phase 3 allele counts (Ensembl REST, retrieved
2026-08-27).

| SNP | Trait |
|---|---|
| `rs2814778` | Duffy-null / ACKR1 |
| `rs4988235` | lactase persistence / MCM6 |
| `rs1426654` | light skin pigmentation / SLC24A5 |

Where a population is fixed or has a single copy of the rare allele,
genotypes are uniquely determined by the allele counts. For CEU
`rs4988235` the table stores the integer HWE counts that match the
published allele counts (146 A + 52 G) exactly.

- 1000 Genomes Project Consortium (2015). *Nature* 526: 68–74.
  <https://doi.org/10.1038/nature15393>

## `panel_ceu_yri.csv`

50 simulated SNPs for the pooled-then-stratified HWE plots.
Each population is generated under HWE; 10 SNPs are strongly
differentiated, 40 are similar. Rebuild with `prepare_two_pops.R`.

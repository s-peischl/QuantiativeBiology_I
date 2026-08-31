# Build a CEU+YRI teaching panel for the Wahlund demonstration.
# Famous SNPs are stored separately in famous_snps.csv from 1000 Genomes
# Phase 3 allele counts (Ensembl REST, 2026-08-27). Background SNPs are
# simulated under HWE *within* each population.

set.seed(5)

hwe_integers <- function(n, nA) {
  p <- nA / (2 * n)
  AA <- round(n * p^2)
  BB <- round(n * (1 - p)^2)
  AB <- n - AA - BB
  # Keep allele count exact by moving one heterozygote if needed.
  current <- 2 * AA + AB
  while (current < nA) {
    if (BB > 0) {
      BB <- BB - 1
      AB <- AB + 1
    } else {
      AB <- AB - 1
      AA <- AA + 1
    }
    current <- 2 * AA + AB
  }
  while (current > nA) {
    if (AA > 0) {
      AA <- AA - 1
      AB <- AB + 1
    } else {
      AB <- AB - 1
      BB <- BB + 1
    }
    current <- 2 * AA + AB
  }
  stopifnot(AA + AB + BB == n, 2 * AA + AB == nA, AA >= 0, AB >= 0, BB >= 0)
  c(AA = AA, AB = AB, BB = BB)
}

n_ceu <- 99
n_yri <- 108

similar <- lapply(1:40, function(i) {
  p <- runif(1, 0.15, 0.85)
  nA_ceu <- round(2 * n_ceu * p)
  nA_yri <- round(2 * n_yri * (p + runif(1, -0.03, 0.03)))
  nA_yri <- min(max(nA_yri, 1), 2 * n_yri - 1)
  ceu <- hwe_integers(n_ceu, nA_ceu)
  yri <- hwe_integers(n_yri, nA_yri)
  rbind(
    data.frame(snp = sprintf("SIM_similar_%02d", i), class = "aehnlich",
               pop = "CEU", n = n_ceu, t(ceu)),
    data.frame(snp = sprintf("SIM_similar_%02d", i), class = "aehnlich",
               pop = "YRI", n = n_yri, t(yri))
  )
})

differentiated <- lapply(1:10, function(i) {
  p1 <- runif(1, 0.75, 0.98)
  p2 <- runif(1, 0.02, 0.25)
  if (runif(1) < 0.5) {
    tmp <- p1
    p1 <- p2
    p2 <- tmp
  }
  ceu <- hwe_integers(n_ceu, round(2 * n_ceu * p1))
  yri <- hwe_integers(n_yri, round(2 * n_yri * p2))
  rbind(
    data.frame(snp = sprintf("SIM_diff_%02d", i), class = "differenziert",
               pop = "CEU", n = n_ceu, t(ceu)),
    data.frame(snp = sprintf("SIM_diff_%02d", i), class = "differenziert",
               pop = "YRI", n = n_yri, t(yri))
  )
})

panel <- rbind(do.call(rbind, similar), do.call(rbind, differentiated))
rownames(panel) <- NULL
write.csv(panel, "panel_ceu_yri.csv", row.names = FALSE, quote = FALSE)
message("Wrote ", length(unique(panel$snp)), " SNPs to panel_ceu_yri.csv")

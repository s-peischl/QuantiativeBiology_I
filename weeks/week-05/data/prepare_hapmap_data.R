# Rebuild hapmap_chb_chr1.csv from the CRAN HardyWeinberg source archive.
# Run from weeks/week-05/data/. No package installation is required.

version <- "1.7.9"
url <- sprintf(
  "https://cloud.r-project.org/src/contrib/HardyWeinberg_%s.tar.gz",
  version
)

tmp <- tempfile("hardyweinberg-")
dir.create(tmp)
on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

archive <- file.path(tmp, basename(url))
download.file(url, archive, mode = "wb")
member <- "HardyWeinberg/data/HapMapCHBChr1.rda"
untar(archive, files = member, exdir = tmp)
load(file.path(tmp, member))

stopifnot(
  is.matrix(HapMapCHBChr1),
  identical(dim(HapMapCHBChr1), c(225L, 3L)),
  identical(colnames(HapMapCHBChr1), c("AA", "AB", "BB")),
  all(rowSums(HapMapCHBChr1) == 84)
)

out <- data.frame(
  snp = sprintf("SNP_%03d", seq_len(nrow(HapMapCHBChr1))),
  AA = HapMapCHBChr1[, "AA"],
  AB = HapMapCHBChr1[, "AB"],
  BB = HapMapCHBChr1[, "BB"],
  check.names = FALSE
)

write.csv(out, "hapmap_chb_chr1.csv", row.names = FALSE, quote = FALSE)
message("Wrote 225 SNPs to hapmap_chb_chr1.csv")

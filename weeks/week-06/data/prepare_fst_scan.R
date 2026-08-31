# Teaching Fst scan: marine vs freshwater sticklebacks (schematic).
# Background Fst is low; a few peaks stand in for known ecotype loci.
# Not real Jones et al. (2012) or Hohenlohe et al. (2010) genotypes.

set.seed(6)

chr_len <- c(280, 220, 200)
scan <- do.call(rbind, lapply(seq_along(chr_len), function(chr) {
  n <- chr_len[chr]
  data.frame(
    chr = chr,
    pos = seq_len(n),
    fst = rbeta(n, 1.15, 28)
  )
}))

add_peak <- function(chr, center, height, width) {
  i <- which(scan$chr == chr)
  bump <- height * exp(-((scan$pos[i] - center)^2) / (2 * width^2))
  scan$fst[i] <<- pmin(0.92, scan$fst[i] + bump)
}

add_peak(1, 92, 0.80, 5.5)
add_peak(2, 148, 0.42, 7)
add_peak(3, 70, 0.74, 4.5)

gap <- 18
offsets <- c(0, cumsum(chr_len[-length(chr_len)] + gap))
scan$x <- scan$pos + offsets[scan$chr]
scan$label <- ""
scan$label[scan$chr == 1 & scan$pos == 92] <- "Platten"
scan$label[scan$chr == 3 & scan$pos == 70] <- "Becken"

out <- "fst_scan.csv"
write.csv(scan, out, row.names = FALSE)
message("wrote ", out, ": ", nrow(scan), " SNPs")

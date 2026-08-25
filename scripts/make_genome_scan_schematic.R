# Teaching schematic: genome-wide selection scan highlighting a hit
png("pics/biology/genome_scan_schematic.png", width = 1000, height = 420, res = 120)
set.seed(7)
par(mar = c(4.5, 4.5, 3.2, 1), family = "sans")
chr_len <- c(8, 7, 6, 6, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1)
pos <- c()
stat <- c()
chr_id <- c()
x0 <- 0
centers <- c()
for (i in seq_along(chr_len)) {
  n <- chr_len[i] * 18
  x <- x0 + seq_len(n) / 18
  y <- abs(rnorm(n, 0, 0.9))
  # soft background peaks
  if (i %% 4 == 0) y <- y + dnorm(seq_len(n), mean = n / 2, sd = n / 8) * 2
  pos <- c(pos, x)
  stat <- c(stat, y)
  chr_id <- c(chr_id, rep(i, n))
  centers <- c(centers, mean(x))
  x0 <- max(x) + 0.6
}
# strong hit on "chr 2-ish"
hit <- which(chr_id == 2)
stat[hit[35:48]] <- stat[hit[35:48]] + seq(2.5, 5.5, length.out = 14)
stat[hit[40]] <- 7.2

cols <- ifelse(chr_id %% 2 == 1, "#5dade2", "#2e86c1")
plot(pos, stat, pch = 16, cex = 0.45, col = cols,
     xlab = "Genomposition (Chromosomen)", ylab = "Selektionssignal (schematisch)",
     main = "Genomweiter Scan: wo stechen Signale heraus?",
     axes = FALSE, ylim = c(0, 8))
axis(2)
abline(h = 4.5, lty = 2, col = "#c0392b", lwd = 2)
points(pos[hit[40]], stat[hit[40]], pch = 16, cex = 1.3, col = "#c0392b")
text(pos[hit[40]], 7.6, "Treffer\n(z. B. EPAS1 / PDE10A)", col = "#c0392b", cex = 0.9, font = 2)
mtext("Schwelle", side = 4, at = 4.5, line = -8, col = "#c0392b", cex = 0.8)
box()
# chr ticks
axis(1, at = centers, labels = seq_along(chr_len), cex.axis = 0.7, tick = FALSE)
dev.off()
message("ok")

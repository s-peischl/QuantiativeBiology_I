# Teaching figure: Simpson's paradox (penguin-style populations)
set.seed(1)
mk <- function(mx, my, n = 40) {
  x <- rnorm(n, mx, 0.35)
  y <- my - 0.7 * (x - mx) + rnorm(n, 0, 0.25)
  data.frame(x, y)
}
A <- cbind(mk(2.0, 3.2), pop = "A")
B <- cbind(mk(3.2, 4.0), pop = "B")
C <- cbind(mk(4.4, 4.8), pop = "C")
d <- rbind(A, B, C)
cols <- c(A = "#e67e22", B = "#2980b9", C = "#27ae60")

out <- "pics/biology/simpson_penguins.png"
png(out, width = 1100, height = 480, res = 120)
par(mfrow = c(1, 2), mar = c(4.2, 4.2, 3.5, 1), family = "sans")

plot(
  d$x, d$y, pch = 16, col = "#7f8c8d",
  xlab = "Schnabellänge (rel.)", ylab = "Schnabeltiefe (rel.)",
  main = "Alle Pinguine zusammen", cex = 0.9,
  xlim = c(1.2, 5.4), ylim = c(1.8, 5.8)
)
abline(lm(y ~ x, d), lwd = 3, col = "#c0392b")
mtext("Trend insgesamt: positiv?", side = 3, line = 0.2, col = "#c0392b", cex = 0.9)

plot(
  d$x, d$y, pch = 16, col = cols[d$pop],
  xlab = "Schnabellänge (rel.)", ylab = "Schnabeltiefe (rel.)",
  main = "Nach Population / Art", cex = 0.9,
  xlim = c(1.2, 5.4), ylim = c(1.8, 5.8)
)
for (p in c("A", "B", "C")) {
  di <- d[d$pop == p, ]
  abline(lm(y ~ x, di), lwd = 2.5, col = cols[p])
}
legend("topleft", legend = c("Pop A", "Pop B", "Pop C"), col = cols, pch = 16, bty = "n", cex = 0.9)
mtext("Innerhalb jeder Gruppe: negativ!", side = 3, line = 0.2, col = "#196f3d", cex = 0.9)
dev.off()
message("wrote ", out)

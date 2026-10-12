# Recall figure for Woche 5: Checkpoint A Zeitreihe + Simplex
make_rps_A <- function(s, w) {
  matrix(c(1, w, s, s, 1, w, w, s, 1), 3, 3, byrow = TRUE)
}
next_rps <- function(N, r, A, C = 2) {
  sN <- sum(N)
  if (sN <= 0) return(N)
  p <- N / sN
  W <- C - as.numeric(A %*% p)
  Wbar <- sum(p * W)
  pmax(N + r * N * (W - Wbar), 0)
}
simulate_rps <- function(N0, r, A, T = 2000, C = 2) {
  n <- length(N0)
  N <- matrix(0, T + 1, n)
  N[1, ] <- N0
  for (t in 1:T) N[t + 1, ] <- next_rps(N[t, ], r, A, C)
  N
}
to_simplex_xy <- function(N) {
  s <- pmax(rowSums(N), 1e-12)
  f <- N / s
  cbind(x = f[, 1] * 0.5 + f[, 3] * 1, y = f[, 1] * (sqrt(3) / 2))
}

out <- "weeks/week-05/figs/checkpoint_rps_traj_simplex.png"
s <- 1.35
w <- 0.65
A <- make_rps_A(s, w)
N <- simulate_rps(c(40, 35, 30), r = 0.05, A = A, T = 2500)
cols <- c("#e67e22", "#2980b9", "#f1c40f")

png(out, width = 1400, height = 560, res = 160)
par(mfrow = c(1, 2), mar = c(4.2, 4.2, 2.6, 0.8), mgp = c(2.2, 0.7, 0))

pN <- N / rowSums(N)
matplot(
  0:(nrow(pN) - 1), pN,
  type = "l", lty = 1, lwd = 2.4, col = cols,
  xlab = "Zeit", ylab = "Anteil",
  main = "Zeitreihe (Checkpoint)", ylim = c(0, 1),
  cex.lab = 1.05, cex.main = 1.1
)
legend(
  "topright", c("Typ 1", "Typ 2", "Typ 3"),
  col = cols, lty = 1, lwd = 2.4, bty = "n", cex = 0.85
)

xy <- to_simplex_xy(N)
v1 <- c(0.5, sqrt(3) / 2)
v2 <- c(0, 0)
v3 <- c(1, 0)
plot(
  NA,
  xlim = c(-0.08, 1.08), ylim = c(-0.12, sqrt(3) / 2 + 0.1),
  asp = 1, axes = FALSE, xlab = "", ylab = "",
  main = "Simplex (Checkpoint)"
)
polygon(
  c(v1[1], v2[1], v3[1]), c(v1[2], v2[2], v3[2]),
  border = "#2c3e50", lwd = 2, col = "#f4f6f7"
)
text(v1[1], v1[2] + 0.07, "1", col = cols[1], font = 2, cex = 1.2)
text(v2[1] - 0.06, v2[2] - 0.05, "2", col = cols[2], font = 2, cex = 1.2)
text(v3[1] + 0.06, v3[2] - 0.05, "3", col = cols[3], font = 2, cex = 1.2)
n <- nrow(xy)
step <- max(1L, floor(n / 900))
idx <- seq(1L, n - 1L, by = step)
for (k in seq_along(idx)) {
  i <- idx[k]
  j <- if (k < length(idx)) idx[k + 1] else n
  a <- 0.15 + 0.75 * (i / n)
  segments(
    xy[i, 1], xy[i, 2], xy[j, 1], xy[j, 2],
    col = rgb(0.12, 0.15, 0.22, a), lwd = 1.7
  )
}
points(xy[1, 1], xy[1, 2], pch = 16, col = "#27ae60", cex = 1.3)
points(xy[n, 1], xy[n, 2], pch = 16, col = "#c0392b", cex = 1.2)
dev.off()
message("wrote ", out)

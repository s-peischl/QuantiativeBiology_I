# Woche 4 Checkpoint A — nur R (base R, keine Packages)
# In RStudio: Source, dann s und w setzen und show_rps / show_two aufrufen.

make_rps_A <- function(s, w) {
  matrix(c(1, w, s,
           s, 1, w,
           w, s, 1), 3, 3, byrow = TRUE)
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

plot_3lv <- function(N, main = "") {
  cols <- c("#e67e22", "#2980b9", "#f1c40f")
  matplot(0:(nrow(N) - 1), N, type = "l", lty = 1, lwd = 2.2,
          col = cols[seq_len(ncol(N))],
          xlab = "Zeit", ylab = "Haeufigkeit", main = main,
          ylim = c(0, max(N) * 1.05))
  legend("topright", paste0("Typ ", seq_len(ncol(N))),
         col = cols[seq_len(ncol(N))], lty = 1, lwd = 2.2,
         bty = "n", cex = 0.8)
}

to_simplex_xy <- function(N) {
  s <- pmax(rowSums(N), 1e-12)
  f <- N / s
  cbind(
    x = f[, 1] * 0.5 + f[, 3] * 1,
    y = f[, 1] * (sqrt(3) / 2)
  )
}

plot_simplex <- function(N, main = "") {
  cols <- c("#e67e22", "#2980b9", "#f1c40f")
  xy <- to_simplex_xy(N)
  v1 <- c(0.5, sqrt(3) / 2)
  v2 <- c(0, 0)
  v3 <- c(1, 0)
  plot(NA, xlim = c(-0.08, 1.08), ylim = c(-0.12, sqrt(3) / 2 + 0.1),
       asp = 1, axes = FALSE, xlab = "", ylab = "", main = main)
  polygon(c(v1[1], v2[1], v3[1]), c(v1[2], v2[2], v3[2]),
          border = "#2c3e50", lwd = 2, col = "#f4f6f7")
  text(v1[1], v1[2] + 0.07, "1", col = cols[1], font = 2)
  text(v2[1] - 0.06, v2[2] - 0.05, "2", col = cols[2], font = 2)
  text(v3[1] + 0.06, v3[2] - 0.05, "3", col = cols[3], font = 2)
  n <- nrow(xy)
  if (n > 40) {
    step <- max(1L, floor(n / 900))
    idx <- seq(1L, n - 1L, by = step)
    for (k in seq_along(idx)) {
      i <- idx[k]
      j <- if (k < length(idx)) idx[k + 1] else n
      a <- 0.15 + 0.75 * (i / n)
      segments(xy[i, 1], xy[i, 2], xy[j, 1], xy[j, 2],
               col = rgb(0.12, 0.15, 0.22, a), lwd = 1.6)
    }
  } else {
    lines(xy[, 1], xy[, 2], lwd = 2, col = "#2c3e50")
  }
  points(xy[1, 1], xy[1, 2], pch = 16, col = "#27ae60", cex = 1.2)
  points(xy[n, 1], xy[n, 2], pch = 16, col = "#c0392b", cex = 1.1)
}

show_two <- function(s, w, r = 0.05, T = 800) {
  A <- make_rps_A(s, w)
  print(A)
  starts <- list(c(40, 35, 0), c(0, 40, 35), c(35, 0, 40))
  titles <- c("nur 1 und 2", "nur 2 und 3", "nur 1 und 3")
  par(mfrow = c(1, 3), mar = c(4, 4, 2.4, 0.8))
  for (i in seq_along(starts)) {
    plot_3lv(simulate_rps(starts[[i]], r, A, T = T), main = titles[i])
  }
}

show_rps <- function(s, w, r = 0.05, T = 2500, N0 = c(40, 35, 30)) {
  A <- make_rps_A(s, w)
  print(A)
  N <- simulate_rps(N0, r, A, T = T)
  par(mfrow = c(1, 2), mar = c(4, 4, 2.4, 0.8))
  plot_3lv(N, main = paste0("s=", s, ", w=", w))
  plot_simplex(N, main = "Simplex")
}

show_flex <- function(A12, A13, A21, A23, A31, A32,
                      N0 = c(40, 35, 30), T = 2500, r = 0.05) {
  A <- matrix(c(1, A12, A13,
                A21, 1, A23,
                A31, A32, 1), 3, 3, byrow = TRUE)
  print(A)
  N <- simulate_rps(N0, r, A, T = T)
  par(mfrow = c(1, 2), mar = c(4, 4, 2.4, 0.8))
  plot_3lv(N, main = "freie Matrix")
  plot_simplex(N, main = "Simplex")
}

# --- hier s und w setzen (s > 1 > w) ---

s <- 1.5
w <- 0.5

show_two(s, w)
show_rps(s, w)

# show_rps(s, w)   # Versuch 2: andere s, w
# show_rps(s, w)   # Versuch 3: andere s, w

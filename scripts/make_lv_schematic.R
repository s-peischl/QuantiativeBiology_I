# Lotka-Volterra teaching figure: time series + phase cycle
out <- "pics/biology/lotka_volterra_cycles.png"
dir.create("pics/biology", showWarnings = FALSE, recursive = TRUE)

lv <- function(t, y, parms) {
  N <- y[1]; P <- y[2]
  with(as.list(parms), {
    dN <- r * N - a * N * P
    dP <- b * a * N * P - m * P
    list(c(dN, dP))
  })
}

# simple Euler integration (no deSolve dependency)
parms <- list(r = 1.0, a = 0.1, b = 0.5, m = 0.5)
dt <- 0.01
T <- 40
n <- as.integer(T / dt)
N <- numeric(n); P <- numeric(n); time <- numeric(n)
N[1] <- 10; P[1] <- 5; time[1] <- 0
for (i in 2:n) {
  dN <- parms$r * N[i - 1] - parms$a * N[i - 1] * P[i - 1]
  dP <- parms$b * parms$a * N[i - 1] * P[i - 1] - parms$m * P[i - 1]
  N[i] <- max(N[i - 1] + dt * dN, 1e-6)
  P[i] <- max(P[i - 1] + dt * dP, 1e-6)
  time[i] <- time[i - 1] + dt
}

png(out, width = 1100, height = 480, res = 120)
par(mfrow = c(1, 2), mar = c(4.2, 4.2, 3.2, 1), family = "sans")

plot(time, N, type = "l", lwd = 2.5, col = "#2980b9",
     xlab = "Zeit", ylab = "Dichte", ylim = range(c(N, P)),
     main = "Zeitreihe (Beute / Räuber)")
lines(time, P, lwd = 2.5, col = "#c0392b")
legend("topright", legend = c("Beute N", "Räuber P"),
       col = c("#2980b9", "#c0392b"), lwd = 2.5, bty = "n")

plot(N, P, type = "l", lwd = 2, col = "#7f8c8d",
     xlab = "Beute N", ylab = "Räuber P",
     main = "Phasenraum: Zyklus")
points(N[1], P[1], pch = 16, col = "#27ae60", cex = 1.3)
text(N[1], P[1], " Start", pos = 4, col = "#196f3d", cex = 0.9)
dev.off()
message("wrote ", out)

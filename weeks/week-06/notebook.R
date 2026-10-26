# Woche 6 — Notebook (nur R, base R)
# Inhalt: konstante Fitness · RPS mit 3 Allelen · Plastizitaet (Corl)
# In RStudio: Working Directory = weeks/week-06, dann Source.
# Keine Abgabe. Nur markierte Parameter aendern.

cols <- c("#e67e22", "#2980b9", "#c9a227")

# =============================================================================
# 1 · Was macht die Heterozygote?
# =============================================================================

# Eine Generation: Allelfrequenz p nach Selektion mit Fitness w = (w_AA, w_Aa, w_aa)
selektionsschritt <- function(p, w) {
  q <- 1 - p
  wbar <- p^2 * w[1] + 2 * p * q * w[2] + q^2 * w[3]  # mittlere Fitness
  (p^2 * w[1] + p * q * w[2]) / wbar                     # Beitrag von A
}

# Bahn von p über mehrere Generationen
simuliere_w <- function(p0, w, gen = 200) {
  p <- numeric(gen + 1)
  p[1] <- p0
  for (t in seq_len(gen)) p[t + 1] <- selektionsschritt(p[t], w)
  p
}

# Homozygote fest; Heterozygote frei waehlen
w_AA <- 1.0
w_aa <- 0.9
w_Aa <- 1.1   # <- aendern (z.B. 0.5, 0.95, 1.1)
w <- c(w_AA, w_Aa, w_aa)
starts <- c(0.05, 0.2, 0.5, 0.8, 0.95)   # Startwerte gleich lassen

plot(NA, xlim = c(0, 200), ylim = c(0, 1),
     xlab = "Generation", ylab = "Allelfrequenz p",
     main = sprintf("Relative Fitness w = (%.2f, %.2f, %.2f)", w[1], w[2], w[3]))
abline(h = c(0, 1), col = "grey85")
for (p0 in starts) {
  lines(0:200, simuliere_w(p0, w), lwd = 2, col = "#2166ac")
}

# F1:
# 1. Homozygote bei 1 und 0.9 belassen; nur w_Aa aendern.
# 2. Wann bleibt Vielfalt? Wann wandert p an den Rand?

# =============================================================================
# 2 · Von Strategien zur Vererbung
# =============================================================================
# O > B → orange; B > Y → blau; Y > O → gelb

# RPS-Auszahlungsmatrix (Kosten): s > 1 stark, w < 1 schwach
make_rps_A <- function(s, w) {
  matrix(c(1, w, s, s, 1, w, w, s, 1), 3, byrow = TRUE)
}

# Reine Strategien (wie Woche 4)
simuliere_strategie <- function(f0, s, w, gen = 400, C = 2) {
  F <- matrix(NA_real_, gen + 1, 3)
  F[1, ] <- f0 / sum(f0)
  for (t in seq_len(gen)) {
    W <- C - as.vector(make_rps_A(s, w) %*% F[t, ])
    f1 <- F[t, ] * W
    F[t + 1, ] <- f1 / sum(f1)
  }
  F
}

# Allelfrequenzen → Morphanteile unter zyklischer Dominanz
morphen_3allel <- function(p) {
  o <- p[1]; b <- p[2]; y <- p[3]
  c(o^2 + 2 * o * b,   # orange: OO, OB
    b^2 + 2 * b * y,   # blau:   BB, BY
    y^2 + 2 * y * o)   # gelb:   YY, YO
}

# Drei Allele: HWE → Morphen → Fitness → Genotypselektion → neue Allelfrequenzen
simuliere_3allel <- function(p0, s, w, gen = 400, C = 2) {
  P <- matrix(NA_real_, gen + 1, 3)
  P[1, ] <- p0 / sum(p0)
  for (t in seq_len(gen)) {
    o <- P[t, 1]; b <- P[t, 2]; y <- P[t, 3]
    f <- morphen_3allel(P[t, ])
    Wm <- C - as.vector(make_rps_A(s, w) %*% f)
    g <- c(o^2, 2 * o * b, 2 * o * y, b^2, 2 * b * y, y^2)
    Wg <- c(Wm[1], Wm[1], Wm[3], Wm[2], Wm[2], Wm[3])
    g1 <- g * Wg / sum(g * Wg)
    P[t + 1, ] <- c(
      g1[1] + 0.5 * g1[2] + 0.5 * g1[3],
      g1[4] + 0.5 * g1[2] + 0.5 * g1[5],
      g1[6] + 0.5 * g1[3] + 0.5 * g1[5]
    )
  }
  P
}

s <- 1.5   # <- aendern
w <- 0.3   # <- aendern
f0 <- c(0.4, 0.35, 0.25)

F_s <- simuliere_strategie(f0, s, w)
M_g <- t(apply(simuliere_3allel(f0, s, w), 1, morphen_3allel))

par(mfrow = c(1, 2), mar = c(4, 4, 2.5, 0.8))
matplot(0:400, F_s, type = "l", lty = 1, lwd = 2, col = cols,
        xlab = "Generation", ylab = "Anteil", ylim = c(0, 1),
        main = paste0("reine Strategien (s=", s, ", w=", w, ")"))
matplot(0:400, M_g, type = "l", lty = 1, lwd = 2, col = cols,
        xlab = "Generation", ylab = "Anteil", ylim = c(0, 1),
        main = "drei Allele mit Dominanz")
par(mfrow = c(1, 1))

# F2:
# 1. Was bleibt gleich zwischen den Panels, was aendert sich?
# 2. Mindestens ein zweites Paar (s, w) ausprobieren.

# =============================================================================
# 3 · Plastizitaet statt eines dritten Allels
# =============================================================================

# Haplotypfrequenz p (Anteil O): Morphanteile mit Plastizitaet theta
farben_theta <- function(p, theta) {
  q <- 1 - p
  c(p^2 + 2 * p * q,       # orange: alles mit mindestens einem O
    (1 - theta) * q^2,     # blau: Anteil (1 - theta) der BB
    theta * q^2)           # gelb: Anteil theta der BB
}

# Eine Frequenz p; Fitness von B ist der Mittelwert aus blau und gelb
simuliere_theta <- function(p0, theta, s, w, gen = 400, C = 2) {
  p <- numeric(gen + 1)
  p[1] <- p0
  for (t in seq_len(gen)) {
    f <- farben_theta(p[t], theta)
    W <- C - as.vector(make_rps_A(s, w) %*% f)
    wO <- W[1]
    wB <- (1 - theta) * W[2] + theta * W[3]
    q <- 1 - p[t]
    p[t + 1] <- p[t] * wO / ((p[t]^2 + 2 * p[t] * q) * wO + q^2 * wB)
  }
  p
}

theta <- 0.48   # <- aendern
s3 <- 1.5         # gleiche Matrix-Staerke wie Abschnitt 2
w3 <- 0.3

plot_theta <- function(th) {
  p <- simuliere_theta(0.5, th, s3, w3)
  M <- t(sapply(p, function(pi) farben_theta(pi, th)))
  matplot(0:400, M, type = "l", lty = 1, lwd = 2, col = cols,
          xlab = "Generation", ylab = "Morphanteil", ylim = c(0, 1),
          main = paste0("theta = ", th, " (s=", s3, ", w=", w3, ")"))
  legend("right", c("orange", "blau", "gelb"),
         col = cols, lty = 1, lwd = 2, bty = "n")
}

par(mfrow = c(1, 2), mar = c(4, 4, 2.5, 0.8))
plot_theta(theta)
plot_theta(0)
par(mfrow = c(1, 1))

# F3:
# 1. Vergleich mit Abschnitt 2.
# 2. Was aendert sich bei theta = 0 (keine gelbe Morphe)?

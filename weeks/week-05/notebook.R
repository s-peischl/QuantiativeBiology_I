# Woche 5 — Notebook (nur R, base R)
# Inhalt: Hardy–Weinberg · Blutgruppen · Avocado (Groh et al. 2026)
# In RStudio: Working Directory = weeks/week-05, dann Source.

## Ziel
# - Hardy–Weinberg rechnen und vergleichen
# - Annahmen verstehen; Beispiele wo sie gelten / verletzt sind

## Die Groessen
# Zwei Allele A und B. Zaehlungen AA, AB, BB.
# Relative Haeufigkeit: Zaehlung / n
# Allelfrequenz: p = (2*n_AA + n_AB) / (2*n)
# HWE-Erwartung: p^2, 2pq, q^2

# =============================================================================
# Teil A — theoretische Grundlagen
# =============================================================================

## A1) Genotypzaehlungen
pop <- data.frame(AA = 16, AB = 48, BB = 36)

# F1: Relative Genotypfrequenzen von Hand (AA/n, ...)

## A2) Hardy–Weinberg
zusammenfassen <- function(d) {
  n <- d$AA + d$AB + d$BB
  p <- (2 * d$AA + d$AB) / (2 * n)
  data.frame(
    n = n,
    p = p,
    f_AA = d$AA / n,
    f_AB = d$AB / n,
    f_BB = d$BB / n,
    hwe_AA = p^2,
    hwe_AB = 2 * p * (1 - p),
    hwe_BB = (1 - p)^2
  )
}

zusammenfassen(pop)

# F2:
# 1. Stimmen beobachtet und erwartet ueberein?
# 2. Warum steht im Nenner von p die 2n?
# 3. Welche Annahmen stecken dahinter? (Vorlesung)

# =============================================================================
# Teil B — Blutgruppen (Mourant et al. 1976)
# =============================================================================

bloodgroups_world <- read.csv("data/bloodgroups_Mourant1976_world.csv")
bloodgroups_world

zusammenfassen_MN <- function(d) {
  n <- d$MM + d$MN + d$NN
  p <- (2 * d$MM + d$MN) / (2 * n)
  data.frame(
    Country = d$Country,
    n = n,
    p = p,
    f_MM = d$MM / n,
    f_MN = d$MN / n,
    f_NN = d$NN / n,
    hwe_MM = p^2,
    hwe_MN = 2 * p * (1 - p),
    hwe_NN = (1 - p)^2
  )
}

## B1) Schweiz
HW_CH <- zusammenfassen_MN(
  bloodgroups_world[bloodgroups_world$Country == "Switzerland", ]
)
HW_CH

# F3: Stimmen beobachtet und erwartet ueberein?

## B2) Welt
HW_world <- zusammenfassen_MN(bloodgroups_world)
HW_world

p_grid <- seq(0, 1, length.out = 201)
plot(
  x = p_grid,
  y = 2 * p_grid * (1 - p_grid),
  type = "l", lwd = 2.5,
  col = "#1b9e77", ylim = c(0, 0.8),
  xlab = "p", ylab = "Heterozygotenanteil",
  main = "HWE-Kurve weltweite Beobachtungen"
)
points(HW_world$p, HW_world$f_MN, pch = 16, cex = 1.6, col = "#2166ac")
points(HW_CH$p, HW_CH$f_MN, pch = 16, cex = 1.6, col = "#8500ac")
legend(
  "topright", c("HWE", "Weltweit", "Schweiz"),
  col = c("#1b9e77", "#2166ac", "#8500ac"),
  lwd = c(2.5, NA, NA), pch = c(NA, 16, 16), bty = "n"
)

# F4:
# 1. Wie verhalten sich die Punkte zur HWE-Kurve?
# 2. Welche Annahmen sind erfuellt / verletzt?

# =============================================================================
# Teil C — Avocados (Groh et al. 2026)
# =============================================================================
# Typ A: A1A1 oder A1A2  |  Typ B: A2A2
# Abbildung (optional): data/grafik_Avocados.png

avocados <- data.frame(A1A1 = 5, A1A2 = 33, A2A2 = 62)

zusammenfassen_avo <- function(d) {
  n <- d$A1A1 + d$A1A2 + d$A2A2
  p <- (2 * d$A1A1 + d$A1A2) / (2 * n)
  data.frame(
    n = n,
    p = p,
    f_A1A1 = d$A1A1 / n,
    f_A1A2 = d$A1A2 / n,
    f_A2A2 = d$A2A2 / n,
    hwe_A1A1 = p^2,
    hwe_A1A2 = 2 * p * (1 - p),
    hwe_A2A2 = (1 - p)^2
  )
}

HW_avocados <- zusammenfassen_avo(avocados)
HW_avocados

# F5:
# 1. Stimmen beobachtet und erwartet ueberein?
# 2. Erwartete Verteilung Typ A vs Typ B?

# Zuechter-Erwartung fuer geerntete Fruechte:
#   A1A1 = 0,  A1A2 = 0.525,  A2A2 = 0.475

# F6:
# 1. Unterschied zu Ihren HWE-Erwartungen?
# 2. Welche HWE-Annahmen sind erfuellt / eventuell nicht — und warum?

# =============================================================================
# Zusammenfassung
# =============================================================================
# Wenn gemessene Frequenzen nicht zu HWE passen, ist das ein Hinweis,
# dass nicht alle Annahmen erfuellt sind.

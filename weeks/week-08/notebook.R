# Woche 8 — Notebook · Checkpoint B (nur R, base R)
# Sommer und Winter: eine Resistenz-Cline bei Stechmuecken
# In RStudio: Working Directory = weeks/week-08, dann Source.
# Kein Programmieren: nur ausfuehren und im Teil 2 eine Zahl aendern.
#
# Rund um Montpellier wurde gegen Stechmuecken Insektizid gespritzt, auf dem
# Land nicht. In der Stadt ist das Resistenz-Allel R im Vorteil, auf dem
# Land kostet es etwas. Die Muecken fliegen hin und her.
#
# Entlang eines Transekts von 17 Stellen wurde der Anteil von R gemessen —
# einmal im Sommer, einmal im Winter. Die beiden Kurven sehen verschieden
# aus.
#
# Ihr Auftrag (kein Programmieren, nur Code ausfuehren und eine Zahl
# aendern):
#
# 1. Abbildung 1: Sommer und Winter mit angepassten Kurven. Was ist im
#    Winter anders?
# 2. Abbildung 2: Im Modell eine Zahl aendern, bis die Winter-Kurve passt —
#    einmal s kleiner, einmal m groesser.
# 3. Erklaeren Sie der Assistenz in 1–2 Minuten mit einer Abbildung: Warum
#    sieht der Winter anders aus?

# ===========================================================================
# 0 · Daten und Funktionen (einfach ausfuehren)
# ===========================================================================

# Position in km: links (x < 0) Land ohne Insektizid, rechts (x > 0) Stadt mit Insektizid
x <- seq(-8, 8, by = 1)
n <- 40   # typisierte Allele pro Stelle

# Anzahl Resistenz-Allele R pro Stelle (Daten: TAs)
k_sommer <- c(0, 0, 0, 0, 0, 0, 3, 10, 15, 27, 39, 37, 40, 39, 40, 40, 40)
k_winter <- c(0, 1, 0, 3, 5, 7, 7, 14, 16, 24, 30, 36, 32, 32, 38, 37, 40)

sommer <- data.frame(x = x, p = k_sommer / n)
winter <- data.frame(x = x, p = k_winter / n)

# --- Hilfsfunktionen (nicht veraendern) ---

farben <- c(Sommer = "#d95f02", Winter = "#2166ac")

# Logistische Kurve: c = Zentrum (p = 0.5), b = Steilheit, Breite = 4 / b
logistisch <- function(x, c, b) 1 / (1 + exp(-b * (x - c)))

passe_an <- function(d) {
  nls(p ~ logistisch(x, c, b), data = d, start = list(c = 0, b = 1))
}

zeige_clines <- function(main = "Resistenz entlang des Transekts") {
  plot(sommer$x, sommer$p, pch = 16, col = farben["Sommer"], ylim = c(0, 1),
       xlab = "Position (km): links Land, rechts Stadt mit Insektizid",
       ylab = "Frequenz des Resistenz-Allels R", main = main)
  points(winter$x, winter$p, pch = 17, col = farben["Winter"])
  abline(v = 0, lty = 3, col = "grey60")
  legend("topleft", c("Sommer", "Winter"), pch = c(16, 17),
         col = farben, bty = "n")
}

vergleiche_clines <- function() {
  fit_s <- passe_an(sommer)
  fit_w <- passe_an(winter)
  zeige_clines(main = "Daten und angepasste Kurven")
  x_fein <- seq(-8, 8, length.out = 200)
  lines(x_fein, predict(fit_s, data.frame(x = x_fein)),
        col = farben["Sommer"], lwd = 2.2)
  lines(x_fein, predict(fit_w, data.frame(x = x_fein)),
        col = farben["Winter"], lwd = 2.2)
  tab <- rbind(Sommer = coef(fit_s), Winter = coef(fit_w))
  data.frame(zentrum_km = round(tab[, "c"], 1),
             breite_km  = round(4 / tab[, "b"], 1))
}

# Modell wie Woche 7, aber 17 Stellen in einer Reihe:
# 1. Selektion lokal: in der Stadt ist R besser, auf dem Land A
# 2. Migration: Anteil m/2 fliegt zu jeder Nachbarstelle
selektionsschritt <- function(p, w) {
  q <- 1 - p
  w_quer <- p^2 * w[1] + 2 * p * q * w[2] + q^2 * w[3]
  (p^2 * w[1] + p * q * w[2]) / w_quer
}

simuliere_cline <- function(s, m, generationen = 3000) {
  p <- rep(0.5, length(x))
  for (t in seq_len(generationen)) {
    for (i in seq_along(x)) {
      w <- if (x[i] > 0) c(1 + s, 1 + s / 2, 1) else c(1, 1 + s / 2, 1 + s)
      if (x[i] == 0) w <- c(1, 1, 1)
      p[i] <- selektionsschritt(p[i], w)
    }
    links  <- c(p[1], p[-length(p)])
    rechts <- c(p[-1], p[length(p)])
    p <- (1 - m) * p + m / 2 * links + m / 2 * rechts
  }
  p
}

zeige_modell <- function(s, m) {
  zeige_clines(main = paste0("Modell (schwarz): s = ", s, ", m = ", m))
  lines(x, simuliere_cline(s, m), col = "grey15", lwd = 2.2, type = "b",
        pch = 1)
}

# ===========================================================================
# 1 · Abbildung 1: Sommer und Winter
# ===========================================================================
# Die Punkte sind die Messungen. Die Linien sind logistische Kurven, die R
# an die Punkte anpasst. Zwei Zahlen fassen eine Kurve zusammen:
#
# - Zentrum: wo die Frequenz 0.5 ist,
# - Breite: wie lang der Uebergang vom Land zur Stadt ist.

print(vergleiche_clines())

# F1: Was ist an der Winter-Kurve anders: das Zentrum, die Breite oder beides?

# ===========================================================================
# 2 · Abbildung 2: Selektion oder Migration?
# ===========================================================================
# Das Modell ist dasselbe wie in Woche 7 — nur mit 17 Stellen in einer Reihe
# statt zwei Habitaten:
#
# - s = Selektion: wie stark R in der Stadt hilft (und auf dem Land
#    schadet),
# - m = Migration: wie viele Muecken pro Generation zur Nachbarstelle
#    fliegen.
#
# Mit s = 0.1 und m = 0.1 passt das Modell zum Sommer. Aendern Sie fuer den
# Winter jeweils nur eine Zahl.

zeige_modell(s = 0.1, m = 0.1)   # Sommer
zeige_modell(s = 0.1, m = 0.1)   # Versuch A: nur s kleiner machen
zeige_modell(s = 0.1, m = 0.1)   # Versuch B: nur m groesser machen

# F2: Welche Aenderung im Modell erzeugt die Winter-Kurve: s kleiner oder m
# groesser? Klappt beides?

# ===========================================================================
# 3 · Ihre Erklaerung
# ===========================================================================
# F3: Was ist biologisch plausibler? Tipp: Was passiert im Winter mit dem
# Insektizid — und fliegen Muecken im Winter mehr?
#
# Woche 7: Fuer das Gleichgewicht zaehlte vor allem das Verhaeltnis m/s.
#
# Fuer das Gespraech (1-2 Minuten): eine Abbildung zeigen und drei Saetze
# sagen — was ist anders, welche Aenderung im Modell passt, warum ist das
# biologisch plausibel.

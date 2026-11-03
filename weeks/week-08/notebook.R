# Woche 8 — Notebook · Checkpoint B (nur R, base R)
# Sommer und Winter: eine Resistenz-Cline bei Stechmuecken
# In RStudio: Working Directory = weeks/week-08, dann Zeile fuer Zeile ausfuehren.
# Kein Programmieren: nur ausfuehren und Zahlen aendern.

# In der Stadt wird gegen Muecken Insektizid gespritzt, auf dem Land nicht. Der Anteil des Resistenz-Allels R wurde an 17 Stellen vom Land bis in die Stadt gemessen, im Sommer und im Winter. Warum sehen die beiden Clines verschieden aus?

# --- Auftrag ---
#
# 1. Finden Sie Parameterwerte s und m, mit denen das Modell zur Sommer-Cline passt, und solche fuer die Winter-Cline.
# 2. Welche Parameter haben Sie gefunden? Tragen Sie sie in die Tabelle ein.
# 3. Sind diese Parameter plausibel?
#
# Erklaeren Sie das der Assistenz in 1–2 Minuten mit einer Abbildung.

# ===========================================================================
# 0 · Daten und Funktionen
# ===========================================================================
#
# Einfach ausfuehren (Kursdaten, erfunden).

# Position in km: links (x < 0) Land ohne Insektizid, rechts (x > 0) Stadt mit Insektizid
x <- seq(-8, 8, by = 1)
n <- 40   # untersuchte Allele (Genkopien) pro Stelle

# Anzahl Resistenz-Allele R pro Stelle (Kursdaten)
k_sommer <- c(0, 0, 0, 0, 0, 0, 3, 10, 15, 27, 39, 37, 40, 39, 40, 40, 40)
k_winter <- c(0, 1, 0, 3, 5, 7, 7, 14, 16, 24, 30, 36, 32, 32, 38, 37, 40)

sommer <- data.frame(x = x, p = k_sommer / n)
winter <- data.frame(x = x, p = k_winter / n)

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
# 1. Selektion lokal: in der Stadt ist R besser, auf dem Land r
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

# Abstand zwischen Modell und Daten (kleiner = passt besser)
abstand <- function(p_modell, daten) round(sum((p_modell - daten$p)^2), 3)

zeige_modell <- function(s, m) {
  p_modell <- simuliere_cline(s, m)
  zeige_clines(main = paste0("Modell (schwarz): s = ", s, ", m = ", m,
                             ",  m/s = ", round(m / s, 1)))
  lines(x, p_modell, col = "grey15", lwd = 2.2, type = "b", pch = 1)
  mtext(paste0("Abstand zum Sommer: ", abstand(p_modell, sommer),
               "   zum Winter: ", abstand(p_modell, winter),
               "   (kleiner = passt besser)"), side = 3, line = 0.2, cex = 0.85)
}

# ===========================================================================
# 1 · Die Daten
# ===========================================================================

vergleiche_clines()

# Die Tabelle unter der Abbildung zeigt Zentrum und Breite der beiden Clines.

# ===========================================================================
# 2 · Parameter finden
# ===========================================================================
#
# Das Modell ist wie in Woche 7, nur mit 17 Stellen in einer Reihe:
#
# - s = Selektion: wie stark R in der Stadt hilft (und auf dem Land schadet),
# - m = Migration: welcher Anteil der Muecken pro Generation zu den Nachbarstellen fliegt.
#
# Aendern Sie s und m und fuehren Sie den Block erneut aus. Ueber der Abbildung steht der Abstand zu den Sommer- und Winter-Daten: Unter etwa 0.06 passt das Modell.

zeige_modell(s = 0.2, m = 0.05)   # hier s und m aendern

# Tipp: Aendern Sie zuerst nur eine Zahl. Es gibt mehr als eine Loesung. Suchen Sie fuer den Winter zwei verschiedene.

# --- F1 · Welche Parameter haben Sie gefunden? ---
#
# |  | s | m | m/s | Abstand |
# | Sommer |  |  |  |  |
# | Winter, Loesung 1 |  |  |  |  |
# | Winter, Loesung 2 |  |  |  |  |
#
# Was haben alle Ihre Winter-Loesungen gemeinsam? Und was unterscheidet sie vom Sommer?

# ===========================================================================
# 3 · Sind die Parameter plausibel?
# ===========================================================================
#
# Im Winter fliegen die Muecken weniger als im Sommer, m ist also eher kleiner. Probieren Sie m halb so gross wie in Ihrer Sommer-Loesung und suchen Sie das passende s.

zeige_modell(s = 0.1, m = 0.05)   # hier s aendern

# --- F2 · Plausibel? ---
#
# - Welche Ihrer Winter-Loesungen passt dazu, dass die Muecken weniger fliegen?
# - Wie stark ist die Selektion im Winter im Vergleich zum Sommer? Warum ist das plausibel? (Tipp: Wird im Winter gespritzt?)

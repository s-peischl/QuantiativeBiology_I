# Woche 8 — Notebook · Checkpoint B (nur R, base R)
# Sommer und Winter: eine Resistenz-Cline bei Stechmuecken
# In RStudio: Working Directory = weeks/week-08, dann Zeile fuer Zeile ausfuehren.
# Kein Programmieren: nur ausfuehren und in Teil 2 eine Zahl aendern.

# Rund um Montpellier wird gegen Stechmuecken Insektizid gespritzt, auf dem Land nicht. In der Stadt ist das Resistenz-Allel R im Vorteil, auf dem Land kostet es etwas. Die Muecken fliegen hin und her — wie in Woche 7.
#
# Entlang einer Strecke von 17 Stellen (vom Land bis in die Stadt) wurde der Anteil von R gemessen, einmal im Sommer und einmal im Winter. Die beiden Kurven sehen verschieden aus. Warum?

# --- Auftrag ---
#
# Kein Programmieren: Sie fuehren nur Code aus und aendern Zahlen.
#
# 1. Teil 1: Abbildung 1 erzeugen. Was ist im Winter anders? -> F1
# 2. Teil 2: Im Modell s und m aendern (beide gleich, nur s, nur m) und die Werte in eine Tabelle eintragen. -> F2
# 3. Teil 3: Mit biologischem Wissen entscheiden, was sich im Winter geaendert hat. -> F3
# 4. Gespraech: Der Assistenz in 1–2 Minuten mit einer Abbildung erklaeren, warum der Winter anders aussieht.

# ===========================================================================
# 0 · Daten und Funktionen
# ===========================================================================
#
# Einfach ausfuehren. Die Daten sind fuer den Kurs erfunden, aber realistisch.

# Position in km: links (x < 0) Land ohne Insektizid, rechts (x > 0) Stadt mit Insektizid
x <- seq(-8, 8, by = 1)
n <- 40   # typisierte Allele pro Stelle

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
# 1 · Abbildung 1: Sommer und Winter
# ===========================================================================
#
# Die Punkte sind die Messungen. Die Linien sind logistische Kurven, die R an die Punkte anpasst. Zwei Zahlen fassen eine Kurve zusammen:
#
# - Zentrum: wo die Frequenz 0.5 ist,
# - Breite: wie lang der Uebergang vom Land zur Stadt ist.

vergleiche_clines()

# --- F1 ---
#
# Lesen Sie die Tabelle unter der Abbildung. Was ist an der Winter-Kurve anders: das Zentrum, die Breite oder beides?

# ===========================================================================
# 2 · Abbildung 2: Selektion oder Migration?
# ===========================================================================
#
# Das Modell ist dasselbe wie in Woche 7, nur mit 17 Stellen in einer Reihe statt zwei Habitaten:
#
# - s = Selektion: wie stark R in der Stadt hilft (und auf dem Land schadet),
# - m = Migration: welcher Anteil der Muecken pro Generation zu den Nachbarstellen fliegt.
#
# Mit s = 0.1 und m = 0.1 passt das Modell gut zum Sommer:

zeige_modell(s = 0.1, m = 0.1)   # Sommer

# Ueber jeder Abbildung steht der Abstand des Modells zu den Sommer- und zu den Winter-Daten: je kleiner, desto besser passt das Modell.
#
# Versuch A — s und m gleich aendern (so bleibt m/s = 1). Probieren Sie zum Beispiel s = m = 0.05 und s = m = 0.2. Passt das Modell immer noch zum Sommer?

zeige_modell(s = 0.1, m = 0.1)   # hier s und m gleich aendern

# Versuch B — nur s aendern (m bleibt 0.1). Probieren Sie zum Beispiel s = 0.05, 0.02, 0.01. Wann passt das Modell zum Winter?

zeige_modell(s = 0.1, m = 0.1)   # hier nur s aendern

# Versuch C — nur m aendern (s bleibt 0.1). Probieren Sie zum Beispiel m = 0.2, 0.5, 0.8. Wann passt das Modell zum Winter?

zeige_modell(s = 0.1, m = 0.1)   # hier nur m aendern

# --- F2 ---
#
# Tragen Sie Ihre Werte ein (Abstand: zum Sommer bei A, zum Winter bei B und C):
#
# |  | s | m | m/s | Abstand |
# | Sommer | 0.1 | 0.1 | 1 |  |
# | Versuch A |  |  | 1 |  |
# | Versuch A |  |  | 1 |  |
# | Versuch B (Winter) |  | 0.1 |  |  |
# | Versuch C (Winter) | 0.1 |  |  |  |
#
# Was faellt Ihnen an der Spalte m/s auf? Worauf kommt es an: auf s, auf m oder auf m/s? (Erinnerung an Woche 7.)

# ===========================================================================
# 3 · Abbildung 3: Was passiert im Winter wirklich?
# ===========================================================================
#
# Das Modell allein kann nicht entscheiden, ob sich s oder m geaendert hat. Dafuer braucht es Biologie.
#
# Bekannt ist: Im Winter fliegen die Muecken weniger. Viele ueberwintern in Kellern und Hoehlen. Nehmen wir an, m ist im Winter nur noch halb so gross: m = 0.05.
#
# Versuch D — m = 0.05 fest, s suchen. Lassen Sie zuerst s = 0.1 stehen und schauen Sie, was passiert. Verkleinern Sie dann s, bis das Modell zum Winter passt.

zeige_modell(s = 0.1, m = 0.05)   # hier s aendern

# --- F3 ---
#
# 1. Mit m = 0.05 und s = 0.1: Wird die Cline breiter oder enger als im Sommer?
# 2. Welches s brauchen Sie mit m = 0.05 fuer den Winter? Wie viel Selektion ist vom Sommer noch uebrig?
# 3. Warum ist die Selektion im Winter so schwach? Tipp: Wird im Winter gespritzt?

# --- Fuer das Gespraech mit der Assistenz (1–2 Minuten) ---
#
# Zeigen Sie eine Abbildung und sagen Sie drei Saetze:
#
# 1. Was ist im Winter anders? (F1)
# 2. Worauf kommt es im Modell an? (F2)
# 3. Was hat sich im Winter geaendert, und warum ist das plausibel? (F3)

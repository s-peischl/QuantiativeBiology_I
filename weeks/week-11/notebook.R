# Woche 11 - Checkpoint C (nur R, base R)
# Heterozygote und Homozygote: Welches s zaehlt fuer eine neue Mutation?
# In RStudio: Working Directory = weeks/week-11, dann Zeile fuer Zeile ausfuehren.
# Kein Programmieren: nur ausfuehren und Zahlen aendern.

# Eine neue Mutation beginnt mit einer Kopie. In Woche 10 hat sie sich etwa mit Wahrscheinlichkeit 2s etabliert. Dort haben wir aber so getan, als haette jedes Individuum nur eine Kopie des Gens. Wir sind diploid: Jedes Individuum hat zwei Kopien, wie in den Wochen 5 und 6.
#
# Das Modell. Drei Genotypen, jeder mit seiner Fitness (mittlere Zahl Nachkommen):
#
# | Genotyp | AA | Aa | aa |
# |---|---|---|---|
# | Fitness | 1 | 1 + h s | 1 + s |
#
# - s: Vorteil des Homozygoten aa. Heute immer s = 0.1.
# - h: Dominanz. Sie sagt, wie viel vom Vorteil schon der Heterozygot Aa hat.
#   - h = 1: dominant, Aa ist so gut wie aa,
#   - h = 0.5: kodominant, Aa liegt in der Mitte,
#   - h = 0: rezessiv, Aa ist so gut wie AA,
#   - h < 0: unterdominant, Aa ist schlechter als beide Homozygoten (Woche 6).
#
# Solange die Mutation selten ist, paart sich jeder Traeger mit einem AA. Jede Kopie sitzt also in einem Heterozygoten und hat im Mittel 1 + h s Nachkommen-Kopien. Simuliert wird wie in Woche 10: Jede Kopie hat 0 oder 2 Nachkommen.
#
# Die Abbildungen.
#
# - Teile 1 und 2: x-Achse Anzahl simulierter Mutationen, y-Achse Anteil etabliert bisher. Blau: Simulation, orange gestrichelt: die Faustregel 2s aus Woche 10.
# - Teil 3: x-Achse Dominanz h, y-Achse Anteil etabliert. Blaue Punkte: Simulation, orange Linie: eine Faustregel.
#
# Auftrag
#
# 1. Simulieren Sie eine dominante Mutation und vergleichen Sie mit 2s.
# 2. Aendern Sie nur h: kodominant, rezessiv, unterdominant.
# 3. Zeigen Sie alle Werte von h in einer Abbildung: Welche Faustregel passt?
#
# Am Schluss steht eine Frage. Diese beantworten Sie der Assistenz in 1-2 Minuten mit einer Abbildung.
#
# ===========================================================================
# 0 · Funktionen
# ===========================================================================
#
# Einfach ausfuehren.
#
# Eine neue Mutation: jede Kopie sitzt in einem Heterozygoten Aa
# und hat 0 oder 2 Nachkommen, im Mittel 1 + h * s (Woche 10).
# 1 = etabliert (100 Kopien erreicht), 0 = verloren
eine_linie <- function(s, h) {
  n <- 1
  while (n > 0 && n < 100) {
    n <- 2 * rbinom(1, n, (1 + h * s) / 2)
  }
  as.numeric(n >= 100)
}

# Anteil etabliert nach 1, 2, 3, ... Laeufen, dazu die Faustregel 2s
zeige_anteil <- function(ergebnisse, s, h) {
  laeufe <- seq_along(ergebnisse)
  plot(laeufe, cumsum(ergebnisse) / laeufe, type = "l", lwd = 2, col = "#2166ac",
       ylim = c(0, 0.4), xlab = "Anzahl simulierter Mutationen",
       ylab = "Anteil etabliert, bisher", main = paste0("s = ", s, ", h = ", h))
  abline(h = 2 * s, lty = 2, lwd = 2, col = "#d95f02")
  legend("topright", c("Simulation", "Faustregel 2s"), col = c("#2166ac", "#d95f02"),
         lty = c(1, 2), lwd = 2, bty = "n")
}

# Alle h auf einen Blick: Simulation (Punkte) und eine Faustregel (Linie)
zeige_h <- function(s = 0.1, regel = "2s", wiederholungen = 1000) {
  h_werte <- c(-0.5, -0.25, 0, 0.25, 0.5, 0.75, 1)
  anteil <- sapply(h_werte, function(h) mean(replicate(wiederholungen, eine_linie(s, h))))
  plot(h_werte, anteil, pch = 16, cex = 1.5, col = "#2166ac", ylim = c(0, 0.3),
       xlab = "Dominanz h", ylab = "Anteil etabliert",
       main = paste0("s = ", s, ", Linie: Faustregel ", regel))
  h_fein <- seq(-0.5, 1, length.out = 100)
  if (regel == "2s") linie <- rep(2 * s, 100) else linie <- pmax(0, 2 * h_fein * s)
  lines(h_fein, linie, lwd = 2, lty = 2, col = "#d95f02")
  abline(v = c(0, 0.5, 1), col = "grey85")
  invisible(data.frame(h = h_werte, anteil = anteil))
}

#
# ===========================================================================
# 1 · Eine dominante Mutation
# ===========================================================================
#
# h = 1: Der Heterozygot hat den vollen Vorteil. 2000 neue Mutationen, jede startet mit einer Kopie.
#
s <- 0.1
h <- 1                                       # Dominanz
ergebnisse <- replicate(2000, eine_linie(s, h))
mean(ergebnisse)                             # Anteil etabliert
2 * s                                        # Faustregel aus Woche 10
zeige_anteil(ergebnisse, s, h)

#
# Das ist Woche 10: Der Anteil liegt bei etwa 2s.
#
# ===========================================================================
# 2 · Nur h aendern
# ===========================================================================
#
# Jetzt bleibt der Vorteil des Homozygoten gleich (s = 0.1). Nur die Dominanz aendert sich.
#
# Anweisung: Setzen Sie h <- 0.5 und fuehren Sie den Block aus. Dann h <- 0, dann h <- -0.5. Notieren Sie jedes Mal den Anteil etabliert.
#
h <- 0.5                                     # hier h aendern: 0.5, dann 0, dann -0.5
ergebnisse <- replicate(2000, eine_linie(s, h))
mean(ergebnisse)
zeige_anteil(ergebnisse, s, h)

#
# ===========================================================================
# 3 · Alle h auf einen Blick
# ===========================================================================
#
# zeige_h simuliert fuer sieben Werte von h je 1000 Mutationen und zeichnet eine Faustregel dazu. Das dauert ein paar Sekunden.
#
# Anweisung: Fuehren Sie den Block aus. Passt die Linie 2s? Ersetzen Sie dann "2s" durch "2hs" und fuehren Sie ihn noch einmal aus.
#
set.seed(1)
zeige_h(s = 0.1, regel = "2s")               # hier "2s" durch "2hs" ersetzen

#
# ===========================================================================
# 4 · Die Frage
# ===========================================================================
#
# Welches s zaehlt?
#
# a) Ihre Werte (s = 0.1):
#
# | h | Fall | Anteil etabliert | 2s | 2hs |
# |---|---|---|---|---|
# | 1 | dominant |  | 0.2 |  |
# | 0.5 | kodominant |  | 0.2 |  |
# | 0 | rezessiv |  | 0.2 |  |
# | -0.5 | unterdominant |  | 0.2 |  |
#
# b) Welche Faustregel passt, 2s oder 2hs?
#
# c) Biologisch: Warum zaehlt fuer eine neue Mutation der Vorteil im Heterozygoten? Tipp: Wie viele aa-Individuen gibt es, solange es nur eine oder wenige Kopien gibt? Was heisst das fuer eine rezessive Mutation, die im Homozygoten sehr vorteilhaft waere?
#

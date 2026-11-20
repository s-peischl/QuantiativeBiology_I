# Woche 11 - Checkpoint C (nur R, base R)
# Heterozygote und Homozygote: Welches s zaehlt fuer eine neue Mutation?
# In RStudio: Working Directory = weeks/week-11, dann Zeile fuer Zeile ausfuehren.
# Kein Programmieren: nur ausfuehren und Zahlen aendern.

# Eine neue Mutation beginnt mit einer Kopie. In Woche 10 hat sie sich etwa mit Wahrscheinlichkeit 2s etabliert. Dort hatte jedes Individuum aber nur eine Kopie des Gens. Wir sind diploid: Jedes Individuum hat zwei Kopien, wie in den Wochen 5 und 6.
#
# Das Modell. Drei Genotypen, jeder mit seiner Fitness (mittlere Zahl Nachkommen):
#
# | Genotyp | AA | Aa | aa |
# |---|---|---|---|
# | Fitness | 1 | 1 + h s | 1 + s |
#
# - s: Vorteil des Homozygoten aa. Heute immer s = 0.1.
# - h: Dominanz. Sie sagt, wie viel vom Vorteil schon der Heterozygot Aa hat:
#   h = 1 dominant (Aa so gut wie aa), h = 0.5 kodominant (Aa in der Mitte), h = 0 rezessiv (Aa so gut wie AA).
#
# Solange die Mutation selten ist, paart sich jeder Traeger mit einem AA. Die Simulation folgt jeder neuen Mutation wie in Woche 10, bis sie verloren oder etabliert ist.
#
# Die Abbildung. x-Achse Dominanz h, y-Achse Anteil etablierter Mutationen. Blaue Punkte: Simulation, orange gestrichelt: die Faustregel 2s aus Woche 10.
#
# Auftrag
#
# 1. Schaetzen Sie die Etablierungswahrscheinlichkeit fuer eine dominante Mutation.
# 2. Aendern Sie nur h: kodominant, dann rezessiv.
# 3. Zeigen Sie alle drei in einer Abbildung und finden Sie die Faustregel: u ~ 2 * ?
#
# Am Schluss steht eine Frage. Diese beantworten Sie der Assistenz in 1-2 Minuten mit einer Abbildung.
#
# ===========================================================================
# 0 · Funktionen
# ===========================================================================
#
# Einfach ausfuehren.
#
# Eine neue Mutation, wie in Woche 10: jede Kopie hat 0 oder 2 Nachkommen.
# Sie sitzt in einem Heterozygoten Aa, also im Mittel 1 + h * s Nachkommen.
# 1 = etabliert (100 Kopien erreicht), 0 = verloren
eine_linie <- function(s, h) {
  n <- 1
  while (n > 0 && n < 100) {
    n <- 2 * rbinom(1, n, (1 + h * s) / 2)
  }
  as.numeric(n >= 100)
}

# Etablierungswahrscheinlichkeit: Anteil etabliert von 2000 neuen Mutationen
etablierung <- function(s, h, wiederholungen = 2000) {
  mean(replicate(wiederholungen, eine_linie(s, h)))
}

# Etablierung fuer h = 0, 0.5 und 1 in einer Abbildung
zeige_h <- function(s = 0.1) {
  h_werte <- c(0, 0.5, 1)
  u <- sapply(h_werte, function(h) etablierung(s, h))
  plot(h_werte, u, pch = 16, cex = 2, col = "#2166ac", ylim = c(0, 0.3),
       xlim = c(-0.1, 1.1), xaxt = "n", xlab = "Dominanz h",
       ylab = "Anteil etabliert", main = paste("s =", s))
  axis(1, at = h_werte, labels = c("0\nrezessiv", "0.5\nkodominant", "1\ndominant"), padj = 0.5)
  abline(h = 2 * s, lty = 2, lwd = 2, col = "#d95f02")
  text(h_werte, u, round(u, 3), pos = ifelse(u > 0.15, 1, 3))
  legend("topleft", c("Simulation", "Faustregel 2s"), col = c("#2166ac", "#d95f02"),
         pch = c(16, NA), lty = c(NA, 2), lwd = 2, bty = "n")
  invisible(data.frame(h = h_werte, u = u))
}

#
# ===========================================================================
# 1 · Eine dominante Mutation
# ===========================================================================
#
# etablierung(s, h) simuliert 2000 neue Mutationen und gibt eine Zahl zurueck: den Anteil, der sich etabliert.
#
etablierung(s = 0.1, h = 1)   # dominant
2 * 0.1                       # Faustregel aus Woche 10

#
# Das ist Woche 10: etwa 2s.
#
# ===========================================================================
# 2 · Nur h aendern
# ===========================================================================
#
# Anweisung: Setzen Sie h = 0.5, fuehren Sie den Block aus und notieren Sie die Zahl. Dann dasselbe mit h = 0. Der Vorteil des Homozygoten bleibt s = 0.1.
#
etablierung(s = 0.1, h = 0.5)   # hier h aendern: 0.5, dann 0

#
# ===========================================================================
# 3 · Alle drei auf einen Blick
# ===========================================================================
#
# zeige_h simuliert h = 0, 0.5 und 1 und zeichnet sie zusammen mit der Faustregel 2s. Das dauert ein paar Sekunden.
#
set.seed(1)
zeige_h(s = 0.1)

#
# ===========================================================================
# 4 · Die Frage
# ===========================================================================
#
# Wie gross sollte die Etablierungswahrscheinlichkeit sein?
#
# a) Ihre Werte (s = 0.1):
#
# | h | Fall | Anteil etabliert |
# |---|---|---|
# | 1 | dominant |  |
# | 0.5 | kodominant |  |
# | 0 | rezessiv |  |
#
# b) In Woche 10 galt u ~ 2s. Ergaenzen Sie die Faustregel so, dass sie zu allen drei Punkten passt: u ~ 2 * ?
#
# c) Biologisch: Warum zaehlt fuer eine neue Mutation der Vorteil im Heterozygoten? Tipp: Wie viele aa-Individuen gibt es, solange es nur eine oder wenige Kopien gibt?
#

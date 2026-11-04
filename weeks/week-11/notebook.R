# Woche 11 — Checkpoint C (nur R, base R)
# Wildtyp und Mutator: evolutionaere Rettung unter Antibiotikum
# In RStudio: Working Directory = weeks/week-11, dann Zeile fuer Zeile ausfuehren.
# Kein Programmieren: nur ausfuehren und Zahlen aendern.

# Ein Antibiotikum toetet empfindliche Bakterien. Die Population schrumpft. Sie ueberlebt nur, wenn rechtzeitig eine resistente Mutante entsteht und sich etabliert: evolutionaere Rettung (Woche 10).
#
# Das Experiment. Bakterien-Kulturen wurden in Roehrchen mit Antibiotikum gegeben. Jede Kultur startet mit N_0 Zellen, von 10 000 bis 1 Milliarde. Fuer jede Startgroesse gibt es 24 Roehrchen. Nach drei Tagen wird nachgeschaut:
#
# - trueb: resistente Zellen sind gewachsen, die Kultur ist gerettet,
# - klar: alle Zellen sind tot, die Kultur ist ausgestorben.
#
# Das wurde mit zwei Staemmen gemacht: dem Wildtyp und einem Mutator. Der Mutator ist derselbe Stamm, aber mit einem defekten Gen fuer die DNA-Reparatur.
#
# Die Abbildungen. Alle Abbildungen haben dieselben Achsen:
#
# - x-Achse: Startgroesse N_0 (Anzahl Zellen) auf einer log-Skala: Jeder Strich ist zehnmal mehr,
# - y-Achse: Anteil geretteter Roehrchen (von 24),
# - orange Kreise: Wildtyp, blaue Dreiecke: Mutator.

# --- Auftrag ---
#
# 1. Passen Sie das Modell an den Wildtyp an.
# 2. Veraendern Sie diese Loesung, bis sie auch zum Mutator passt.
# 3. Schliessen Sie daraus biologisch, was den Mutator unterscheidet.
#
# Am Schluss steht eine Frage. Diese beantworten Sie der Assistenz in 1–2 Minuten mit einer Abbildung.

# ===========================================================================
# 0 · Daten und Funktionen
# ===========================================================================
#
# Einfach ausfuehren (Kursdaten, erfunden).

# Startgroessen: 10 000 bis 1 Milliarde Zellen, Schritte von Faktor etwa 3
N0 <- 10^seq(4, 9, by = 0.5)
roehrchen <- 24   # Roehrchen pro Startgroesse

# Anzahl geretteter (trueber) Roehrchen pro Startgroesse
k_wildtyp <- c(0, 0, 0, 0, 0, 1, 3, 6, 16, 23, 24)
k_mutator <- c(0, 1, 3, 7, 14, 23, 24, 24, 24, 24, 24)

wildtyp <- data.frame(N0 = N0, anteil = k_wildtyp / roehrchen)
mutator <- data.frame(N0 = N0, anteil = k_mutator / roehrchen)

farben <- c(Wildtyp = "#d95f02", Mutator = "#2166ac")

# Wahrscheinlichkeit der Rettung (Woche 10, Orr & Unckless 2014)
rettung <- function(N0, r, s, U) 1 - exp(-2 * N0 * U * s / r)

zeige_daten <- function(main = "Gerettete Roehrchen") {
  plot(wildtyp$N0, wildtyp$anteil, log = "x", pch = 16, col = farben["Wildtyp"],
       ylim = c(0, 1), xaxt = "n", main = main,
       xlab = "Startgroesse N0 (Zellen, log-Skala)",
       ylab = "Anteil gerettet (von 24)")
  axis(1, at = 10^(4:9),
       labels = c("10 000", "100 000", "1 Mio.", "10 Mio.", "100 Mio.", "1 Mrd."))
  points(mutator$N0, mutator$anteil, pch = 17, col = farben["Mutator"])
  abline(h = 0.5, lty = 3, col = "grey60")
  legend("topleft", c("Wildtyp", "Mutator"), pch = c(16, 17),
         col = farben, bty = "n")
}

# Abstand zwischen Modell und Daten (kleiner = passt besser)
abstand <- function(p_modell, daten) round(sum((p_modell - daten$anteil)^2), 3)

zeige_modell <- function(s, r, U) {
  zeige_daten(main = paste0("Modell (schwarz): s = ", s, ", r = ", r, ", U = ", U))
  N_fein <- 10^seq(4, 9, length.out = 200)
  lines(N_fein, rettung(N_fein, r, s, U), col = "grey15", lwd = 2.2)
  mtext(paste0("Abstand zum Wildtyp: ", abstand(rettung(N0, r, s, U), wildtyp),
               "   zum Mutator: ", abstand(rettung(N0, r, s, U), mutator),
               "   (kleiner = passt besser)"), side = 3, line = 0.2, cex = 0.85)
}

# ===========================================================================
# 1 · Die Daten
# ===========================================================================

zeige_daten()

# Kleine Kulturen sterben fast immer aus, grosse werden fast immer gerettet. Dazwischen liegt ein Uebergang. Die gepunktete Linie markiert die Haelfte: Bei welcher Startgroesse wird etwa jedes zweite Roehrchen gerettet? Beim Mutator liegt dieser Punkt bei viel kleineren Kulturen.

# ===========================================================================
# 2 · Das Modell
# ===========================================================================
#
# Das Modell ist die Formel aus Woche 10:
#
# 
# P(Rettung) = 1 - exp(-2 * N0 * U * s / r)
# 
#
# Die drei Parameter:
#
# - r: wie schnell das Antibiotikum empfindliche Zellen toetet (Anteil pro Generation),
# - s: wie stark resistente Zellen im Antibiotikum wachsen (im Mittel 1 + s Nachkommen),
# - U: Wahrscheinlichkeit, dass eine neue Zelle eine Resistenzmutation traegt.
#
# In Woche 10 hat die Simulation gezeigt, dass die Formel gut passt. Heute rechnen wir nur mit der Formel: Eine Simulation mit einer Milliarde Zellen dauert zu lange.
#
# R schreibt sehr kleine Zahlen so: 1e-8 heisst 10^-8 = 0.00000001. 1e-7 ist zehnmal groesser, 1e-6 hundertmal.
#
# Was die Abbildung zeigt: die Daten wie oben und dazu das Modell als schwarze Linie. Im Titel stehen s, r und U. Darunter steht der Abstand zwischen Modell und Daten, einmal zum Wildtyp und einmal zum Mutator. Der Abstand ist die Summe der quadrierten Unterschiede ueber alle 11 Startgroessen: 0 hiesse perfekt, unter etwa 0.03 passt das Modell.

# ===========================================================================
# 3 · Schritt 1: den Wildtyp anpassen
# ===========================================================================
#
# Fuer den Wildtyp ist die Mutationsrate gemessen: U = 10^-8. Diese Zahl bleibt fest. Das Modell startet mit s = 0.1 und r = 0.05. Fuehren Sie den Block aus: Die schwarze Linie passt noch nicht zum Wildtyp.
#
# Anweisung: Aendern Sie entweder s oder r (nur eine Zahl) und fuehren Sie den Block erneut aus. Wiederholen Sie das, bis der Abstand zum Wildtyp unter 0.03 liegt. Notieren Sie Ihre Werte.

zeige_modell(s = 0.1, r = 0.05, U = 1e-8)   # Wildtyp: s oder r aendern

# ===========================================================================
# 4 · Schritt 2: den Mutator anpassen
# ===========================================================================
#
# Nehmen Sie Ihre Wildtyp-Loesung und tragen Sie sie unten ein. Der Mutator wird schon bei kleineren Kulturen gerettet.
#
# Anweisung: Aendern Sie wieder nur eine Zahl, bis der Abstand zum Mutator unter 0.03 liegt.
#
# - Versuch 1: nur s aendern. Groesser oder kleiner?
# - Versuch 2: zurueck zur Wildtyp-Loesung, jetzt nur r aendern. Groesser oder kleiner?
# - Versuch 3: zurueck zur Wildtyp-Loesung, jetzt nur U aendern. Groesser oder kleiner?

zeige_modell(s = 0.1, r = 0.05, U = 1e-8)   # hier Ihre Wildtyp-Loesung eintragen, dann eine Zahl aendern

# ===========================================================================
# 5 · Die Frage
# ===========================================================================

# --- Was unterscheidet den Mutator? ---
#
# a) Ihre Werte:
#
# |  | s | r | U | Abstand |
# | Wildtyp |  |  |  |  |
# | Mutator, nur s geaendert |  |  |  |  |
# | Mutator, nur r geaendert |  |  |  |  |
# | Mutator, nur U geaendert |  |  |  |  |
#
# b) Um welchen Faktor mussten Sie jede Zahl aendern? Was haben die drei Mutator-Loesungen gemeinsam?
#
# c) Biologisch: In Kontrollversuchen sterben empfindliche Zellen beider Staemme im Antibiotikum gleich schnell, und beide tragen dieselbe Resistenzmutation. Welcher Parameter unterscheidet den Mutator also, und um wie viel? Was bedeutet das fuer eine Infektion mit Mutator-Bakterien?

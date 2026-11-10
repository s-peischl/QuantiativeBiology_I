# Woche 9 - Notebook (nur R, base R)
# Zufall und Notwendigkeit: Drift, die Teiche und die Echsen mit endlicher Population
# In RStudio: Working Directory = weeks/week-09, dann Zeile fuer Zeile ausfuehren.
# Quarto: notebook.qmd. Knit ohne Quarto: notebook.Rmd.

# In der Vorlesung wandert die Frequenz in den Teichen, auch ohne dass wir schon wissen, wie viel davon Selektion ist. Ein Grund dafuer: Die Population ist endlich. Jede Generation ist eine Ziehung aus der vorherigen.
#
# Dieses Notebook rechnet die Teiche nicht noch einmal. Sie kommen nur am Ende von Teil A kurz zurueck. Zwei neue Fragen:
#
# 1. Wie haengt diese Wanderung von der Populationsgroesse N ab, wenn das Allel neutral ist?
# 2. Was passiert mit den drei Kehlfarben der Echsen aus Woche 4, wenn die Population endlich ist?

# Auftrag
# 1. Eine Binomialverteilung anschauen und set.seed ausprobieren.
# 2. Ein neutrales Allel viele Generationen lang verfolgen, einmal in einer grossen und einmal in einer kleinen Population. Dann mit den Teichen vergleichen.
# 3. Das Echsen-Spiel aus Woche 4 mit endlicher Population laufen lassen: Wann gehen Farben verloren?

# ===========================================================================
# 0 · Zufallszahlen
# ===========================================================================
#
# rbinom(anzahl, size, prob) zieht anzahl Mal, wie viele von size Versuchen erfolgreich waren. Jeder Versuch klappt mit Wahrscheinlichkeit prob. In der Vorlesung war das die Frage: Wie viele von N Genkopien sind die gesuchte Kopie?
#
# set.seed legt den Startwert fest. Dieselbe Folge kommt dann noch einmal heraus.

set.seed(2026)

x <- rbinom(1000, size = 20, prob = 0.5)
hist(x, breaks = 0:21 - 0.5,
     main = "1000 Ziehungen", xlab = "X ~ Binomial(20, 0.5)", ylab = "Anzahl")

# F1
# 1. Lassen Sie denselben Block ohne set.seed zweimal laufen. Aendert sich das Histogramm?
# 2. Setzen Sie prob = 0.1. Wie veraendert sich die Verteilung? Warum?

# ===========================================================================
# A · Populationsgroesse
# ===========================================================================
#
# Wir verfolgen ein neutrales Allel. p ist seine Frequenz. Der Einfachheit halber ist die Populationsgroesse N fix, und jedes Individuum ist haploid: Es traegt das Allel, oder es traegt es nicht.
#
# Jede Generation wird aus der vorherigen gezogen. Ist das Allel in Generation t haeufig, ist es in Generation t+1 wahrscheinlich auch haeufig - aber nicht genau gleich haeufig. Das ist derselbe Schritt wie in der Vorlesung, hier ohne Selektion.

WF_step <- function(p, N) {
  N_p <- rbinom(1, N, p)   # wie viele der N Individuen tragen das Allel?
  N_p / N
}

# --- Eine Generation ---

# F2
# Simulieren Sie eine einzelne Generation mit p = 0.5 und N = 1000.
#
# - Was erwarten Sie: nimmt p ab, nimmt es zu, oder bleibt es in der Naehe von 0.5?
# - Lassen Sie den Chunk mehrmals laufen. Was passiert?

WF_step(p = 0.5, N = 1000)

# --- Viele Generationen ---

simulateWF <- function(p_0, N, generationen = 250) {
  p <- numeric(generationen + 1)
  p[1] <- p_0
  for (t in seq_len(generationen)) {
    p[t + 1] <- WF_step(p[t], N)
  }
  data.frame(generation = 0:generationen, p = p)
}

# --- Grosse Population ---

p_0 <- 0.5   # bitte aendern

large_pop <- simulateWF(p_0, N = 1000)

plot(large_pop$generation, large_pop$p, type = "l", lwd = 2, col = "plum4",
     xlab = "Generationen", ylab = "Allelfrequenz", ylim = c(0, 1),
     main = "N = 1000")
abline(h = p_0, lwd = 1, lty = 2)

# F3
# Aendern Sie p_0. Was passiert mit der Allelfrequenz ueber die 250 Generationen?

# --- Kleine Population ---

# F4
# Was erwarten Sie fuer N = 100, bevor Sie den naechsten Block laufen lassen?

p_0 <- 0.5   # bitte aendern

small_pop <- simulateWF(p_0, N = 100)

plot(small_pop$generation, small_pop$p, type = "l", lwd = 2, col = "plum4",
     xlab = "Generationen", ylab = "Allelfrequenz", ylim = c(0, 1),
     main = "N = 100")
abline(h = p_0, lwd = 1, lty = 2)

# F5
# - Lassen Sie den Block ein paar Mal laufen. Was beobachten Sie?
# - In den bisherigen Wochen stieg oder fiel p, weil das Allel einen Vorteil oder einen Nachteil hatte. Ist das hier auch so?
# - Was heisst das fuer die genetische Vielfalt in einer kleinen Population?

# --- Zurueck zu den Teichen ---
#
# In der Vorlesung starten alle drei Teiche bei p = 0.5 und liegen nach drei bis vier Jahren bei etwa 0.63 (Teich 2 und 14) und 0.84 (Teich 7). Kann ein neutrales Allel das allein durch Zufall schaffen?
#
# Wir lassen simulateWF 100 Mal laufen, je 4 Generationen mit N = 250, und merken uns nur die Frequenz am Ende.

N <- 250   # bitte aendern

set.seed(2026)
p_ende <- numeric(100)
for (i in 1:100) {
  bahn <- simulateWF(p_0 = 0.5, N = N, generationen = 4)
  p_ende[i] <- bahn$p[5]
}

hist(p_ende, breaks = seq(0, 1, by = 0.025), xlim = c(0.2, 1),
     main = paste("100 neutrale Bahnen, N =", N),
     xlab = "Allelfrequenz nach 4 Generationen", ylab = "Anzahl")
abline(v = c(0.637, 0.625, 0.837), lwd = 2,
       col = c("#e67e22", "#1e8449", "#2980b9"))   # Teich 2, 14, 7

sum(p_ende >= 0.62)   # wie viele Bahnen kommen so hoch wie die Teiche?

# F6
# - Wie viele der 100 neutralen Bahnen kommen so hoch wie die Teiche? Und wie viele so hoch wie Teich 7?
# - Setzen Sie N auf 50 und dann auf 25. Wie klein muesste die Population sein, damit Zufall allein reicht?
# - In jedem Teich leben Hunderte Stichlinge. Was muss also zum Zufall dazukommen?

# ===========================================================================
# B · Echsen mit endlicher Population
# ===========================================================================
#
# In Woche 4 hatten die Maennchen von Uta stansburiana drei Kehlfarben: orange schlaegt blau, blau schlaegt gelb, gelb schlaegt orange. Mit der Matrix
#
# 
# A =
# \begin{pmatrix}
# 1 & w & s \\
# s & 1 & w \\
# w & s & 1
# \end{pmatrix}
# 
#
# gab es drei Verlaeufe. Ist s + w < 2, laufen die Haeufigkeiten auf einen Punkt in der Mitte zu. Ist s + w > 2, schaukeln sie sich auf: eine Heterokline. Jede Farbe wird abwechselnd fast alleinherrschend und dann fast null.
#
# Fast null: Im Modell von Woche 4 ist die Population unendlich gross. Eine Farbe mit Haeufigkeit 0.0001 ist dort noch da und kommt wieder. In echten Echsen-Populationen gibt es nur ganze Maennchen.
#
# Wir machen dasselbe wie in der Vorlesung mit den Teichen: erst Selektion, dann Ziehung. Fuer drei Farben zieht rmultinom statt rbinom: Von N Maennchen der neuen Generation, wie viele sind orange, blau, gelb?

echsen_matrix <- function(s, w) {
  matrix(c(1, w, s,
           s, 1, w,
           w, s, 1), nrow = 3, byrow = TRUE)
}

# Eine Generation: erst Selektion (wie Woche 4), dann N Maennchen ziehen
echsen_schritt <- function(p, A, N, r = 0.3) {
  W <- 2 - as.numeric(A %*% p)            # Fitness jeder Farbe
  W_mittel <- sum(p * W)
  p_sel <- p * (1 + r * (W - W_mittel))   # 1. Selektion
  p_sel <- p_sel / sum(p_sel)
  if (is.infinite(N)) return(p_sel)       # N = Inf: kein Zufall
  as.numeric(rmultinom(1, size = N, prob = p_sel)) / N   # 2. Ziehung
}

# Viele Generationen hintereinander
echsen_lauf <- function(s, w, N, generationen = 1000, p0 = c(0.4, 0.35, 0.25)) {
  A <- echsen_matrix(s, w)
  p <- matrix(NA, nrow = generationen + 1, ncol = 3)
  p[1, ] <- p0
  for (t in 1:generationen) p[t + 1, ] <- echsen_schritt(p[t, ], A, N)
  p
}

farben3 <- c("#e67e22", "#2980b9", "#f1c40f")

erster_verlust <- function(p) {
  i <- which(apply(p, 1, min) == 0)
  if (length(i)) i[1] - 1 else NA
}

zeige_echsen <- function(s, w, N, generationen = 1000) {
  p <- echsen_lauf(s, w, N, generationen)
  verlust <- erster_verlust(p)
  par(mfrow = c(1, 2), mar = c(4, 4, 3, 1))
  matplot(0:generationen, p, type = "l", lty = 1, lwd = 1.8, col = farben3, ylim = c(0, 1),
          xlab = "Generation", ylab = "Haeufigkeit",
          main = paste0("s = ", s, ", w = ", w, ", N = ", N))
  if (!is.na(verlust)) {
    abline(v = verlust, lty = 2, col = "grey40")
    mtext(paste("erster Verlust: Generation", verlust), side = 3, line = 0.2, cex = 0.8)
  } else {
    mtext("alle drei Farben noch da", side = 3, line = 0.2, cex = 0.8)
  }
  legend("topright", c("orange", "blau", "gelb"), col = farben3, lwd = 2, bty = "n", cex = 0.8)
  # Dreieck: jede Ecke eine Farbe, der Punkt ist die Mischung
  ecke <- rbind(c(0.5, sqrt(3) / 2), c(0, 0), c(1, 0))
  xy <- p %*% ecke
  plot(NA, xlim = c(-0.05, 1.05), ylim = c(-0.08, 0.95), asp = 1, axes = FALSE,
       xlab = "", ylab = "", main = "Dreieck: jede Ecke eine Farbe")
  polygon(ecke, col = "#f4f6f7", border = "#2c3e50", lwd = 2)
  zeit <- seq(0, 1, length.out = nrow(xy))
  segments(xy[-nrow(xy), 1], xy[-nrow(xy), 2], xy[-1, 1], xy[-1, 2],
           col = grey(0.8 - 0.65 * zeit[-1]), lwd = 1.3)
  points(xy[1, 1], xy[1, 2], pch = 16, col = "#27ae60", cex = 1.4)
  points(xy[nrow(xy), 1], xy[nrow(xy), 2], pch = 16, col = "#c0392b", cex = 1.4)
  text(ecke[, 1] + c(0, -0.04, 0.04), ecke[, 2] + c(0.05, -0.05, -0.05),
       c("orange", "blau", "gelb"), col = farben3, font = 2)
  par(mfrow = c(1, 1))
  invisible(p)
}

zeit_bis_verlust <- function(s, w, N, wiederholungen = 20, generationen = 3000) {
  t <- replicate(wiederholungen, erster_verlust(echsen_lauf(s, w, N, generationen)))
  c(verloren = sum(!is.na(t)), median_generation = median(t, na.rm = TRUE))
}

# Die Abbildungen. Links: Haeufigkeit jeder Farbe ueber die Generationen. Rechts: das Dreieck aus Woche 4. Jede Ecke ist eine Farbe allein, die Mitte ist gleich viel von allen. Gruen ist der Start, rot das Ende, die Linie wird mit der Zeit dunkler.

# --- Ohne Zufall ---

zeige_echsen(s = 1.3, w = 0.8, N = Inf)

# F7
# - s + w = 2.1: Was macht die Bahn im Dreieck?
# - Geht eine Farbe je ganz verloren? Wie klein wird die seltenste Farbe? p <- echsen_lauf(1.3, 0.8, N = Inf); min(p)

# --- Mit Zufall ---
#
# Dasselbe Spiel, aber jede Generation hat N = 1000 Maennchen.

zeige_echsen(s = 1.3, w = 0.8, N = 1000)   # bitte mehrmals ausfuehren, dann N aendern

# F8
# - Was passiert, wenn eine Farbe in die Naehe von null kommt?
# - Und danach, mit nur noch zwei Farben? (Woche 4: Zwei Strategien schliessen sich aus.)
# - Lassen Sie den Block mehrmals laufen. Gewinnt immer dieselbe Farbe?

# --- Wie schnell? ---
#
# zeit_bis_verlust laesst 20 Populationen laufen und zaehlt, in wie vielen eine Farbe verloren geht und nach wie vielen Generationen (Median).

set.seed(1)
zeit_bis_verlust(s = 1.3, w = 0.8, N = 1000)   # bitte N aendern

# F9
# | N | verloren (von 20) | Generationen bis zum ersten Verlust |
# |---|---|---|
# | 100 |  |  |
# | 1 000 |  |  |
# | 10 000 |  |  |
#
# Hilft eine groessere Population gegen den Verlust? Verhindert sie ihn?

# --- Ein stabiler Punkt ---
#
# Jetzt s + w < 2: Selektion zieht die Mischung zur Mitte.

zeige_echsen(s = 1.1, w = 0.5, N = 1000)

set.seed(1)
zeit_bis_verlust(s = 1.1, w = 0.5, N = 1000)   # bitte N aendern

# F10
# - Vergleichen Sie mit der Heterokline. Wo haelt Selektion die Vielfalt, wo bringt sie die Farben in Gefahr?
# - Probieren Sie N = 100. Was aendert sich?
# - Bei Uta gibt es seit Jahren alle drei Farben. Was sagt das ueber N, oder ueber s und w?

# ===========================================================================
# Fazit
# ===========================================================================
#
# Teil A: Zufall allein laesst ein Allel wandern, und in kleinen Populationen geht es schnell verloren. Teil B: Zufall und Selektion zusammen. Wohin die Selektion die Population treibt, entscheidet, wie gefaehrlich der Zufall ist.

# F11
# Schreiben Sie die drei Saetze zu Ende.
#
# - In einer kleinen Population kann ein Allel zufaelligerweise ... . Diesen Prozess nennen wir Drift.
# - Auf einer Heterokline wird jede Farbe immer wieder selten. In einer endlichen Population kann sie dann ... . Die Vielfalt geht ..., auch wenn die Selektion sie im Mittel erhalten wuerde.
# - In Teich 7 wurden pro Jahr nur 7-36 Fische untersucht. Ein Teil des Unterschieds zu den anderen Teichen kann deshalb ... sein.


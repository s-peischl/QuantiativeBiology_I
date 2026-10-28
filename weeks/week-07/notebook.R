# Woche 7 — Notebook (nur R, base R)
# Migration und Selektion
# In RStudio: Working Directory = weeks/week-07, dann Zeile fuer Zeile ausfuehren.
# Formeln stehen schoener im Notebook (HTML) oder in notebook.Rmd.

# ===========================================================================
# Ziel
# ===========================================================================
#
# - verstehen, wie Selektion und Migration lokale Anpassung beeinflussen
# - nachvollziehen, wie verschiedene Kraefte (Selektion und Migration) aehnliche Anpassungsmuster generieren koennen

# ===========================================================================
# 0) Lokale Anpassung in kurz
# ===========================================================================
#
# Migration vermischt Populationen, wodurch sie einander aehnlicher werden. Selektion fuehrt dazu, dass Populationen sich ihrer Umgebung anpassen, wodurch Populationen unterschiedlicher werden.

# ===========================================================================
# A) Beispiel Insektizidresistenz in Moskitos
# ===========================================================================
# Diese Woche untersuchen wir die Anpassung verschiedener Moskitopopulationen an Insektizide. Dieses Beispiel ist an eine Studie von Lenormand et al. (1999) angelehnt.
#
# Um die Stadt Montpellier wurde in den 90er Jahren Insektizid ausgetragen, woraufhin die lokale Moskitopopulation eine Resistenz dagegen entwickelt hat. Diese Resistenz ist jedoch in Abwesenheit des Insektizids unvorteilhaft und daher in laendlichen Moskitopopulationen nicht vorhanden. Wir untersuchen nun, wie sich die Resistenzfrequenz p des Resistenz-Alleles R in der Stadtpopulation unter verschiedenen Selektions- und Migrationsszenarien veraendert. Dafuer tracken wir das resistente Allel R und das urspruengliche (Insektizid-anfaellige) Allel r in der Stadtpopulation, jeweils mit Frequenzen p_R und p_r.

# --- Gleichungen ---
# Wir nehmen an, dass in der Stadtpopulation das Resistenzallel R vorteilhaft ist, so dass die Genotypen folgende Fitnesswerte haben:
#
# |  w_RR |  w_rR |  w_rr |
# | 1 + s | 1 + s/2 | 1 |
#
# Dabei ist s der Selektionskoeffizient und somit der Fitnessvorteil von Resistenz in der Stadt.
#
# Die mittlere Fitness w_quer ist demnach:
#   w_quer = p^2 w_RR + 2pq w_rR + q^2 w_rr
#
# und nach Selektion gilt:
#
#   p^s = (p^2 w_RR + pq w_rR ) / w_quer,     q^s = (q^2 w_rr + pq w_rR ) / w_quer
#
# Nach Migration nehmen wir an, dass ein Anteil m der Individuen aus der Population aus der Nachbarpopulation stammt, wobei eine Population komplett durchmischt ist, wenn m = 0.5:
#   p^m = (1-m)p^s + mq^s,    
#   q^m = (1-m)q^s + mp^s

# --- Funktionen ---

# Selektion; Berechnung der mittleren Fitness
selektionsschritt <- function(p, # Proportion des gefragten Alleles
                              w) # Fitness der verschiedenen Genotypen (Vektor mit drei Eintraegen)
  {
  
  q <- 1-p # Proportion des anderen Alleles
  
  w_quer <- p^2*w[1] + 2*p*q*w[2] + q^2*w[3]
  
  p_sel <- (p^2*w[1] + p*q*w[2] )/ w_quer
  
  return(p_sel)
}

# Simulation eines Generationschritts, Selektion gefolgt von Migration
eine_generation <- function(p, # Frequenz des Resistenz-Alleles
                            s, # Selektionskoeffizient
                            m) # Migration
  {
  
  q <- 1 - p # Proportion der anfaelligen Moskitos
  
  # Selektion
  p_sel <- selektionsschritt(p, c(1 + s, 1 + s/2, 1))
  q_sel <- selektionsschritt(q, c(1, 1 + s/2, 1 + s))
  
  # Migration
  p_mig <- (1 - m) * p_sel + m * q
  q_mig <- (1 - m) * q_sel + m * p
  
  return(c(p_mig = p_mig, q_mig = q_mig))

}

# --- A1) Eine Generation ---
# Simulieren Sie eine einzelne Generation. Wir starten mit einer gleichmaessigen Verteilung von resistenten und anfaelligen Moskitos; p_R = 0.5.
#
# Die Ausgabe hat zwei Zahlen:
#
# - p_mig: Frequenz von R in der Stadt nach Selektion und Migration
# - q_mig: Frequenz von R in der Nachbarpopulation (Land) nach Selektion und Migration

# --- F1 ---
#
# Was sind Ihre Erwartungen? Nimmt p_R ab oder zu?

eine_generation(p = 0.5,
                s = 0.2,
                m = 0.2)

# --- F2 ---
#
# Setzen Sie zuerst s und dann m auf 0; was sehen Sie?

# ===========================================================================
# A2) Mehrere Generationen
# ===========================================================================

# Simulation mehrerer Generationen
simulateLA <- function(p_0, # Anfangsfrequenz
                       s, # Selektionskoeffizient
                       m, # Migration
                       generationen = 100) # Anzahl Generationen; Annahme = 100
  {
  
  p <- q <- numeric(generationen + 1) # Vorbereiten von leeren Vektoren (von 0 bis zur maximalen Generationen Zahl)
  
  # Anfangsfrequenzen
  p[1] <- p_0
  q[1] <- 1- p_0 
  
  for (t in seq_len(generationen)) { # Wiederholen der Zeitschritte
    
    new_freq <- eine_generation(p[t], s, m)
    p[t + 1] <- new_freq[1]
    q[t + 1] <- new_freq[2]
  }
  
  data.frame(generation = 0:generationen, 
             p = p, 
             q = q)
}

# Schauen Sie sich nun die Allelfrequenz als Funktion von Zeit an

test_df <- simulateLA(p_0 = 0.5,
                     s = 0.2, # Bitte aendern
                     m = 0.2)

plot(x = test_df$generation,
     y = test_df$p,
     type = "l", lwd = 2, col = "dodgerblue",
     xlab = "Generationen",
     ylab = "Allelfrequenz",
     ylim = c(0,1),
     main = "s = ?, m = 0.2")
lines(x = test_df$generation,
     y = test_df$q, 
     type = "l", lwd = 2, col = "chartreuse3")
legend("topright", c("Resistent", "Anfaellig"),
       col = c("dodgerblue", "chartreuse3"),
       lwd = 2, bty = "n")

# --- F3 ---
#
# Aendern Sie s. Was passiert mit dem Resistenzallel?

# --- Vergleich verschiedener m/s Regime ---

# m/s groesser 1
ms_gr_1 <- simulateLA(p_0 = 0.5,
                     s = 0, # Bitte aendern
                     m = 0) # Bitte aendern

# m/s gleich 1
ms_gl_1 <- simulateLA(p_0 = 0.5,
                     s = 0.3,
                     m = 0.3)

# m/s kleiner 1
ms_kl_1 <- simulateLA(p_0 = 0.5,
                     s = 0, # Bitte aendern
                     m = 0) # Bitte aendern

par(mfrow = c(1, 3))
plot(x = ms_gr_1$generation,
     y = ms_gr_1$p,
     type = "l", lwd = 2, col = "dodgerblue",
     xlab = "Generationen",
     ylab = "Allelfrequenz",
     ylim = c(0,1),
     main = "m/s > 1")
lines(x = ms_gr_1$generation,
     y = ms_gr_1$q, 
     type = "l", lwd = 2, col = "chartreuse3")
legend("topright", c("Resistent", "Anfaellig"),
       col = c("dodgerblue", "chartreuse3"),
       lwd = 2, bty = "n")

plot(x = ms_gl_1$generation,
     y = ms_gl_1$p,
     type = "l", lwd = 2, col = "dodgerblue",
     xlab = "Generationen",
     ylab = "Allelfrequenz",
     ylim = c(0,1),
     main = "m/s = 1")
lines(x = ms_gl_1$generation,
     y = ms_gl_1$q, 
     type = "l", lwd = 2, col = "chartreuse3")
legend("topright", c("Resistent", "Anfaellig"),
       col = c("dodgerblue", "chartreuse3"),
       lwd = 2, bty = "n")

plot(x = ms_kl_1$generation,
     y = ms_kl_1$p,
     type = "l", lwd = 2, col = "dodgerblue",
     xlab = "Generationen",
     ylab = "Allelfrequenz",
     ylim = c(0,1),
     main = "m/s < 1")
lines(x = ms_kl_1$generation,
     y = ms_kl_1$q, 
     type = "l", lwd = 2, col = "chartreuse3")
legend("topright", c("Resistent", "Anfaellig"),
       col = c("dodgerblue", "chartreuse3"),
       lwd = 2, bty = "n")

# --- F4 ---
#
# Aendern Sie die m und s Werte der verschiedenen Simulationen, um die drei m/s Szenarien zu plotten.
# Beschreiben Sie, was Sie sehen.
#
# Vergleichen Sie Simulationen mit verschiedenen m und s Werten:

ref <- simulateLA(p_0 = 0.5,
                     s = 0.25,
                     m = 0.1)

test1 <- simulateLA(p_0 = 0.5,
                     s = 0.0, # Bitte aendern
                     m = 0.3)

test2 <- simulateLA(p_0 = 0.5,
                     s = 0.5,
                     m = 0.0) # Bitte aendern

par(mfrow = c(1, 3))
plot(x = ref$generation,
     y = ref$p,
     type = "l", lwd = 2, col = "dodgerblue",
     xlab = "Generationen",
     ylab = "Allelfrequenz",
     ylim = c(0,1),
     main = "s = 0.25, m = 0.1")
lines(x = ref$generation,
     y = ref$q, 
     type = "l", lwd = 2, col = "chartreuse3")
legend("topright", c("Resistent", "Anfaellig"),
       col = c("dodgerblue", "chartreuse3"),
       lwd = 2, bty = "n")

plot(x = test1$generation,
     y = test1$p,
     type = "l", lwd = 2, col = "dodgerblue",
     xlab = "Generationen",
     ylab = "Allelfrequenz",
     ylim = c(0,1),
     main = "s = ?, m = 0.3")
lines(x = test1$generation,
     y = test1$q, 
     type = "l", lwd = 2, col = "chartreuse3")
legend("topright", c("Resistent", "Anfaellig"),
       col = c("dodgerblue", "chartreuse3"),
       lwd = 2, bty = "n")

plot(x = test2$generation,
     y = test2$p,
     type = "l", lwd = 2, col = "dodgerblue",
     xlab = "Generationen",
     ylab = "Allelfrequenz",
     ylim = c(0,1),
     main = "s = 0.5, m = ? ")
lines(x = test2$generation,
     y = test2$q, 
     type = "l", lwd = 2, col = "chartreuse3")
legend("topright", c("Resistent", "Anfaellig"),
       col = c("dodgerblue", "chartreuse3"),
       lwd = 2, bty = "n")

# --- F5 ---
#
# Waehlen Sie in den Simulationen die fehlenden Werte fuer m oder s damit das Muster der Allelfrequenzen zum ersten Graphen (s = 0.25, m = 0.1) passt.
# Welche Werte waehlen Sie?

# ===========================================================================
# B) Zum Experimentieren: F_ST
# ===========================================================================
#
# Nur der Vollstaendigkeit halber: Wie verschieden sind die beiden Populationen am Ende? Das misst F_ST (siehe Folien):
#
#   F_ST = (H_T - H_S) / H_T,     H = 2p(1-p)
#
# H_S ist die mittlere Heterozygotie innerhalb der Populationen, H_T die Heterozygotie, wenn man beide Populationen zusammenwirft. F_ST = 0: kein Unterschied; F_ST = 1: verschiedene Allele fixiert.
#
# Zwei Funktionen, beide geben F_ST aus:
#
# - fst_aus_p(p1, p2) rechnet F_ST direkt aus zwei Allelfrequenzen, zum Beispiel aus gemessenen Daten. Hier gibt es kein Modell, nur die Formel oben.
# - fst_aus_ms(m, s) fragt: Wie gross wird F_ST, wenn Selektion und Migration lange genug gewirkt haben? Die Funktion laesst simulateLA() 1000 Generationen laufen, nimmt die Frequenzen der letzten Generation (Stadt und Land) und gibt sie an fst_aus_p() weiter.
#
# Der Unterschied: Bei fst_aus_p() geben Sie die Frequenzen vor; bei fst_aus_ms() geben Sie die Kraefte vor, und das Modell bestimmt die Frequenzen.

# F_ST aus zwei Allelfrequenzen
fst_aus_p <- function(p1, # Frequenz von R in Population 1
                      p2) # Frequenz von R in Population 2
  {

  p_quer <- (p1 + p2) / 2                          # mittlere Frequenz
  H_S <- (2*p1*(1 - p1) + 2*p2*(1 - p2)) / 2       # innerhalb
  H_T <- 2*p_quer*(1 - p_quer)                     # zusammengeworfen

  return((H_T - H_S) / H_T)
}

# F_ST im Gleichgewicht von Migration und Selektion
fst_aus_ms <- function(m, # Migration
                       s, # Selektionskoeffizient
                       generationen = 1000) # lange laufen lassen
  {

  sim <- simulateLA(p_0 = 0.5, s = s, m = m, generationen = generationen)
  ende <- sim[nrow(sim), ] # letzte Generation

  return(fst_aus_p(ende$p, ende$q))
}

fst_aus_p(p1 = 0.9, p2 = 0.1) # Bitte aendern

fst_aus_ms(m = 0.1, s = 0.1)  # Bitte aendern

# --- Zum Ausprobieren ---
#
# - Wann ist fst_aus_p() gleich 0, wann gleich 1?
# - Verdoppeln Sie in fst_aus_ms() m und s. Was passiert mit F_ST? Und wenn Sie nur m verdoppeln?

# ===========================================================================
# Referenzen
# ===========================================================================
# Lenormand, T., Bourguet, D., Guillemaud, T. et al. *Tracking the evolution of insecticide resistance in the mosquito Culex pipiens*. Nature 400, 861–864 (1999). https://doi.org/10.1038/23685

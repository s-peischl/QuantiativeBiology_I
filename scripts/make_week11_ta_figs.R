# Abbildungen für das TA-Merkblatt Checkpoint C (Woche 11).
# Aus dem Repo-Root ausführen: Rscript scripts/make_week11_ta_figs.R
# Daten und Funktionen kommen direkt aus weeks/week-11/notebook.qmd.

src <- readLines("weeks/week-11/notebook.qmd")
chunks <- grep("^```", src)
start <- grep("^# 0 · ", src)
ende <- grep("^# 1 · ", src)
im_teil0 <- chunks[chunks > start & chunks < ende]
code <- unlist(lapply(seq(1, length(im_teil0), by = 2), function(i)
  src[(im_teil0[i] + 1):(im_teil0[i + 1] - 1)]))
eval(parse(text = code[!grepl("^#\\|", code)]))

dir.create("weeks/week-11/ta-figs", showWarnings = FALSE)
N_fein <- 10^seq(4, 9, length.out = 200)

png("weeks/week-11/ta-figs/abb1_daten.png", width = 1500, height = 950, res = 200)
zeige_daten(main = "Daten: Wildtyp und Mutator")
dev.off()

png("weeks/week-11/ta-figs/mutator_modelle.png", width = 1500, height = 950, res = 200)
zeige_daten(main = "Drei Mutator-Loesungen (von Wildtyp-Loesung A aus)")
lines(N_fein, rettung(N_fein, 0.05, 0.025, 1e-8), col = farben["Wildtyp"], lwd = 2)
lines(N_fein, rettung(N_fein, 0.05, 2.5, 1e-8), col = "grey15", lwd = 5)
lines(N_fein, rettung(N_fein, 0.0005, 0.025, 1e-8), col = "#1b9e77", lwd = 3, lty = 2)
lines(N_fein, rettung(N_fein, 0.05, 0.025, 1e-6), col = "#e7298a", lwd = 2, lty = 3)
legend("bottomright", c("Wildtyp A: s = 0.025, r = 0.05, U = 1e-8",
                        "Mutator nur s: s = 2.5", "Mutator nur r: r = 0.0005",
                        "Mutator nur U: U = 1e-6"),
       col = c(farben["Wildtyp"], "grey15", "#1b9e77", "#e7298a"),
       lwd = c(2, 5, 3, 2), lty = c(1, 1, 2, 3), bty = "n", cex = 0.75)
dev.off()

# Abstand zum Wildtyp in Abhängigkeit von s/r (U = 1e-8)
verh <- 10^seq(-1.5, 0.5, length.out = 200)
ab <- sapply(verh, function(q) abstand(rettung(N0, 1, q, 1e-8), wildtyp))
png("weeks/week-11/ta-figs/abstand_sr.png", width = 1500, height = 950, res = 200)
plot(verh, ab, log = "x", type = "l", lwd = 2.5,
     xlab = "s / r (log-Skala)", ylab = "Abstand zum Wildtyp",
     main = "Nur das Verhaeltnis s/r zaehlt (U = 1e-8)")
abline(h = 0.03, lty = 3, col = "grey50")
abline(v = 0.5, lty = 2, col = farben["Wildtyp"])
dev.off()

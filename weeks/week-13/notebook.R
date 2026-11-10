# Woche 13 - Notebook (nur R)
# Farbe und Form: vier neue Abbildungen mit ggplot2 und Ihre eigene Frage
# In RStudio: Working Directory = weeks/week-13, dann Zeile fuer Zeile ausfuehren.
# Quarto: notebook.qmd. Knit ohne Quarto: notebook.Rmd.

# Letzte Woche haben Sie aus zwei Dateien eine lange Tabelle gemacht und mit ggplot Boxen, Punkte, Facetten und Karten gezeichnet. Heute lernen Sie vier neue Arten von Abbildungen kennen, jede fuer eine andere Frage. Danach stellen Sie Ihre eigene Frage.

# Auftrag
# 1. Vier neue Abbildungen, je fuer eine Frage (ca. 30 min):
#    - Zusammenfassen: Wo ist welche Art haeufig? (Farbfeld)
#    - Veraenderung: Was hat sich von 2019 bis 2024 getan? (Linien und Karte)
#    - Vielfalt: Wie viele Arten leben auf einem Plot?
#    - Zusammenhang: Welche Arten kommen gemeinsam vor?
# 2. Ihre Frage (ca. 20 min): eine Abbildung, ein Titel als Aussage, ein Satz, was sie nicht zeigt.

# ===========================================================================
# 0 · Die Tabellen von letzter Woche
# ===========================================================================
#
# Dieser Block ist der Code aus Woche 12. Weil alles im Code steht, entstehen die Tabellen in einer Sekunde wieder. Einfach ausfuehren.

library(ggplot2)

roh19 <- read.csv("data/rottensand_2019.csv")
roh24 <- read.csv("data/rottensand_2024.csv")

arten <- c("OedCae", "CalIta", "OedGer", "SphCae", "PlaAlb", "ManRel")
namen <- c(OedCae = "Oedipoda caerulescens", CalIta = "Calliptamus italicus",
           OedGer = "Oedipoda germanica", SphCae = "Sphingonotus caerulans",
           PlaAlb = "Platycleis albopunctata", ManRel = "Mantis religiosa")

max_besuch <- function(d, art) {
  zaehlung <- d[, paste0(art, 1:4)]
  apply(zaehlung, 1, function(x) if (all(is.na(x))) NA else max(x, na.rm = TRUE))
}

aufbereiten <- function(roh, jahr) {
  d <- roh[roh$quarter == "tot" & !is.na(roh$temp1), ]
  kurz <- data.frame(plot = d$plot, jahr = jahr, x = d$Xcoo, y = d$Ycoo,
                     habitat = d$habitat.type, temp = d$temp1,
                     boden = d$soil, gras = d$grass, kies = d$gravel,
                     baum = d$canopy, deckung = d$cover.sum, team = d$observ1)
  for (a in arten) kurz[[a]] <- max_besuch(d, a)
  kurz
}

alle <- rbind(aufbereiten(roh19, 2019), aufbereiten(roh24, 2024))
alle <- alle[alle$habitat %in% c("forest", "alluvial", "steppe"), ]
alle$habitat <- factor(alle$habitat, levels = c("forest", "alluvial", "steppe"),
                       labels = c("Wald", "Aue", "Steppe"))

lang <- NULL
for (a in arten) {
  stueck <- alle[, c("plot", "jahr", "x", "y", "habitat", "temp", "boden", "gras", "team")]
  stueck$art <- namen[a]
  stueck$anzahl <- alle[[a]]
  lang <- rbind(lang, stueck)
}

farben <- c(Wald = "#1e8449", Aue = "#5dade2", Steppe = "#e5a50a")

# Zur Erinnerung: alle hat eine Zeile pro Plot und Jahr (breit, eine Spalte pro Art). lang hat eine Zeile pro Plot, Jahr und Art.

# ===========================================================================
# 1 · Zusammenfassen: ein Farbfeld
# ===========================================================================
#
# Frage: Wo ist welche Art im Mittel haeufig?
#
# Statt jeden Plot zu zeigen, rechnen wir zuerst einen Mittelwert pro Art und Lebensraum. aggregate macht aus 1000 Zeilen 18:

mittel <- aggregate(anzahl ~ art + habitat, data = lang, FUN = mean)
mittel

# Ein Farbfeld (geom_tile) zeigt so eine Tabelle auf einen Blick. Die Zahl schreiben wir dazu (geom_text).

ggplot(mittel, aes(x = habitat, y = art, fill = anzahl)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = round(anzahl, 1))) +
  scale_fill_gradient(low = "white", high = "#d35400") +
  labs(x = NULL, y = NULL, fill = "Tiere\npro Plot",
       title = "Mittlere Anzahl pro Plot, beide Jahre") +
  theme_minimal(base_size = 12) +
  theme(axis.text.y = element_text(face = "italic"), panel.grid = element_blank())

# F1
# 1. Welche Art ist am staerksten auf die Steppe beschraenkt? Welche ist auch in der Aue haeufig?
# 2. Aendern Sie FUN = mean zu FUN = median. Was aendert sich, und warum?
# 3. Probieren Sie eine andere Farbskala: Ersetzen Sie scale_fill_gradient(...) durch scale_fill_viridis_c().

# ===========================================================================
# 2 · Veraenderung: 2019 und 2024
# ===========================================================================

# --- Linien zwischen zwei Jahren ---
#
# Frage: Ist eine Art 2024 haeufiger als 2019, und wo?
#
# Ein Mittelwert pro Art, Lebensraum und Jahr, dann eine Linie von 2019 nach 2024:

mj <- aggregate(anzahl ~ art + habitat + jahr, data = lang, FUN = mean)

ggplot(mj, aes(x = factor(jahr), y = anzahl, colour = habitat, group = habitat)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  facet_wrap(~ art, scales = "free_y") +
  scale_colour_manual(values = farben) +
  labs(x = NULL, y = "Tiere pro Plot (Mittel)", colour = NULL) +
  theme_minimal(base_size = 12) +
  theme(strip.text = element_text(face = "italic"), legend.position = "top")

# --- Gekommen, geblieben, verschwunden ---
#
# Frage: Auf welchen Plots ist eine Art neu aufgetaucht?
#
# Dafuer brauchen wir die zwei Jahre nebeneinander: merge ueber den Schluessel plot.

art <- "SphCae"   # bitte aendern

v19 <- alle[alle$jahr == 2019, c("plot", art)]
v24 <- alle[alle$jahr == 2024, c("plot", "x", "y", art)]
beide <- merge(v19, v24, by = "plot", suffixes = c("_2019", "_2024"))
vorher  <- beide[[paste0(art, "_2019")]] > 0
nachher <- beide[[paste0(art, "_2024")]] > 0

beide$status <- ifelse(vorher & nachher, "geblieben",
                ifelse(nachher, "neu",
                ifelse(vorher, "verschwunden", "nie")))
beide$status <- factor(beide$status, levels = c("neu", "geblieben", "verschwunden", "nie"))

ggplot(beide, aes(x = x, y = y, fill = status)) +
  geom_point(shape = 21, size = 3.5, colour = "grey40") +
  scale_fill_manual(values = c(neu = "#28b463", geblieben = "#2471a3",
                               verschwunden = "#cb4335", nie = "grey90")) +
  coord_equal() +
  labs(title = paste(namen[art], "2019 -> 2024"), fill = NULL) +
  theme_void(base_size = 12) +
  theme(plot.title = element_text(face = "italic"))

table(beide$status)

# F2
# 1. Welche Art hat in der Steppe am meisten zugelegt? Welche hat abgenommen?
# 2. Setzen Sie art <- "ManRel" (Gottesanbeterin). Wo ist sie neu?
# 3. Ist Sphingonotus wirklich haeufiger geworden, oder kann ein Teil davon Zaehlglueck sein (Woche 9)? Was wuerden Sie brauchen, um das zu entscheiden?

# ===========================================================================
# 3 · Vielfalt: Arten pro Plot
# ===========================================================================
#
# Frage: Wo leben viele Arten zusammen?
#
# Eine neue Spalte: Wie viele der sechs Arten wurden auf dem Plot gefunden?

alle$n_arten <- rowSums(alle[, arten] > 0)
table(alle$n_arten)

ggplot(alle, aes(x = x, y = y, colour = n_arten)) +
  geom_point(size = 2.5) +
  facet_wrap(~ jahr) +
  scale_colour_viridis_c(breaks = 0:6) +
  coord_equal() +
  labs(colour = "Arten") +
  theme_void(base_size = 12)

ggplot(alle, aes(x = habitat, y = n_arten, fill = habitat)) +
  geom_boxplot(alpha = 0.4, outlier.shape = NA) +
  geom_jitter(aes(colour = habitat), width = 0.2, height = 0.1) +
  facet_wrap(~ jahr) +
  scale_fill_manual(values = farben, guide = "none") +
  scale_colour_manual(values = farben, guide = "none") +
  scale_y_continuous(breaks = 0:6) +
  labs(x = NULL, y = "Arten pro Plot") +
  theme_minimal(base_size = 12)

# F3
# 1. Wo im Gebiet liegen die Plots mit fuenf oder sechs Arten?
# 2. Ersetzen Sie scale_colour_viridis_c() durch scale_colour_viridis_c(option = "magma") oder "plasma". Welche Skala lesen Sie am leichtesten?
# 3. Ein Plot mit null Arten: Heisst das, dort lebt keine Heuschrecke?

# ===========================================================================
# 4 · Zusammenhang: Welche Arten kommen gemeinsam vor?
# ===========================================================================
#
# Frage: Wenn auf einem Plot viele Calliptamus sind, sind dort auch viele Oedipoda germanica?
#
# Zuerst fuer zwei Arten:

ggplot(alle, aes(x = CalIta, y = OedGer, colour = habitat)) +
  geom_jitter(width = 0.3, height = 0.3, alpha = 0.7, size = 2) +
  scale_colour_manual(values = farben) +
  labs(x = "Calliptamus italicus", y = "Oedipoda germanica", colour = NULL) +
  theme_minimal(base_size = 12)

# Fuer alle Paare auf einmal: die Korrelation zwischen je zwei Arten (zwischen -1 und 1), wieder als Farbfeld.

k <- cor(alle[, arten])
k_lang <- as.data.frame(as.table(k))
names(k_lang) <- c("art1", "art2", "r")

ggplot(k_lang, aes(x = art1, y = art2, fill = r)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = round(r, 2)), size = 3.5) +
  scale_fill_gradient2(low = "#2166ac", mid = "white", high = "#b2182b", limits = c(-1, 1)) +
  labs(x = NULL, y = NULL, fill = "r") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# F4
# 1. Welche zwei Arten kommen am haeufigsten gemeinsam vor?
# 2. Fast alle Korrelationen sind positiv. Heisst das, die Arten helfen einander? Tipp: Schauen Sie die Farben im Streudiagramm an.
# 3. Rechnen Sie die Korrelation nur fuer die Steppe: cor(alle[allehabitat == "Steppe", arten]). Was aendert sich?

# ===========================================================================
# 5 · Ihre Frage (ca. 20 min)
# ===========================================================================
#
# Waehlen Sie eine Frage, machen Sie eine Abbildung, und schreiben Sie:
#
# - einen Titel, der die Aussage sagt,
# - einen Satz, was die Abbildung nicht zeigt.
#
# Speichern Sie sie mit ggsave("meine_frage.png", width = 8, height = 5) und zeigen Sie sie der Assistenz.
#
# | Frage | Tabelle | Start |
# |---|---|---|
# | Moegen die blaufluegeligen Arten offenen Boden? | lang | aes(x = boden, y = anzahl) + geom_point + facet_wrap(~ art) |
# | Zaehlt man bei Hitze mehr? | lang | aes(x = temp, y = anzahl) + geom_smooth() |
# | Zaehlen Teams verschieden, und liegt das an den Orten? | lang | aes(x = team, y = anzahl, colour = habitat) |
# | Haengt die Vielfalt am Gras? | alle | aes(x = gras, y = n_arten) |
# | Wo lebt die Gottesanbeterin, und wo ist sie neu? | lang, beide | Abschnitt 2 mit art <- "ManRel" |
# | Ihre eigene Frage | | |

# F5 · Ihre Abbildung
# "Die Abbildung zeigt ... . Sie zeigt nicht, ... ."

# --- Bonus · eine Abbildung als Funktion ---
#
# Gefaellt Ihnen eine Abbildung, machen Sie eine Funktion daraus. Dann ist jede Variante eine Zeile, und dieselbe Abbildung entsteht immer gleich.

karte <- function(welche_art, welches_jahr) {
  d <- lang[lang$art == namen[welche_art] & lang$jahr == welches_jahr, ]
  ggplot(d, aes(x = x, y = y, size = anzahl, colour = habitat)) +
    geom_point(alpha = 0.7) +
    scale_colour_manual(values = farben) +
    scale_size_area(max_size = 6) +
    coord_equal() +
    labs(title = paste(namen[welche_art], welches_jahr)) +
    theme_void() +
    theme(plot.title = element_text(face = "italic"))
}

karte("CalIta", 2024)

# for (a in arten) {
#   ggsave(paste0("karte_", a, "_2024.png"), karte(a, 2024), width = 8, height = 3)
# }

# Sechs Dateien in einer Schleife. Naechstes Jahr kommen neue Daten: eine Zahl aendern, alles neu.
#
# Daten: Feldpraktikum Conservation Biology, Universitaet Bern (Rottensand 2019 und 2024), mit freundlicher Genehmigung. Die Kuerzel der Beobachterinnen und Beobachter sind durch Teamcodes ersetzt.

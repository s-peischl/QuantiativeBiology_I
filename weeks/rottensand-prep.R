# Rottensand-Tabellen für die Folien von Woche 12 und 13 (echo: false).
# Dieselben Schritte wie im Notebook von Woche 12. Aufruf aus weeks/week-XX/.

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
                     boden = d$soil, gras = d$grass, kraut = d$forb,
                     kies = d$gravel, stein = d$stone + d$rock,
                     baum = d$canopy, deckung = d$cover.sum,
                     team = d$observ1)
  for (a in arten) kurz[[a]] <- max_besuch(d, a)
  kurz
}

k19 <- aufbereiten(roh19, 2019)
k24 <- aufbereiten(roh24, 2024)
beide <- merge(k19, k24, by = "plot", suffixes = c("_2019", "_2024"))
alle <- rbind(k19, k24)

drei <- alle[alle$habitat %in% c("alluvial", "forest", "steppe"), ]
drei$habitat <- factor(drei$habitat, levels = c("forest", "alluvial", "steppe"),
                       labels = c("Wald", "Aue", "Steppe"))
hab_farben <- c(Wald = "#1e8449", Aue = "#5dade2", Steppe = "#e5a50a")

# Lange Tabelle: eine Zeile pro Plot, Jahr und Art
lang <- do.call(rbind, lapply(arten, function(a)
  data.frame(drei[, c("plot", "jahr", "x", "y", "habitat")],
             art = factor(namen[a], levels = namen), anzahl = drei[[a]])))

# Rottensand-Daten für Woche 12 und 13 aus den Rohdaten erzeugen.
# Aus dem Repo-Root ausführen: Rscript scripts/make_rottensand_data.R
#
# Quelle (ausserhalb des Repos): ../examples/ConservationBio/
#   Rottensand_data_2019_final.xlsx, Blatt "Rottensand_data_tot_2019"
#   Rottensand_data_tot_2024.csv
#
# Was das Skript ändert, und nur das:
#   - 2019 wird aus Excel als CSV geschrieben ("NA" ist in Excel als Text eingetragen).
#   - Die Kürzel der Beobachterinnen (observ1-4) werden durch Teamcodes ersetzt.
# Alles andere bleibt roh: Zeilen pro Quadrant, nicht besuchte Plots, Zeitformate.

suppressMessages(library(readxl))

quelle <- "../examples/ConservationBio"
d19 <- as.data.frame(read_excel(file.path(quelle, "Rottensand_data_2019_final.xlsx"),
                                sheet = "Rottensand_data_tot_2019", na = "NA",
                                .name_repair = "minimal"))
d24 <- read.csv(file.path(quelle, "Rottensand_data_tot_2024.csv"), check.names = FALSE)

pseudonym <- function(d, jahr) {
  sp <- paste0("observ", 1:4)
  kuerzel <- sort(unique(na.omit(unlist(d[, sp]))))
  kuerzel <- setdiff(kuerzel, "All")
  code <- setNames(paste0("Team ", LETTERS[seq_along(kuerzel)]), kuerzel)
  code <- c(code, All = "alle")
  for (s in sp) d[[s]] <- unname(code[d[[s]]])
  d
}

d19 <- pseudonym(d19, 2019)
d24 <- pseudonym(d24, 2024)

for (woche in c("week-12", "week-13")) {
  ziel <- file.path("weeks", woche, "data")
  dir.create(ziel, showWarnings = FALSE)
  write.csv(d19, file.path(ziel, "rottensand_2019.csv"), row.names = FALSE, na = "NA")
  write.csv(d24, file.path(ziel, "rottensand_2024.csv"), row.names = FALSE, na = "NA")
}
cat("2019:", dim(d19), " 2024:", dim(d24), "\n")

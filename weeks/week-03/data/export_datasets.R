library(gauseR)

dir3 <- "/Users/stephan/Dropbox/Teaching/BridgeCourse/Part1_HS/2026_HS/course-outline/weeks/week-03/data"
dir4 <- "/Users/stephan/Dropbox/Teaching/BridgeCourse/Part1_HS/2026_HS/course-outline/weeks/week-04/data"
dir.create(dir3, recursive = TRUE, showWarnings = FALSE)
dir.create(dir4, recursive = TRUE, showWarnings = FALSE)

f22 <- gause_1934_book_f22

pc <- subset(f22, Treatment == "Pc")
pc_out <- data.frame(
  day = pc$Day,
  volume = pc$Volume_Species1,
  species = "Paramecium caudatum",
  treatment = "monoculture",
  source = "gauseR::gause_1934_book_f22",
  citation = "Gause (1934) The Struggle for Existence, Fig. 22"
)
pc_out <- pc_out[order(pc_out$day), ]

pa <- subset(f22, Treatment == "Pa")
pa_out <- data.frame(
  day = pa$Day,
  volume = pa$Volume_Species2,
  species = "Paramecium aurelia",
  treatment = "monoculture",
  source = "gauseR::gause_1934_book_f22",
  citation = "Gause (1934) The Struggle for Existence, Fig. 22"
)
pa_out <- pa_out[order(pa_out$day), ]

mix <- subset(f22, Treatment == "Mixture")
mix <- mix[order(mix$Day), ]
mix_out <- data.frame(
  day = mix$Day,
  caudatum = mix$Volume_Species1,
  aurelia = mix$Volume_Species2,
  treatment = "mixture",
  source = "gauseR::gause_1934_book_f22",
  citation = "Gause (1934) The Struggle for Existence, Fig. 22"
)

write.csv(pc_out, file.path(dir3, "paramecium_caudatum_alone.csv"), row.names = FALSE)
write.csv(pa_out, file.path(dir3, "paramecium_aurelia_alone.csv"), row.names = FALSE)
write.csv(mix_out, file.path(dir3, "paramecium_competition.csv"), row.names = FALSE)

long <- rbind(
  data.frame(day = pc_out$day, species = "caudatum", volume = pc_out$volume, treatment = "alone"),
  data.frame(day = pa_out$day, species = "aurelia", volume = pa_out$volume, treatment = "alone"),
  data.frame(day = mix_out$day, species = "caudatum", volume = mix_out$caudatum, treatment = "mixture"),
  data.frame(day = mix_out$day, species = "aurelia", volume = mix_out$aurelia, treatment = "mixture")
)
long$source <- "gauseR::gause_1934_book_f22"
write.csv(long, file.path(dir3, "paramecium_competition_long.csv"), row.names = FALSE)

# Week 4: Isle Royale moose–wolf (McLaren & Peterson 1994)
mc <- mclaren_1994_f03
moose <- subset(mc, Species == "Alces alces")
wolf <- subset(mc, Species == "Canis lupus")
yrs <- sort(intersect(moose$year, wolf$year))
mw <- data.frame(
  year = yrs,
  moose = moose$individuals[match(yrs, moose$year)],
  wolf = wolf$individuals[match(yrs, wolf$year)],
  aet_mm = moose$AET..mm.[match(yrs, moose$year)],
  source = "gauseR::mclaren_1994_f03",
  citation = "McLaren & Peterson (1994) Science; Isle Royale moose-wolf; digitized in gauseR"
)
write.csv(mw, file.path(dir4, "isle_royale_moose_wolf.csv"), row.names = FALSE)

# Optional: Huffaker mites (60-week treatment only)
hf <- subset(huffaker_1963, as.character(Treatment) == "60 weeks")
prey_df <- subset(hf, grepl("Prey|Eotetranychus", as.character(Species)))
pred_df <- subset(hf, grepl("Predator|Typhlodromus|Metaseiulus", as.character(Species), ignore.case = TRUE))
wks <- sort(intersect(prey_df$Weeks, pred_df$Weeks))
hf_out <- data.frame(
  week = wks,
  prey = prey_df$Individuals[match(wks, prey_df$Weeks)],
  predator = pred_df$Individuals[match(wks, pred_df$Weeks)],
  source = "gauseR::huffaker_1963",
  citation = "Huffaker 60-week mite predator-prey; digitized in gauseR"
)
write.csv(hf_out, file.path(dir4, "huffaker_mites.csv"), row.names = FALSE)

# Optional classic lynx pelts
ly <- data.frame(
  year = as.numeric(time(lynx)),
  lynx_pelts = as.numeric(lynx),
  source = "R datasets::lynx",
  citation = "Annual Canadian lynx trappings 1821-1934; R datasets::lynx"
)
write.csv(ly, file.path(dir4, "hudson_bay_lynx.csv"), row.names = FALSE)

message("Week 3 files: ", paste(list.files(dir3), collapse = ", "))
message("Week 4 files: ", paste(list.files(dir4), collapse = ", "))
message("Moose-wolf years: ", nrow(mw), " range ", min(mw$year), "-", max(mw$year))
message("Huffaker weeks: ", nrow(hf_out))

library(gauseR)

dir <- "/Users/stephan/Dropbox/Teaching/BridgeCourse/Part1_HS/2026_HS/course-outline/weeks/week-02/data"

alone <- subset(
  gause_1934_book_f21,
  Species == "Paramecium caudatum" & !is.na(Individuals)
)
alone_out <- data.frame(
  day = alone$Time,
  paramecium = alone$Individuals,
  source = "gauseR::gause_1934_book_f21",
  citation = "Gause (1934) The Struggle for Existence, Fig. 21 (Paramecium caudatum monoculture)"
)
alone_out <- alone_out[order(alone_out$day), ]

mix <- gause_1934_book_f32
mix_out <- data.frame(
  day = mix$Day,
  paramecium = mix$Individuals_Prey,
  didinium = mix$Individuals_Predator,
  immigration = as.character(mix$Immigration),
  source = "gauseR::gause_1934_book_f32",
  citation = "Gause (1934) The Struggle for Existence, Fig. 32"
)
mix_out <- mix_out[order(mix_out$day), ]

ext <- gause_1934_book_f30
prey <- subset(ext, grepl("Paramecium", as.character(Species)))
pred <- subset(ext, grepl("Didinium", as.character(Species)))
ext_out <- data.frame(
  day = prey$Time,
  paramecium = prey$Individuals,
  didinium = pred$Individuals[match(prey$Time, pred$Time)],
  source = "gauseR::gause_1934_book_f30",
  citation = "Gause (1934) The Struggle for Existence, Fig. 30 (Osterhout)"
)

write.csv(alone_out, file.path(dir, "paramecium_alone.csv"), row.names = FALSE)
write.csv(mix_out, file.path(dir, "paramecium_with_didinium.csv"), row.names = FALSE)
write.csv(ext_out, file.path(dir, "paramecium_didinium_extinction.csv"), row.names = FALSE)

message("Wrote real Gause CSVs to ", dir)

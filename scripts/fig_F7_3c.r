## F7 spatial map of 3-component composite, similar to existing F7 in figures_v04
suppressPackageStartupMessages({
  library(terra); library(ggplot2); library(viridis)
})

INPUT <- "/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/CSPI_v21_3component_30m.tif"
OUT_PNG <- "/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/F7_cspi_v21_3c_map.png"
OUT_PDF <- "/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/F7_cspi_v21_3c_map.pdf"

cat("Reading 3-component composite...\n")
r <- rast(INPUT)
cat("Surface dims:", dim(r), "res:", res(r), "\n")

# Aggregate to ~1 km for the figure (1 km ≈ 30 m × 33)
cat("Aggregating to 1 km for figure...\n")
r_low <- aggregate(r, fact = 33, fun = "mean", na.rm = TRUE,
                   filename = tempfile(fileext = ".tif"),
                   overwrite = TRUE)
cat("Aggregated dims:", dim(r_low), "res:", res(r_low), "\n")

# Convert to data frame for ggplot
df <- as.data.frame(r_low, xy = TRUE, na.rm = TRUE)
names(df)[3] <- "value"
cat("Plot points:", nrow(df), "\n")

# Build the map
p <- ggplot(df, aes(x = x, y = y, fill = value)) +
  geom_raster(interpolate = FALSE) +
  scale_fill_viridis_c(name = "CSPI v2 (3-comp)\n0–100", option = "viridis",
                       limits = c(0, 100), na.value = "transparent") +
  coord_fixed(ratio = 1.0) +
  theme_minimal(base_size = 11) +
  theme(panel.grid = element_blank(),
        axis.title = element_blank(),
        axis.text = element_text(size = 8),
        legend.position = "right",
        legend.key.height = unit(1.5, "cm")) +
  labs(title = "CSPI v2: 3-component composite (ESI + BGI + Asym) at 30 m, displayed at 1 km",
       subtitle = "z-score equal-weight average over CONUS; gray = no data (non-forest / out of analysis extent)")

ggsave(OUT_PNG, p, width = 10, height = 6, dpi = 300, bg = "white")
ggsave(OUT_PDF, p, width = 10, height = 6, bg = "white")
cat("Wrote", OUT_PNG, "and", OUT_PDF, "\n")

# Summary stats
cat("\nSurface summary stats:\n")
gs <- global(r_low, c("min","max","mean","sd"), na.rm = TRUE)
print(gs)

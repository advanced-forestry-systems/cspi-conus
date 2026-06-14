## Fix the SSURGO join: the gSSURGO mukey raster returns a factor on extract,
## so as.integer(mk) maps to factor level (1,2,3,...) not the underlying mukey
## value. Use as.integer(as.character(mk)) instead.

suppressPackageStartupMessages({ library(data.table); library(terra) })

V7_DIR <- "/fs/scratch/PUOM0008/crsfaaron/cspi_v7"
OUT    <- file.path(V7_DIR, "multidim_v4")

plt <- fread(file.path(V7_DIR, "multidim_v2/plt_ext_4c_plus_FIA.csv"))
plt_xy <- plt[!is.na(LAT) & !is.na(LON)]
r <- rast("/fs/scratch/PUOM0008/crsfaaron/FIA/asym_agb_analysis/environmental_data/gssurgo/mukey_raster.tif")
pts <- vect(plt_xy[, .(LON, LAT)], geom = c("LON","LAT"), crs = "EPSG:4326")
pts <- project(pts, crs(r))
mk <- terra::extract(r, pts, ID = FALSE)[, 1]
plt_xy[, mukey := as.integer(as.character(mk))]
cat("plot mukeys with valid integer:", sum(!is.na(plt_xy$mukey)), "\n")

dom <- fread(file.path(OUT, "E1b_ssurgo_si_per_mukey.csv"))
dom[, mukey := as.integer(mukey)]

plt_xy <- merge(plt_xy, dom[, .(mukey, ssurgo_si_m, ssurgo_si_base)],
                by = "mukey", all.x = TRUE)
plt_xy[, SICOND_m := SICOND * 0.3048]
n_with <- sum(!is.na(plt_xy$ssurgo_si_m))
cat("plots with SSURGO SI (FIXED join):", n_with, "of", nrow(plt_xy), "\n")

cor_mat <- plt_xy[!is.na(ssurgo_si_m), .(
  measure = c("ESI", "BGI", "Asym", "NPP", "SICOND_raw", "CSPI_3c"),
  r_with_SSURGO_SI = round(c(
    cor(ssurgo_si_m, esi   , use = "p"),
    cor(ssurgo_si_m, bgi_v , use = "p"),
    cor(ssurgo_si_m, asym_v, use = "p"),
    cor(ssurgo_si_m, npp_v , use = "p"),
    cor(ssurgo_si_m, SICOND_m, use = "p"),
    {
      mu <- list(esi = 27.81, bgi = 1.72, asym = 249.1)
      sd <- list(esi = 11.41, bgi = 0.58, asym = 20.3)
      z_esi  <- pmax(pmin((plt_xy$esi    - mu$esi ) / sd$esi , 3), -3)
      z_bgi  <- pmax(pmin((plt_xy$bgi_v  - mu$bgi ) / sd$bgi , 3), -3)
      z_asym <- pmax(pmin((plt_xy$asym_v - mu$asym) / sd$asym, 3), -3)
      cor(plt_xy$ssurgo_si_m, (z_esi + z_bgi + z_asym) / 3, use = "p")
    }
  ), 3),
  n = sum(!is.na(ssurgo_si_m) & !is.na(esi))
)]
print(cor_mat)
fwrite(cor_mat, file.path(OUT, "E2c_ssurgo_correlations_fixed.csv"))
fwrite(plt_xy[, .(key, LAT, LON, mukey, ssurgo_si_m, ssurgo_si_base,
                  SICOND_m, esi, bgi_v, asym_v, npp_v, SITECLCD, STDAGE)],
       file.path(OUT, "E3c_plt_with_ssurgo_fixed.csv"))
cat("\n=== Fixed SSURGO join done ===\n")

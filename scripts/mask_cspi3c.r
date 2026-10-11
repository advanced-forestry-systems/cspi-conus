## Forest mask for CSPI v2.1 3-component composite, mirrors mask_cspi_v2.r
##
## Forest = Hansen 2000 tree cover >= TC_MIN percent, the definition stated in
## README and NEWS_v3.0.0. An earlier version of this script used >= 10%, so any
## CSPI_v21_3component_30m_forest.tif built before 2026-10 used the looser mask
## and should be regenerated. Hansen NA cells are masked as well.
suppressPackageStartupMessages({ library(terra) })
TC_MIN <- 30
terraOptions(memmax = 24)
v3c <- rast("/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/CSPI_v21_3component_30m.tif")
hansen <- rast("/fs/scratch/PUOM0008/crsfaaron/cspi_v3/aligned_30m/h_tc2000.tif")
if (!compareGeom(v3c, hansen, stopOnError = FALSE)) {
  stop("Hansen layer is not aligned to the CSPI grid; align it before masking")
}
forest <- hansen >= TC_MIN
v3c_mask <- mask(v3c, forest, maskvalues = c(0, NA))
writeRaster(v3c_mask, "/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/CSPI_v21_3component_30m_forest.tif",
            datatype = "FLT4S", overwrite = TRUE,
            gdal = c("COMPRESS=LZW","TILED=YES","BIGTIFF=YES"))
cat("CSPI v21 3-component forest mask written (Hansen tree cover >=", TC_MIN, "%)\n")

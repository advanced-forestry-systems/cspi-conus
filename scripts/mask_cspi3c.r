## Forest mask for CSPI v2.1 3-component composite, mirrors mask_cspi_v2.r
suppressPackageStartupMessages({ library(terra) })
v3c <- rast("/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/CSPI_v21_3component_30m.tif")
hansen <- rast("/fs/scratch/PUOM0008/crsfaaron/cspi_v3/aligned_30m/h_tc2000.tif")
forest <- hansen >= 10
terraOptions(memmax = 24)
v3c_mask <- mask(v3c, forest, maskvalues = 0)
writeRaster(v3c_mask, "/users/PUOM0008/crsfaaron/raster_layers/cspi_rs/CSPI_v21_3component_30m_forest.tif",
            datatype = "FLT4S", overwrite = TRUE,
            gdal = c("COMPRESS=LZW","TILED=YES","BIGTIFF=YES"))
cat("CSPI v21 3-component forest mask written\n")

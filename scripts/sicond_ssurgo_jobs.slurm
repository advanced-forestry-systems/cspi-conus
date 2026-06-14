#!/bin/bash
#SBATCH --job-name=sicond_ssurgo
#SBATCH --time=03:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --account=PUOM0008
#SBATCH --output=/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/sicond_ssurgo_%j.out
#SBATCH --error=/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/sicond_ssurgo_%j.err
module load gcc/12.3.0 gdal/3.7.3 geos/3.12.0 proj/9.2.1 R/4.4.0
echo "=== SICOND base-50 standardization ==="
Rscript --vanilla /users/PUOM0008/crsfaaron/fvs-conus/R/eval/cspi_v3/sicond_base50.r
echo "=== SSURGO soil SI extraction ==="
Rscript --vanilla /users/PUOM0008/crsfaaron/fvs-conus/R/eval/cspi_v3/ssurgo_si.r
echo "Done."

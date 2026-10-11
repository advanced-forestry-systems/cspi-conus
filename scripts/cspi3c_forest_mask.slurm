#!/bin/bash
#SBATCH --job-name=cspi3c_fm
#SBATCH --time=03:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --account=PUOM0008
#SBATCH --output=/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/cspi3c_fm_%j.out
#SBATCH --error=/fs/scratch/PUOM0008/crsfaaron/cspi_v7/logs/cspi3c_fm_%j.err
set -euo pipefail
module load gcc/12.3.0 gdal/3.7.3 geos/3.12.0 proj/9.2.1 R/4.4.0

# Forest-mask the 3-component composite (Hansen 2000 tree cover >= 30%).
# Input:  CSPI_v21_3component_30m.tif (42.5 GB)
# Output: CSPI_v21_3component_30m_forest.tif
#
# This job previously carried its own inline R that picked whichever
# forest_mask*.tif sorted first and masked only zero cells, so it never applied
# the 30% threshold it described. It now runs the single canonical script,
# which uses an explicit Hansen layer and threshold.
Rscript --vanilla /users/PUOM0008/crsfaaron/fvs-conus/R/eval/cspi_v3/mask_cspi3c.r
echo "Done."

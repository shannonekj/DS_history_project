#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J download
#SBATCH -e 01_download_data.err
#SBATCH -o 01_download_data.out
#SBATCH -c 20
#SBATCH -p med
#SBATCH --time=1-20:00:00

set -e
set -x

#  This script will download all raw RAD data for Delta Smelt from 1995-2012
#	Run with 
#		sbatch -t 1-20:00:00 -p med -A millermrgrp --mem MaxMemPerNode 01_download_data.sh
# don't forget to change modifications to raw files after download

cd /home/sejoslin/projects/DS_history
echo "starting at " date

# make directories to put data into BMAG0044-BMAG0049
mkdir BMAG04{4..9}

#download and sort
wget -r -nH -nc -np -R index.html*    http://slims.bioinformatics.ucdavis.edu/Data/ku4gsq0sv/
mv Data BMAG044/.
date

wget -r -nH -nc -np -R index.html*    http://slims.bioinformatics.ucdavis.edu/Data/9e5t5ne0im/
mv Data BMAG045/.
date

wget -r -nH -nc -np -R index.html*    http://slims.bioinformatics.ucdavis.edu/Data/bdg476uxsz/
mv Data BMAG046/.
date

wget -r -nH -nc -np -R index.html*    http://slims.bioinformatics.ucdavis.edu/Data/m65yjeznnr/
mv Data BMAG047/.
date

wget -r -nH -nc -np -R index.html*    http://slims.bioinformatics.ucdavis.edu/Data/yiokek2c6/
mv Data BMAG048/.
date

wget -r -nH -nc -np -R index.html*    http://slims.bioinformatics.ucdavis.edu/Data/fi07rhwco/
mv Data BMAG049/.
date

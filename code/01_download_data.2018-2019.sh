#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J download
#SBATCH -e 01_download_data.2014-2017.%j.err
#SBATCH -o 01_download_data.2014-2017.%j.out
#SBATCH -c 20
#SBATCH -p med
#SBATCH --time=1-20:00:00
#SBATCH --mem MaxMemPerNode

set -e
set -x

#  This script will download all raw RAD data for Delta Smelt from 2014-2017
# don't forget to change modifications to raw files after download

cd /home/sejoslin/projects/DS_history/data
echo "starting at " $(date)

# make directories to put data into BMAG0055
mkdir BMAG055
cd BMAG055

#download and sort
wget -r -nH -nc -np -R index.html*    http://slimsdata.genomecenter.ucdavis.edu/Data/gvwvs9q993/Un100bp/Project_BMAG_L4_BMAG055/
date
echo "Download complete!"

#move
mv Data/gvwvs9q993/Un100bp/Project_BMAG_L4_BMAG055/* .
rm -rf Data

echo "Checking md5sums"
md5sum -c @md5Sum.md5

echo "ready to unzip!"

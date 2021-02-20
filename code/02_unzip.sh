#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J unzip
#SBATCH -e 02_unzip.err
#SBATCH -o 02_unzip.out
#SBATCH -c 20
#SBATCH -p med
#SBATCH --time=1-20:00:00

set -e
set -x

#  This script will unzip all raw RAD data for Delta Smelt from 1995-2012
#       Run with
#               sbatch -t 1-20:00:00 -p med -A millermrgrp --mem MaxMemPerNode 02_unzip.sh

cd /home/sejoslin/projects/DS_history/

date

for i in BMAG04*
do
cd $i
for file in *.gz
do
newname=$(basename $file .gz)
echo "unzipping " $file " to " $newname
gunzip $file
chmod a=r $newname
done
cd ../
done

date


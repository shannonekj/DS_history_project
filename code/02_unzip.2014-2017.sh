#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J unzip
#SBATCH -e 02_unzip.2014-2017.%j.err
#SBATCH -o 02_unzip.2014-2017.%j.out
#SBATCH -c 20
#SBATCH -p med
#SBATCH --time=1-20:00:00
#SBATCH --mem MaxMemPerNode

set -e
set -x

work_dir="/home/sejoslin/projects/DS_history/data/BMAG055"

#  This script will unzip all raw RAD data for Delta Smelt from 2014-2017

cd ${work_dir}

date

for file in *.gz
do
	echo First get md5sums
	md5sum ${file}
	newname=$(basename $file .gz)
	echo "Unzipping " ${file} " to " ${newname}
	gunzip ${file}
	chmod a=r ${newname}
done

echo FInished at $(date)


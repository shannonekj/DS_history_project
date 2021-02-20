#!/bin/bash
#BATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J findBEST
#SBATCH -e 06_find_best.%j.err
#SBATCH -o 06_find_best.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00

set -e # exits upon failing command
set -v # verbose -- all lines
#set -x # trace of all commands after expansion before execution

# run script with
#       sbatch --mem MaxMemPerNode 06_find_best.sh

# set up directories
code_dir="/home/sejoslin/projects/DS_history/code"
data_dir="/home/sejoslin/projects/DS_history/data"
sum_file="/home/sejoslin/projects/DS_history/data/line_count.all"

cd ${data_dir}
touch ${sum_file}

# go into the run's directory
for i in BMAG04*
do
cd ${i}
echo "Renaming the files for" ${i}
echo "They are:"
  # then go into each library's directory
  for library in 04_split_wells.${i}.??????.sh
  do
  index=$(echo ${library} | cut -d. -f3)
  echo ${index}
  cd ${index}
  wc -l *R?.fastq >> ${sum_file}
  cd ../
  done
cd ../
done

sort -n ${sum_file} > ${sum_file}.sorted

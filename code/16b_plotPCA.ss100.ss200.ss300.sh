#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J plotPCA
#SBATCH -e 16b_plotPCA.ss100.ss200.ss300.%j.err
#SBATCH -o 16b_plotPCA.ss100.ss200.ss300.%j.out
#SBATCH -c 20
#SBATCH --time=20:00:00
#SBATCH --mem=32G
#SBATCH -p high

set -e # exits upon failing command
set -v # verbose -- all lines

# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
loci_dir="/home/sejoslin/projects/${pop}/data/id_loci/PRICE"
RAD_dir="${data_dir}/RAD_alignments"
PCA_dir="${data_dir}/RAD_PCA"

cd ${PCA_dir}


# Make annotated file for each ss
for i in ${pop}.*.ss?00.bamlist
do
	base=$(echo $i | cut -d. -f5)
	echo "BATCH_BATCH-WELL_YEAR_WELL_IND" | awk -F_ '{print $1"\t"$2"\t"$3"\t"$4"\t"$5}' > ${pop}.${base}.clst
	cat $i | sed 's:.*alignments/::g' | sed 's:.sort.proper.rmdup.bam::g' | sed 's:\-:_:g' | awk -F_ '{print $1"\t"$1"_"$4"\t"$3"\t"$4"\t"$1"-"$2"_"$3"_"$4}' >> ${pop}.${base}.clst
        # $1 = Ht??
        # $2 = batch_ind number
        # $3 = year
        # $4 = well
done



# plot all PCAs denoting each year with a different color






# Call on an R script to plot PCA for individuals over 100k, 200k, and 300k reads

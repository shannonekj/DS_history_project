#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J geno2genepop
#SBATCH -e 19c_popGen_contempNe_rand30_geno2genepop.err
#SBATCH -o 19c_popGen_contempNe_rand30_geno2genepop.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES:



# set up directories
pop="DS_history"
cutoff="30"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
PCA_dir="${data_dir}/RAD_PCA"
PARA_dir="${para_dir}/results_paralogs"
theta_dir="${data_dir}/popgen_theta"
out_dir="${data_dir}/ANGSD_calledGenotypes${cutoff}"

yearList="${para_dir}/year.list"

cd ${out_dir}


#####################################
###    convert geno to genepop    ###
#####################################
# Note we are no longer using years 1993, 2000, 2007 due to having too few loci from too few individuals (n=9, 6, 1, respectively)
# Refer to the refined top 100 bamlist generated in estimating long term theta to grab individuals for 


Rscript #script to go from geno to genepop
# add a component to make a list of the loci


#shell: add Ind
for gp_files in Ht*.genepop
do
	for n in $(seq 1 30)
	do
		sed -i "${n}s/^/Ind${n}, /" ${gp_files}
	done
	# add Pop at the beginning of the file
	sed -i '1iPop' ${gp_files}
	echo Completed ${gp_files}
done


#make line with the list of loci






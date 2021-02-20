#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J formatNeEst
#SBATCH -e 19c_popGen_contempNe_rand30_findCommonSNPs.%j.err
#SBATCH -o 19c_popGen_contempNe_rand30_findCommonSNPs.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES:
# Use the same random 30 individuals created in 19b_popGen_contempNe_rand30_callGeno

# First, find the SNPs that all files have in common. These SNPs will have passed the following QC:
#	minMAF
#	minInd
#	minMap
#	minMap
#	minMapQ
#	postCutoff
#	not a paralog
#	SNP p-value 
# Next, pull common SNPs from the geno files into new files with common SNPs.
# Finally, convert all geno files to genepop using PopGenTools.pl



# set up directories
pop="DS_history"
cutoff="30"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
PCA_dir="${data_dir}/RAD_PCA"
PARA_dir="${para_dir}/results_paralogs"
theta_dir="${data_dir}/popgen_theta"
out_dir="${data_dir}/ANGSD_calledGenotypes${cutoff}"

ref="${para_dir}/DS_history_contigs_250.fasta"
noPara="${PARA_dir}/DS_history.rand20.same.29.loci"
noHybs="${PCA_dir}/Refined_Individuals.list"
yearList="${para_dir}/year.list"

cd ${out_dir}


####################################
###       find common SNPs       ###
###   convert geno to genepop    ###
####################################
# Note we are no longer using years 1993, 2000, 2007 due to having too few loci from too few individuals (n=9, 6, 1, respectively)
# Refer to the refined top 100 bamlist you generated in estimating long term theta to grab individuals for 



		echo "echo Unzipping Ht_${year}_callGeno.geno" >> Ht_${year}_callGeno.sh
		echo "gunzip Ht_${year}_callGeno.geno.gz" >> Ht_${year}_callGeno.sh
		echo "echo Now onto converting geno files to GENEPOP format \$(date)" >> Ht_${year}_callGeno.sh
		echo "perl /home/sejoslin/scripts/PopGenTools_3.00.pl GENEPOP \
-g Ht_${year}_callGeno.geno \
-n ${cutoff} \
-o Ht_${year}_callGeno.${cutoff}.genepop" >> Ht_${year}_callGeno.sh
		echo "gzip Ht_${year}_callGeno.geno" >> Ht_${year}_callGeno.sh

#submit jobs
# divide onto different partitions with comparison operators
if [[ ${year} -lt 2000 ]]
        then
        sbatch -p bigmemh Ht_${year}_callGeno.sh
        elif [[ ${year} -ge 2000 && ${year} -le 2010 ]]
                then
                sbatch -p bigmemm Ht_${year}_callGeno.sh
                elif [[ ${year} -gt 2010 ]]
                        then
                        sbatch -p high Ht_${year}_callGeno.sh
                        else
                                echo ${year} "Not a valid year!"
fi
        x=$(( $x + 1 ))
done



## After this make an NeEstimator files by concatenating the genepop files and go to town!






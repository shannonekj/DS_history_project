#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J g2gp
#SBATCH -e 19c_popGen_contempNe_geno2genepop.%j.err
#SBATCH -o 19c_popGen_contempNe_geno2genepop.%j.out
#SBATCH -p bigmemh
#SBATCH --time=2-20:00:00
#SBATCH --mem=MaxMemPerNode

set -e
set -x

# NOTES
# This script will convert all geno files created in the last step to genepop files for input into NeEstimator

# set up directories
pop="DS_history"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
PCA_dir="${data_dir}/RAD_PCA"
PARA_dir="${para_dir}/results_paralogs"
theta_dir="${data_dir}/popgen_theta"
out_dir="${data_dir}/popgen_calledGenotype"

ref="${para_dir}/DS_history_contigs_250.fasta"
noPara="${PARA_dir}/DS_history.rand20.same.29.loci"
noHybs="${PCA_dir}/Refined_Individuals.list"
yearList="${para_dir}/year.list"

cd ${out_dir}



# refer to the refined top 100 bamlist you generated in estimating long term theta

infile="${yearList}"
echo ${infile}

# call genotypes using SFS as prior for each year

n=$(wc -l ${infile} | awk '{print $1}')
x=1
while [ $x -le $n ]
do
	year=$(sed -n ${x}p ${infile})
	bamlist="${theta_dir}/Ht_${year}.ReadCount.Sorted.best100.bamlist"

### Unzip all files ###
        gunzip Ht_${year}_callGeno.geno.gz

### transform genotype file into genepop format ###
        geno_to_genepop.py Ht_${year}_callGeno.geno ### tmp output is a file ending with "genepoptemp" ###

### add individual IDs to genepop file ###
        cut -d'/' -f6 ${theta_dir}/Ht_${year}.ReadCount.Sorted.best100.bamlist | cut -d'_' -f1-2 | sed 1iID > ${pop}_id
        paste ${pop}_id Ht_${year}_callGeno.genepoptemp > Ht_${year}_callGeno.genepop

### clean up ###
        rm ${pop}_id
        rm Ht_${year}_callGeno.genepoptemp

		echo "#!/bin/bash" > Ht_${year}.callGeno.sh
		echo "#SBATCH -e Ht_${year}_callGeno.err" >> Ht_${year}.callGeno.sh
		echo "#SBATCH -o Ht_${year}_callGeno.out" >> Ht_${year}.callGeno.sh
		echo "#SBATCH -J ${year}CalG" >> Ht_${year}.callGeno.sh
		echo "#SBATCH -t 2880" >> Ht_${year}.callGeno.sh
		echo "#SBATCH --mem=60G" >> Ht_${year}.callGeno.sh
		echo "set -e" >> Ht_${year}.callGeno.sh
		echo "set -v" >> Ht_${year}.callGeno.sh
		echo "" >> Ht_${year}.callGeno.sh
		echo "module load bio" >> Ht_${year}.callGeno.sh
		echo "angsd --version" >> Ht_${year}.callGeno.sh
		echo "nInd=\$(wc -l ${bamlist} | awk '{print \$1}')" >> Ht_${year}.callGeno.sh
		echo "mInd=\$((\${nInd}/2))" >> Ht_${year}.callGeno.sh
		echo "echo Calling Genotypes" >> Ht_${year}.callGeno.sh
		echo "angsd -out ${out_dir}/Ht_${year}_callGeno \
-GL 1 \
-doGeno 2 \
-doPost 3 \
-doMaf 2 \
-doMajorMinor 1 \
-bam ${bamlist} \
-minInd ${mInd} \
-rf ${noPara} \
-minMapQ 20 \
-minQ 20 \
-pest ${theta_dir}/SFS/Ht_${year}.sfs \
-SNP_pval 1e-6" >> Ht_${year}.callGeno.sh   

#submit jobs
# divide onto differnt partitions with comparison operators
if [[ ${year} -lt 2000 ]]
        then
        sbatch -p bigmemh Ht_${year}.callGeno.sh
        elif [[ ${year} -ge 2000 && ${year} -le 2008 ]]
                then
                sbatch -p bigmemm Ht_${year}.callGeno.sh
                elif [[ ${year} -gt 2008 ]]
                        then
                        sbatch -p high Ht_${year}.callGeno.sh
                        else
                                echo ${year} "Not a valid year!"
fi
        x=$(( $x + 1 ))
done

# README
echo "This directory contains called genotypes using SFS as a prior for each year. Analysis was restricted to 100 individuals max for each year a list of these individuals can be found in the ${theta_dir}/Ht_XXXX.ReadCount.Sorted.best100.bamlist files." >> README
echo "Filters include no paralogs and excluding potentially hybridized or misclassified individuals." >> README
echo "The SFS are contained in ${theta_dir}/SFS/Ht_XXXX.sfs files" >> README

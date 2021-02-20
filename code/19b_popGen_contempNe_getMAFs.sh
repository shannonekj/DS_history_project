#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J getMAFs
#SBATCH -e 19b_popGen_contempNe_getMAFs.%j.err
#SBATCH -o 19b_popGen_contempNe_getMAFs.%j.out
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=MaxMemPerNode

set -e
set -x

# NOTES
# This script will get the minor allele frequencies for all SNPs for each year. 
# Use it to pull the SNPs that are common for all years to call genotypes on. 


# set up directories
pop="DS_history"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
PCA_dir="${data_dir}/RAD_PCA"
PARA_dir="${para_dir}/results_paralogs"
theta_dir="${data_dir}/popgen_theta"
out_dir="${data_dir}/popgen_getMAFs"

ref="${para_dir}/DS_history_contigs_250.fasta"
noPara="${PARA_dir}/DS_history.rand20.same.29.loci"
noHybs="${PCA_dir}/Refined_Individuals.list"
yearList="${para_dir}/year.list"

mkdir -p ${out_dir}
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

		echo "#!/bin/bash" > Ht_${year}.getMAFs.sh
		echo "#SBATCH -e Ht_${year}_getMAFs.err" >> Ht_${year}.getMAFs.sh
		echo "#SBATCH -o Ht_${year}_getMAFs.out" >> Ht_${year}.getMAFs.sh
		echo "#SBATCH -J ${year}_maf" >> Ht_${year}.getMAFs.sh
		echo "#SBATCH -t 2880" >> Ht_${year}.getMAFs.sh
		echo "#SBATCH --mem=60G" >> Ht_${year}.getMAFs.sh
		echo "set -e" >> Ht_${year}.getMAFs.sh
		echo "set -v" >> Ht_${year}.getMAFs.sh
		echo "" >> Ht_${year}.getMAFs.sh
		echo "module load bio" >> Ht_${year}.getMAFs.sh
		echo "angsd --version" >> Ht_${year}.getMAFs.sh
		echo "nInd=\$(wc -l ${bamlist} | awk '{print \$1}')" >> Ht_${year}.getMAFs.sh
		echo "mInd=\$((\${nInd}/2))" >> Ht_${year}.getMAFs.sh
		echo "echo getting allele frrequencies \$(date)" >> Ht_${year}.getMAFs.sh
		echo "angsd -out ${out_dir}/Ht_${year}_getMAF \
-GL 1 \
-doPost 1 \
-doMaf 2 \
-doMajorMinor 1 \
-bam ${bamlist} \
-minInd \${mInd} \
-rf ${noPara} \
-minMapQ 20 \
-minQ 20 \
-minMaf 0.05 \
-SNP_pval 1e-6" >> Ht_${year}.getMAFs.sh   

#submit jobs
# divide onto differnt partitions with comparison operators
if [[ ${year} -lt 2000 ]]
        then
        sbatch -p bigmemh Ht_${year}.getMAFs.sh
        elif [[ ${year} -ge 2000 && ${year} -le 2008 ]]
                then
                sbatch -p bigmemm Ht_${year}.getMAFs.sh
                elif [[ ${year} -gt 2008 ]]
                        then
                        sbatch -p high Ht_${year}.getMAFs.sh
                        else
                                echo ${year} "Not a valid year!"
fi
        x=$(( $x + 1 ))
done

# README
echo "This directory contains allele frequencies for each year."  >> README
echo ""  >> README
echo "Analysis was restricted to 100 individuals max for each year. Lists of these individuals can be found in ${theta_dir}/Ht_XXXX.ReadCount.Sorted.best100.bamlist files." >> README
echo ""  >> README
echo "Pre-filters include no paralogs (taken from the ${noPara} file and excluding potentially hybridized or misclassified individuals taken from the ${noHybs} file." >> README
echo ""  >> README
echo "These SNPs should be sorted and compared to see which SNPs are common across all years. Call genotypes on those SNPs and then input into NeEstimator." >> README


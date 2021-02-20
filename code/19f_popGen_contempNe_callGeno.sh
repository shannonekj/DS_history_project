#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J callGeno
#SBATCH -e 19f_popGen_contempNe_callGeno.%j.err
#SBATCH -o 19f_popGen_contempNe_callGeno.%j.out
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=MaxMemPerNode

set -e
set -x

# NOTES
# This script will call genotypes using SFS as a prior for each year.
# It is restricting analysis to:
#	100 individuals max for each year.
#	no paralogs
#	exclude potentially hybridized or misclassified individuals
#	SNPs common to all the years in the analysis. (The sites file incorporates the -rf noPara contigs into finding loci, so noPara does not need to be used in this ANGSD cmd. 
# Use this output to estimate contemporary Ne in LDNe and NeEstimator.

# set up directories
pop="DS_history"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
PCA_dir="${data_dir}/RAD_PCA"
PARA_dir="${para_dir}/results_paralogs"
theta_dir="${data_dir}/popgen_theta"
MAF_dir="${data_dir}/popgen_getMAFs"
SNP_dir="${data_dir}/popgen_getSNPs"
out_dir="${data_dir}/popgen_calledGenotypes"

ref="${para_dir}/DS_history_contigs_250.fasta"
noPara="${PARA_dir}/DS_history.rand20.same.29.loci"
noHybs="${PCA_dir}/Refined_Individuals.list"
yearList="${para_dir}/year.list"
sites="${MAF_dir}/DS_history_lociForNe.nInd20.noNA.txt"
snps="${SNP_dir}/DS_history_lociForNe.nInd20.noNA.fromCalledGenos.txt"

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
		echo "echo Calling Genotypes \$(date)" >> Ht_${year}.callGeno.sh
		echo "angsd -out ${out_dir}/Ht_${year}_callGeno \
-GL 1 \
-doGeno 3 \
-doPost 1 \
-doMaf 2 \
-doMajorMinor 1 \
-bam ${bamlist} \
-minInd \${mInd} \
-rf ${snps} \
-minMapQ 20 \
-minQ 20 \
-minMaf 0.05 \
-postCutoff 0.85 \
-pest ${theta_dir}/SFS/Ht_${year}.sfs \
-SNP_pval 1e-6" >> Ht_${year}.callGeno.sh   
	# format for NeEstimator
		echo "echo Unzipping geno files \$(date)" >> Ht_${year}.callGeno.sh
		echo "gunzip Ht_${year}_callGeno.geno.gz" >> Ht_${year}.callGeno.sh
		echo "echo converting geno to genepop format \$(date)" >> Ht_${year}.callGeno.sh
		echo "geno_to_genepop.py Ht_${year}_callGeno.geno" >> Ht_${year}.callGeno.sh
		echo "echo adding individual IDs to genepop file \$(date)" >> Ht_${year}.callGeno.sh
		echo "cut -d'/' -f8 Ht_${year}.ReadCount.Sorted.best100.bamlist | cut -d'_' -f1-2 | sed 1iID > ${year}_id" >> Ht_${year}.callGeno.sh
		echo "paste ${year}_id Ht_${year}_callGeno.genepoptemp > Ht_${year}_callGeno.genepop" >> Ht_${year}.callGeno.sh
		echo "echo cleaning up directory \$(date)" >> Ht_${year}.callGeno.sh
		echo "rm ${year}_id Ht_${year}_callGeno.genepoptemp" >> Ht_${year}.callGeno.sh
		echo "echo saving room and re-zipping geno files \$(date)" >> Ht_${year}.callGeno.sh
		echo "gzip Ht_${year}_callGeno.geno" >> Ht_${year}.callGeno.sh
		echo "echo Completed on \$(date)" >> Ht_${year}.callGeno.sh

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
echo "This directory contains called genotypes using SFS as a prior for each year."  >> README
echo ""  >> README
echo "Analysis was restricted to 100 individuals max for each year. Lists of these individuals can be found in ${theta_dir}/Ht_XXXX.ReadCount.Sorted.best100.bamlist files." >> README
echo ""  >> README
echo "Pre-filters include no paralogs (taken from the ${noPara} file and excluding potentially hybridized or misclassified individuals taken from the ${noHybs} file. Additionally, sites were selected that were common to all years see ${sites} file (there are $(wc -l ${sites}) sites total)." >> README
echo ""  >> README
echo "The SFS are contained in ${theta_dir}/SFS/Ht_XXXX.sfs files." >> README
echo "Use this output to estimate contemporary Ne in LDNe and NeEstimator." >> README

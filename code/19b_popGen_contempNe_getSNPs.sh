#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J getSNPs
#SBATCH -e 19d_popGen_contempNe_getSNPs.%j.err
#SBATCH -o 19d_popGen_contempNe_getSNPs.%j.out
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=MaxMemPerNode

set -e
set -x

# NOTES
# This script will call genotypes using SFS as a prior for each year and will use this information to find the SNPs that are common to all years passing quality filtration.
# It is restricting analysis to 100 individuals max for each year.
# Filters include no paralogs, excluding potentially hybridized or misclassified individuals and only using sites common to all the years in the analysis. 
# Use this output to estimate contemporary Ne in LDNe and NeEstimator.

# set up directories
pop="DS_history"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
PCA_dir="${data_dir}/RAD_PCA"
PARA_dir="${para_dir}/results_paralogs"
theta_dir="${data_dir}/popgen_theta"
out_dir="${data_dir}/popgen_getSNPs"

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

		echo "#!/bin/bash" > Ht_${year}.getSNPs.sh
		echo "#SBATCH -e Ht_${year}_getSNPs.err" >> Ht_${year}.getSNPs.sh
		echo "#SBATCH -o Ht_${year}_getSNPs.out" >> Ht_${year}.getSNPs.sh
		echo "#SBATCH -J ${year}CalG" >> Ht_${year}.getSNPs.sh
		echo "#SBATCH -t 2880" >> Ht_${year}.getSNPs.sh
		echo "#SBATCH --mem=60G" >> Ht_${year}.getSNPs.sh
		echo "set -e" >> Ht_${year}.getSNPs.sh
		echo "set -v" >> Ht_${year}.getSNPs.sh
		echo "" >> Ht_${year}.getSNPs.sh
		echo "module load bio" >> Ht_${year}.getSNPs.sh
		echo "angsd --version" >> Ht_${year}.getSNPs.sh
		echo "nInd=\$(wc -l ${bamlist} | awk '{print \$1}')" >> Ht_${year}.getSNPs.sh
		echo "mInd=\$((\${nInd}/2))" >> Ht_${year}.getSNPs.sh
		echo "echo Calling Genotypes \$(date)" >> Ht_${year}.getSNPs.sh
		echo "angsd -out ${out_dir}/Ht_${year}_getSNPs \
-GL 1 \
-doGeno 3 \
-doPost 1 \
-doMaf 2 \
-doMajorMinor 1 \
-bam ${bamlist} \
-minInd \${mInd} \
-rf ${noPara} \
-minMapQ 20 \
-minQ 20 \
-minMaf 0.05 \
-postCutoff 0.85 \
-pest ${theta_dir}/SFS/Ht_${year}.sfs \
-SNP_pval 1e-6" >> Ht_${year}.getSNPs.sh   

		echo "echo Completed on \$(date)" >> Ht_${year}.getSNPs.sh

#submit jobs
# divide onto differnt partitions with comparison operators
if [[ ${year} -lt 2000 ]]
        then
        sbatch -p bigmemh Ht_${year}.getSNPs.sh
        elif [[ ${year} -ge 2000 && ${year} -le 2008 ]]
                then
                sbatch -p bigmemm Ht_${year}.getSNPs.sh
                elif [[ ${year} -gt 2008 ]]
                        then
                        sbatch -p high Ht_${year}.getSNPs.sh
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
echo "Use this output to find the SNPs contained in all years to call genotypes on and input to estimation Ne." >> README

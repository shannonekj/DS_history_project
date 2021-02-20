#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J alleleCounts
#SBATCH -e 19d_popGen_contempNe_rand30_alleleCounts.%j.err
#SBATCH -o 19d_popGen_contempNe_rand30_alleleCounts.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES:
# Count alleles from genotypes found in getSNPs


# set up directories
pop="DS_history"
cutoff="30"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
theta_dir="${data_dir}/popgen_theta"
MAF_dir="${data_dir}/popgen_getMAFs"
SNP_dir="${data_dir}/popgen_getSNPs"
c30_dir="${data_dir}/popgen_calledGenotypes${cutoff}"
out_dir="${data_dir}/ANGSD_alleleCount${cutoff}"

yearList="${para_dir}/year.list"
sites="${SNP_dir}/DS_history_lociForNe.nInd20.noNA.fromCalledGenos.txt"

module load bio
angsd -version
mkdir -p ${out_dir}
cd ${out_dir}


#####################################
###   make bamlist for each year  ###
###   call genotypes for 30 ind   ###
###    convert geno to genepop    ###
#####################################
# Note we are no longer using years 1993, 2000, 2007 due to having too few loci from too few individuals (n=9, 6, 1, respectively)
# Refer to the refined top 100 bamlist you generated in estimating long term theta to grab individuals for 
# refer to the random 30 sampled individuals from calling genotypes for the bamlist to use for each year.

# filter year list
cp ${yearList} year.no1993.no2000.no2007.list
sed -i '/1993/d' year.no1993.no2000.no2007.list
sed -i '/2000/d' year.no1993.no2000.no2007.list
sed -i '/2007/d' year.no1993.no2000.no2007.list

infile="year.no1993.no2000.no2007.list"
echo ${infile}
n=$(wc -l ${infile} | awk '{print $1}')
x=1
while [ $x -le $n ]
do
        year=$(sed -n ${x}p ${infile})
	bamlist="${c30_dir}/Ht_${year}.rand30.bamlist"
# allele counts on the 30 individuals
                echo "#!/bin/bash" > Ht_${year}.alleleCount.sh
                echo "#SBATCH -e Ht_${year}_alleleCount.err" >> Ht_${year}.alleleCount.sh
                echo "#SBATCH -o Ht_${year}_alleleCount.out" >> Ht_${year}.alleleCount.sh
                echo "#SBATCH -J ${year}aCnt" >> Ht_${year}.alleleCount.sh
                echo "#SBATCH -t 2880" >> Ht_${year}.alleleCount.sh
                echo "#SBATCH --mem=60G" >> Ht_${year}.alleleCount.sh
                echo "set -e" >> Ht_${year}.alleleCount.sh
                echo "set -v" >> Ht_${year}.alleleCount.sh
                echo "" >> Ht_${year}.alleleCount.sh
                echo "module load bio" >> Ht_${year}.alleleCount.sh
                echo "angsd --version" >> Ht_${year}.alleleCount.sh
                echo "nInd=\$(wc -l ${bamlist} | awk '{print \$1}')" >> Ht_${year}.alleleCount.sh
                echo "mInd=\$((\${nInd}/2))" >> Ht_${year}.alleleCount.sh
                echo "echo counting alleles \$(date)" >> Ht_${year}.alleleCount.sh
                echo "angsd -out ${out_dir}/Ht_${year}_alleleCount \
-doCounts 1 \
-dumpCounts 3 \
-bam ${bamlist} \
-rf ${sites} \
-minMapQ 20 \
-minQ 20 " >> Ht_${year}.alleleCount.sh

#submit jobs
# divide onto differnt partitions with comparison operators
if [[ ${year} -lt 2000 ]]
        then
        sbatch -p bigmemh Ht_${year}.alleleCount.sh
        elif [[ ${year} -ge 2000 && ${year} -le 2010 ]]
                then
                sbatch -p bigmemm Ht_${year}.alleleCount.sh
                elif [[ ${year} -gt 2010 ]]
                        then
                        sbatch -p high Ht_${year}.alleleCount.sh
                        else
                                echo ${year} "Not a valid year!"
fi
        x=$(( $x + 1 ))
done


        echo "This directory contains allele counts from shared sites retrived in getSNPs step." >> README
        echo "" >> README
        echo "Next input into NB package in R with the following format" >> README
        echo "NN NN NN NN" >> README
        echo "NN NN NN NN #this is temporal sample 1 allelic counts at each loci" >> README
        echo "" >> README
        echo "NN NN NN NN" >> README
        echo "NN NN NN NN #this is temporal sample 2 allelic counts at each loci" >> README
	echo "Note: The same random 30 samples were use for counting alleles as were used in calling genotypes in" >> README
	echo "${c30_dir}" >> README





#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J formatNeEst
#SBATCH -e 19e_popGen_contempNe_callGeno.%j.err
#SBATCH -o 19e_popGen_contempNe_callGeno.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines

# NOTES:
# First, select a random 30 individuals for each year.
# Second, input those 30 individuals into bamlist
# Third, call genotypes on the 30 individual from the loci you retrived in the getSNPs step.
# Fourth, convert all geno files to genepop using NeEstimator.



# set up directories
pop="DS_history"
cutoff="30"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
PCA_dir="${data_dir}/RAD_PCA"
PARA_dir="${para_dir}/results_paralogs"
theta_dir="${data_dir}/popgen_theta"
MAF_dir="${data_dir}/popgen_getMAFs"
SNP_dir="${data_dir}/popgen_getSNPs"
out_dir="${data_dir}/popgen_calledGenotypes${cutoff}"

ref="${para_dir}/DS_history_contigs_250.fasta"
noPara="${PARA_dir}/DS_history.rand20.same.29.loci"
noHybs="${PCA_dir}/Refined_Individuals.list"
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
	bamlist="Ht_${year}.rand30.bamlist"
	shuf -n ${cutoff} ${theta_dir}/Ht_${year}.ReadCount.Sorted.best100.bamlist > ${bamlist}
# call genotypes on the 30 individuals
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
-doGeno 2 \
-doPost 1 \
-doMaf 2 \
-doMajorMinor 1 \
-bam ${bamlist} \
-minInd \${mInd} \
-rf ${sites} \
-minMapQ 20 \
-minQ 20 \
-postCutoff 0.85 \
-minMaf 0.05 \
-pest ${theta_dir}/SFS/Ht_${year}.sfs \
-SNP_pval 1e-6" >> Ht_${year}.callGeno.sh
		echo "echo Completed calling genotypes \$(date)" >> Ht_${year}.callGeno.sh
		echo "echo Unzipping Ht_${year}_callGeno.geno" >> Ht_${year}.callGeno.sh
		echo "gunzip Ht_${year}_callGeno.geno.gz" >> Ht_${year}.callGeno.sh

#submit jobs
# divide onto differnt partitions with comparison operators
if [[ ${year} -lt 2000 ]]
        then
        sbatch -p bigmemh Ht_${year}.callGeno.sh
        elif [[ ${year} -ge 2000 && ${year} -le 2010 ]]
                then
                sbatch -p bigmemm Ht_${year}.callGeno.sh
                elif [[ ${year} -gt 2010 ]]
                        then
                        sbatch -p high Ht_${year}.callGeno.sh
                        else
                                echo ${year} "Not a valid year!"
fi
        x=$(( $x + 1 ))
done



# after this find common loci and copy those lines into a unique file for each year to convert to genepop.





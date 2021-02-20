#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J getDepths
#SBATCH -e 19c_getDepths_rand30.%j.err
#SBATCH -o 19c_getDepths_rand30.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e

# SCRIPT to get depths for all sites meeting the following criterion:
#	minInd 		= 0.5
#	minQ		= 20
#	minMapQ		= 20
#	postCutoff	= 0.85
#	minMaf		= 0.05
#	SNP_pval	= 1e-6

# set up directories
pop="DS_history"
cutoff="30"
data_dir="/home/sejoslin/projects/${pop}/data"
para_dir="${data_dir}/paralog_id"
PCA_dir="${data_dir}/RAD_PCA"
PARA_dir="${para_dir}/results_paralogs"
theta_dir="${data_dir}/popgen_theta"
geno_dir="${data_dir}/ANGSD_calledGenotypes${cutoff}"
out_dir="${data_dir}/ANGSD_depths${cutoff}"

ref="${para_dir}/DS_history_contigs_250.fasta"
noPara="${PARA_dir}/DS_history.rand20.same.29.loci"
noHybs="${PCA_dir}/Refined_Individuals.list"
yearList="${para_dir}/year.list"

mkdir -p ${out_dir}
cd ${out_dir}

# get depths for each year

infile="${geno_dir}/year.no1993.no2000.no2007.list"
echo Using ${infile} for count read depths for each individual at each site.
n=$(wc -l ${infile} | awk '{print $1}')
x=1
while [ $x -le $n ]
do
        year=$(sed -n ${x}p ${infile})
        bamlist="${geno_dir}/Ht_${year}.rand30.bamlist"
	echo Creating script for ${year} using ${bamlist}	
	# get depths
                echo "#!/bin/bash" > Ht_${year}_getDepth.sh
                echo "#SBATCH -e Ht_${year}_getDepth.err" >> Ht_${year}_getDepth.sh
                echo "#SBATCH -o Ht_${year}_getDepth.out" >> Ht_${year}_getDepth.sh
                echo "#SBATCH -J ${year}CalG" >> Ht_${year}_getDepth.sh
                echo "#SBATCH -t 2880" >> Ht_${year}_getDepth.sh
                echo "#SBATCH --mem=60G" >> Ht_${year}_getDepth.sh
                echo "set -e" >> Ht_${year}_getDepth.sh
                echo "set -v" >> Ht_${year}_getDepth.sh
                echo "" >> Ht_${year}_getDepth.sh
                echo "module load bio" >> Ht_${year}_getDepth.sh
                echo "angsd --version" >> Ht_${year}_getDepth.sh
                echo "nInd=\$(wc -l ${bamlist} | awk '{print \$1}')" >> Ht_${year}_getDepth.sh
                echo "mInd=\$((\${nInd}/2))" >> Ht_${year}_getDepth.sh
                echo "echo Acquiring depths \$(date)" >> Ht_${year}_getDepth.sh
                echo "angsd -out ${out_dir}/Ht_${year}_getDepth \
-doCounts 1 \
-doDepth 1 \
-bam ${bamlist} \
-rf ${noPara} " >> Ht_${year}_getDepth.sh

#submit jobs
# divide onto different partitions with comparison operators
if [[ ${year} -lt 2000 ]]
        then
        sbatch -p bigmemh Ht_${year}_getDepth.sh
        elif [[ ${year} -ge 2000 && ${year} -le 2010 ]]
                then
                sbatch -p bigmemm Ht_${year}_getDepth.sh
                elif [[ ${year} -gt 2010 ]]
                        then
                        sbatch -p high Ht_${year}_getDepth.sh
                        else
                                echo ${year} "Not a valid year!"
fi
        x=$(( $x + 1 ))
done







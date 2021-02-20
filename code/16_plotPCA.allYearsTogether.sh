#!/bin/bash
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J plotPCA
#SBATCH -e 16_plotPCA.allYearsTogether.%j.err
#SBATCH -o 16_plotPCA.allYearsTogether.%j.out
#SBATCH -c 20
#SBATCH --time=20:00:00
#SBATCH --mem=32G
#SBATCH -p high

source ~sejoslin/.bash_profile
set -e # exits upon failing command
set -v # verbose -- all lines

# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data"
loci_dir="/home/sejoslin/projects/${pop}/data/id_loci/PRICE"
RAD_dir="${data_dir}/RAD_alignments"
PCA_dir="${data_dir}/filter_PCA"

cd ${PCA_dir}

# make annotated file from bamlist (clst format)
echo "FID_IID_CLUSTER_IDVAR" | awk -F_ '{print $1"\t"$2"\t"$3"\t"$4}' > ${pop}.clst
	# $1 = Ht??
        # $2 = ind #
        # $3 = year
        # $4 = well
cat ${pop}.bamlist | sed 's:.*alignments/::g' | sed 's:.sort.proper.rmdup.bam::g' | sed 's:\-:_:g' | awk -F_ '{print $1"_"$4"\t1\t"$3"\t"$1}' >> ${pop}.clst

#### Plot results
# already copied plotPCA.R

       plotPCA.R -i ${pop}.covar2 -c 1-2 -a ${pop}.clst -o ${pop}_pca_no_call.pdf
       plotPCA.R -i ${pop}.covar3 -c 1-2 -a ${pop}.clst -o ${pop}_pca_call.pdf

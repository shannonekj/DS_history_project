#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J pcaPLOT
#SBATCH -e IEP_PCA_plot.grey.%j.err
#SBATCH -o IEP_PCA_plot.grey.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines

# run script with
#       sbatch IEP_PCA_plot.grey.sh

# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data/"
RAD_dir="/home/sejoslin/projects/${pop}/data/RAD_alignments"
RAD_sub_dir="/home/sejoslin/projects/${pop}/data/RAD_subsample"
PCA_dir="/home/sejoslin/projects/${pop}/data/IEP_pca"

# Make sure to edit the ${code_dir}/scripts/pca_plot.R before running this (so you will obtain the a customized plot)

#######################
###  plot PCA list  ###
#######################
cd ${data_dir}
mkdir -p plots

ls RAD_pca/*bamlist | sed 's:RAD_pca/::g' | sed 's:.bamlist::g' > list

wc=$(wc -l list | awk '{print $1}')
x=1
while [ $x -le $wc ]
do

        string="sed -n ${x}p list"
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1}')
        set -- ${var}
        c1=$1
        spp=${c1:0:2}
        echo -e "${c1} \t ${spp}"

        # make annotated file from bamlist (clst format)
        echo "FID_IID_CLUSTER_IDVAR" | awk -F_ '{print $1"\t"$2"\t"$3"\t"$4}' > RAD_pca/${c1}.clst
	# $1 = Ht??
	# $2 = ind #
	# $3 = year
	# $4 = well
        cat RAD_pca/${c1}.bamlist | sed 's:.*subsample/::g' | sed 's:ss....bam::g' | sed 's:\-:_:g' | awk -F_ '{print $1"_"$4"\t1\t"$3"\t"$1}' >> RAD_pca/${c1}.clst

        ## plot pdfs
        Rscript --vanilla --slave ${code_dir}/scripts/plot_pca.R -i RAD_pca/${c1}.covar -s ${spp} -c 1-2 -a RAD_pca/${c1}.clst -o plots/${c1}_pca.year.pdf

x=$(( $x + 1 ))
done
rm list

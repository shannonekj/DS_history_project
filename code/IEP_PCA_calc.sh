#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J pcaIEP
#SBATCH -e IEP_PCA_calc.%j.err
#SBATCH -o IEP_PCA_calc.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00
#SBATCH --mem=32G

set -e # exits upon failing command
set -v # verbose -- all lines

# run script with
#       sbatch IEP_PCA_calc.sh

# set up directories
pop="DS_history"
code_dir="/home/sejoslin/projects/${pop}/code"
data_dir="/home/sejoslin/projects/${pop}/data/"
RAD_dir="/home/sejoslin/projects/${pop}/data/RAD_samples"
RAD_sub_dir="/home/sejoslin/projects/${pop}/data/RAD_subsample"
PCA_dir="/home/sejoslin/projects/${pop}/data/IEP_pca"
TempNe_dir="/home/sejoslin/projects/${pop}/data/TempNe_estimation_2014.2013.2012.2011/"

#########################
###  create PCA list  ###
###   for PCA plots   ###
#########################

mkdir ${PCA_dir}
cd ${PCA_dir}

# first pull a list of all bam files 
ls ${RAD_sub_dir}/*_ss300.bam > ${pop}_ss300.bamlist
ls ${RAD_dir}/*_qf300.bam > ${pop}_qf300.bamlist
cat ${TempNe_dir}/*.bamlist > ${pop}_2011.2012.2013.2014.bamlist
cp ${TempNe_dir}/Ht_2013.bamlist ${pop}_2013.bamlist
ls *.bamlist | sed 's:.bamlist::g' > pcalist

# then call genotypes and get covariance file for each PCA set
wc=$(wc -l pcalist | awk '{print $1}')
x=1
while [ $x -le $wc ]
do

        string="sed -n ${x}p pcalist"
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1}')
        set -- $var
        c1=$1

        nInd=$(wc -l ${c1}.bamlist | awk '{print $1}')
        minInd=$[$nInd/2]

        echo "#!/bin/bash -l" > ${PCA_dir}/${c1}.sh
	echo "#SBATCH -e ${c1}-%j.err" >> ${PCA_dir}/${c1}.sh
        echo "#SBATCH -o ${c1}-%j.out" >> ${PCA_dir}/${c1}.sh
        echo "#SBATCH --mail-user=sejoslin@ucdavis.edu"  >> ${PCA_dir}/${c1}.sh
	echo "#SBATCH --mail-type=ALL" >> ${PCA_dir}/${c1}.sh
	echo "#SBATCH --mem=128G" >> ${PCA_dir}/${c1}.sh
	echo "#SBATCH --time=4-20:00:00" >> ${PCA_dir}/${c1}.sh
	echo "#SBATCH -p bigmemh" >> ${PCA_dir}/${c1}.sh
	echo "cd ${PCA_dir}" >> ${PCA_dir}/${c1}.sh
	echo "module load angsd" >> ${PCA_dir}/${c1}.sh
	# call genotypes with ANGSD
	echo "angsd -bam ${PCA_dir}/${c1}.bamlist -out ${PCA_dir}/${c1} -minQ 20 -minMapQ 10 -minInd $minInd -GL 1 -doMajorMinor 1 -doMaf 2 -SNP_pval 1e-6 -minMaf 0.05 -doGeno 32 -doPost 2" >> ${PCA_dir}/${c1}.sh
        echo "gunzip ${PCA_dir}/${c1}*.gz" >> ${PCA_dir}/${c1}.sh
        echo "count=\$(sed 1d ${PCA_dir}/${c1}*mafs| wc -l | awk '{print \$1}')" >> ${PCA_dir}/${c1}.sh
        # create covar file with ngsCovar
	echo "ngsCovar -probfile ${PCA_dir}/${c1}.geno -outfile ${PCA_dir}/${c1}.covar -nind $nInd -nsites \$count -call 1" >> ${PCA_dir}/${c1}.sh
        sbatch -J sekjpca ${PCA_dir}/${c1}.sh
        #rm ${c1}.sh

 x=$(( $x + 1 ))
done


# you should now have covar files for each PCA plot (use ${pop}/code/plotPCA.R to plot all scripts

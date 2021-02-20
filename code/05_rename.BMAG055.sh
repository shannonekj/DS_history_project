#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J renam055
#SBATCH -e 05_rename.BMAG055.%j.err
#SBATCH -o 05_rename.BMAG055.%j.out
#SBATCH -c 20
#SBATCH -p med
#SBATCH --time=1-20:00:00

set -e # exits upon failing command
set -v # verbose -- all lines
#set -x # trace of all commands after expansion before execution

# run script with
#       sbatch --mem MaxMemPerNode 05_rename_ALL.sh

# set up directories
code_dir="/home/sejoslin/projects/DS_history/code"
data_dir="/home/sejoslin/projects/DS_history/data"
meta_dir="${data_dir}/metadata"

cd ${data_dir}

###############
### BMAG043 ###
###############
dir="BMAG055"

#1#
index="CCGTCC"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.metadata" # <-this is the metadata file
wc=$(wc -l ${input} | awk '{print $1}')
x=1
while [ $x -le $wc ] 
do
        string="sed -n ${x}p ${input}"
        str=$($string)
        var=$(echo ${str} | awk -F"\t" '{print $1,$2,$3,$4}')
        set -- $var
        c1=$1 # run ID
        c2=$2 # well number
        c3=$3 # barcode
        c4=$4 # unique ID
	mv ${c1}_${index}_GG${c3}TGCAGG_R1.fastq ${c4}_R1.fastq
	mv ${c1}_${index}_GG${c3}TGCAGG_R2.fastq ${c4}_R2.fastq
	x=$(( $x + 1 ))
done

#2#
index="GTGAAA"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.metadata" # <-this is the metadata file
wc=$(wc -l ${input} | awk '{print $1}')
x=1
while [ $x -le $wc ]
do
        string="sed -n ${x}p ${input}"
        str=$($string)
        var=$(echo ${str} | awk -F"\t" '{print $1,$2,$3,$4}')
        set -- $var
        c1=$1 # run ID
        c2=$2 # well number
        c3=$3 # barcode
        c4=$4 # unique ID
	mv ${c1}_${index}_GG${c3}TGCAGG_R1.fastq ${c4}_R1.fastq
	mv ${c1}_${index}_GG${c3}TGCAGG_R2.fastq ${c4}_R2.fastq
	x=$(( $x + 1 ))
done

#3#
index="GGCTAC"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.metadata" # <-this is the metadata file
wc=$(wc -l ${input} | awk '{print $1}')
x=1
while [ $x -le $wc ]
do
        string="sed -n ${x}p ${input}"
        str=$($string)
        var=$(echo ${str} | awk -F"\t" '{print $1,$2,$3,$4}')
        set -- $var
        c1=$1 # run ID
        c2=$2 # well number
        c3=$3 # barcode
        c4=$4 # unique ID
        mv ${c1}_${index}_GG${c3}TGCAGG_R1.fastq ${c4}_R1.fastq
        mv ${c1}_${index}_GG${c3}TGCAGG_R2.fastq ${c4}_R2.fastq
        x=$(( $x + 1 ))
done


#4#
index="CTTGTA"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.metadata" # <-this is the metadata file
wc=$(wc -l ${input} | awk '{print $1}')
x=1
while [ $x -le $wc ]
do
        string="sed -n ${x}p ${input}"
        str=$($string)
        var=$(echo ${str} | awk -F"\t" '{print $1,$2,$3,$4}')
        set -- $var
        c1=$1 # run ID
        c2=$2 # well number
        c3=$3 # barcode
        c4=$4 # unique ID
        mv ${c1}_${index}_GG${c3}TGCAGG_R1.fastq ${c4}_R1.fastq
        mv ${c1}_${index}_GG${c3}TGCAGG_R2.fastq ${c4}_R2.fastq
        x=$(( $x + 1 ))
done

#!/bin/bash -l
#SBATCH --mail-user=sejoslin@ucdavis.edu
#SBATCH --mail-type=ALL
#SBATCH -J renameALL
#SBATCH -e 05_rename_ALL.%j.err
#SBATCH -o 05_rename_ALL.%j.out
#SBATCH -c 20
#SBATCH -p high
#SBATCH --time=1-20:00:00

set -e # exits upon failing command
set -v # verbose -- all lines
#set -x # trace of all commands after expansion before execution

# run script with
#       sbatch --mem MaxMemPerNode 05_rename_ALL.sh

# set up directories
code_dir="/home/sejoslin/projects/DS_history/code"
data_dir="/home/sejoslin/projects/DS_history/data"
meta_dir="/home/sejoslin/projects/DS_history/data/metadata"

cd ${data_dir}

###############
### BMAG043 ###
###############
dir="BMAG043"

#1#
index="ATCACG"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="CGATGT"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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

###############
### BMAG044 ###
###############
dir="BMAG044"

#1#
index="ACAGTG"
 
cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="GCCAAT"
 
cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="TGACCA"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="TTAGGC"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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


###############
### BMAG045 ###
###############
dir="BMAG045"


#1#
index="ACTTGA"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="CAGATC"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="GATCAG"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="TAGCTT"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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




###############
### BMAG046 ###
###############
dir="BMAG046"

#1#
index="AGTCAA"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="AGTTCC"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="CTTGTA"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="GGCTAC"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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





###############
### BMAG047 ###
###############
dir="BMAG047"

#1#
index="ATGTCA"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="CCGTCC"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="GTCCGC"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="GTGAAA"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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


###############
### BMAG048 ###
###############
dir="BMAG048"

#1#
index="ACTGAT"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="ATTCCT"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="CGTACG"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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
index="GTGGCC"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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



###############
### BMAG049 ###
###############
dir="BMAG049"

#1#
index="GTTTCG"

cd ${data_dir}/${dir}/${index}
input="${meta_dir}/${dir}_${index}.noNA.metadata" # <-this is the metadata file
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

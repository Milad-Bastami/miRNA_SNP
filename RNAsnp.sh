#!/usr/bin/env bash

# set -e
# set -o pipefail
# set -u 

#
# This scripts runs RNAsnp program on a set of 3'UTR:snp pairs
#
# inputs: 
#        -f | --utrs: a text file containing one 3'UTR seq per line. Should have exact number of lines as -s file.
#        -s | snps: a text file containing one snp per line. e.g. A43G in line 1, represents information of the polymorphism
#             related to UTR seq in line 1 of utrs file. Positions are relative to UTR seq.
#
# output: a text file containing the results of RNAsnp for each pair of 3'UTR:snp. 
#         e.g. line 1 of the output file represents the effect of snp on line 1 of snps 
#         file on 3'UTR sequence in line 1 of the utrs file.

usage() {
    echo -e 'Runs RNAsnp program to compute effect of snps on utr sequences. \n'
    echo -e "usage: $0 [-f|--utrs] [-s|--snps] [-m|--mode"]
    echo "              -f|--utrs: required. A text file containing one 3'UTR seq per line. Should have exact number of lines as -s file."
    echo "              -s|--snps: required. A text file containing one snp per line.e.g. A43G in line 1, represents information of the polymorphism 
         related to UTR seq in line 1 of utrs file. Positions are relative to UTR seq."
    echo "              -m|--mode: optional. Which mode of RNAsnp should be used 1 or 2. Default is mode 1 of RNAsnp"
    exit 1    
}

## default values ##
UTR=''
SNP=''
MODE=1  # default is mode 1


while getopts ':f:s:m:h' opt; do
    case $opt in
      (f)   UTR=$OPTARG;;
      (s)   SNP=$OPTARG;;
      (m)   MODE=$OPTARG;;
      (h)   usage;;
      (:)   # "optional arguments" (missing option-argument handling)
            case $OPTARG in
              (f) echo "Sequence file is required" && exit 1;; # error, according to our syntax
              (s) echo "SNP file is reguired" && exit 1;;
              (m) echo "$0: Warning! You passed no mode. keep using default mode (i.e. 1)" && :;;     # acceptable but keeps using mode 1
            esac;;
    esac
done

shift "$OPTIND"

## check if files exist ##
[[ -e $UTR ]] || { echo "Sequence file ($UTR) doesnot exist! provide a valid seq file." && exit 1; }
[[ -e $SNP ]] || { echo "SNP file ($SNP) doesnot exist! provide a valid snp file." && exit 1; }

## number of sequences should match with snps
[[ `cat $UTR | wc -l` == `cat $SNP | wc -l` ]] || { echo "number of sequences should match that of snps. Check the files" && exit 1; }


num_pairs=$(cat $UTR | wc -l) # number of iterations for RNAsnp program


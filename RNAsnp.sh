#!/usr/bin/env bash

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
    echo -e "usage: bash $0 -f|--utrs  -s|--snps  [-m|--mode"]
    echo "-f|--utrs: required. A text file containing one 3'UTR seq per line. Should have exact number of lines as -s file."
    echo "-s|--snps: required. A text file containing one snp per line.e.g. A43G in line 1, represents information of the polymorphism 
         related to UTR seq in line 1 of utrs file. Positions are relative to UTR seq."
    echo "-m|--mode: optional. Which mode of RNAsnp should be used. Default is mode 1 of RNAsnp"
    exit 1    
}

## read & check options ##

# read options
opts=$(getopt -o f:s:m:: --long --utrs:,--snps:,--mode:: -- "$@")
#  print usage if options are incorrect
[$? -eq 0] || {echo -e 'incorrect options\n' && usage && exit 1}
eval set --  "$opts"


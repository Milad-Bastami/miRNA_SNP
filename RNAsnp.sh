#!/usr/bin/env bash
set -e
set -o pipefail
set -u 

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

## default values
utrs=Unset
snps=unset
mode='1'

## read & check options ##

# read options
opts=$(getopt -n RNAsnp -o f:s:m:h --long --utrs:,--snps:,--mode::,--help -- "$@")

#  print usage if options are incorrect
valid_options=$?

[ $valid_options -eq 0 -o $# -eq 0 ] || { 
    echo -e 'incorrect options \n'
    usage 
}

# # check number of passed options
# [[ ( $# != "-h" ) || () ]] && { echo "at least two arguments (i.e. -f and -s) should be passed" }

# set script positional parameters
eval set --  "$opts"

## assigning options to variables ##
while getopts ":f:s:m:h" opt; do
   case ${opt}} in
        f) utrs=$2; shift 2
            ;;
        s) snps=$2; shift 2
            ;;
        m) mode=$2; shift 2
            ;;
        h) usage
            ;;     
        \?) echo "Invalid option: $OPTARG"
            ;;    
        * ) echo -e "Unexpected option: $1 \n"; usage ;;    
   esac
done

echo "utrs is ${utrs}"
echo "snps is ${snps}"
echo "mode is ${mode}"
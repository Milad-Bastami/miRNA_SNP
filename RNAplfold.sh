#!/usr/bin/env bash

: '
This script computes the sum of accessibility values for
nucleotides within the interval of 3UTR miRNA binding site 
(intervals are inclusive).
The process is repeated for sequences with either 
wildtype or mutant allele
'

usage(){
    echo "usage: $0 [-w wfile] [-m mfile] [-i intfile] [-h]"
    echo "           -w: specify a file containing one wildetype seq/line"
    echo "           -m: specify a file containing corresponding mutant seqs"
    echo "           -i: specify a file containing intervals of target sites"
    echo "           -h: show this message"
    exit 1
}

## variables (inputs) ##

: '
the file containing 3UTR sequences
with wild type allele (one seq per line)
'
WILD='' 

: '
the file containing 3UTR sequences
with mutant allele (one seq per line)
'
MUT='' 


: '
The interval file (seqname \t start \t end) 
contains position of a target site within 
each sequence
'
INT=''

## Parsing the options ##

while getopts ':w:m:i:h' opt; do
    case $opt in
        (w) WILD=$OPTARG;;
        (m) MUT=$OPTARG;;
        (i) INT=$OPTARG;;
        (h) usage;;
        (:) case $OPTARG in
                (w) echo "Please specify a file containing wildtype sequences" && exit 1;;
                (m) echo "Please specify a file containing mutant sequences" && exit 1;;
                (i) echo "Please specify a file containing intervals" && exit 1;;
            esac;;
    esac
done

## check if files passed to script exist
[[ -e $WILD ]] || { echo "Wildtype sequence file (${WILD}) doesnot exist" && exit 1;  }
[[ -e $MUT ]] || { echo "Mutant sequence file (${MUT}) doesnot exist" && exit 1;  }
[[ -e $INT ]] || { echo "interval file (${INT}) doesnot exist" && exit 1;  }

## check files compatibility
[[ $(cat "$WILD" | wc -l) -eq $(cat "$MUT" | wc -l) ]] || { echo "equal number of wildtype & mutant sequences is expected" && exit 1; }
[[ $(cat "$WILD" | wc -l) -eq $(cat "$INT" | wc -l) ]] || { echo "interval file should contain a row for each wildtype/mutant sequence" && exit 1; }

## number of iterations is equal for wildtype and mutant sequences ##
num_seqs=$(cat $WILD | wc -l)

## creating output files ##
# going to store: seq number, interval
# start & end, sum of accessibility
touch wildetype.txt
touch mutant.txt

## looping through sequences, running RNAplfold and computing sum accessibility within interval##
for x in $(seq 1 1 $num_seqs); do
    # select the interval region for this sequence
    awk -v lineNum=$x '{if (NR == lineNum) {start=$2; end=$3}}' "$INT" 

    awk -v lineNum=$x '{if (NR == lineNum) {print $0}}' "$WILD" | \   # select one wildtype sequence (i.e. number $x)
        RNAplfold -u 21 -W 80 -L 40 | \                               # run RNAplfold with default params
        tail -n +3 - > wt.tmp                                         # remove the top 2 lines

    # calculate the sum of accessibility values within interval
    awk -v start=$start -v end=$end -v seq_num=$x 'NR==start,NR==end {sum+=$2} END {print seq_num,start,end,sum}' "$wt.tmp" >> wildetype.txt

    # repeat the process for mutant sequence
    awk -v lineNum=$x '{if (NR == lineNum) {print $0}}' "$MUT" | \
        RNAplfold -u 21 -W 80 -L 40 | \
        tail -n +3 - > mt.tmp
    awk -v start=$start -v end=$end -v seq_num=$x 'NR==start,NR==end {sum+=$2} END {print seq_num,start,end,sum}' "$mt.tmp" >> mutant.txt

    rm -f *.tmp
done
#!/bin/bash

fasta_file="NC_000913.faa"
seq_count=$(grep -c "^>" $fasta_file) 
total_aa=$(grep -v "^>" $fasta_file | tr -d '\n' |  wc -c)
average_length=$(echo "$total_aa / $seq_count" | bc)
echo "Average protein length: $average_length"

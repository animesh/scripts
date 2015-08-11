awk '{if($9>=100){print $1}}' read2fugu/mapping/454PairAlign.txt | sort | uniq | wc  sub('[a-z]*-',"",ignore.case = TRUE, extended = TRUE, perl = FALSE,a$SubjAccno)


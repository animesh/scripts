@files = <F*.sff>;
foreach $file (@files) {
  system("sfffile -e tmp5 -o sfffil/$file $file");
} 


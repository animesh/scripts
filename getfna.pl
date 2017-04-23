@files=<*.sff>;
system("rm -rf ecol.fna");
foreach (@files) { $c++;print "$c converting file $_\n";system("/usit/titan/u1/ash022/mapasm454_source_11172009/applicationsBin/sffinfo -seq $_ >> ecol.fna");}


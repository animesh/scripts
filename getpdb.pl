while(<>){
 chomp;
 system("wget http://www.rcsb.org/pdb/files/$_\.pdb.gz");
}
system("gunzip *.gz");

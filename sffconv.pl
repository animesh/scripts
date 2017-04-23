system("ls -1 /space/codgenome/sff/run?/*.sff > tempblat");
open(F,"tempblat");
while(<F>){
chomp;
$c++;
$file="$_.$c.fna";
print "Converting file $_ to $file\n";
system("sffinfo -s $_ > $file");
system("sffinfo -s $_ >> allruns.fasta");
}



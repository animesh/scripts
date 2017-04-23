system("ls -1 NC_010336.*.*.read.fasta > listy");
open(F,"listy");
while(<F>){
	chomp;
	print ;
	system("perl inject-errors.pl $_");
	system("/Home/siv11/ash022/454/bin/runAssembly $_.errinj");
}

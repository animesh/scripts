system("ls -1 NC_010336.*.*.read.fasta > listy");
open(F,"listy");
while(<F>){
	chomp;
	print "$_\n";
	#system("time perl inject-errors.pl $_")
	#/Home/siv11/ash022/v30109test/applicationsBin;
	#system("time /Home/siv11/ash022/454/bin/runAssembly $_.errinj");
	system("time /Home/siv11/ash022/v30109test/applicationsBin/runAssembly $_");
}


open(F,"name41.txt");
open(FO,">name41form.txt");
while($l=<F>){
	chomp $l;
	print FO"\'$l\', ";
}

	
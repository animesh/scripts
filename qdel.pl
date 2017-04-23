$jobid=shift @ARGV;
system("qstat | grep $jobid  > $jobid.sjob.txt");
open(F,"$jobid.sjob.txt");
while($l=<F>){
	chomp $l;
	@t=split(/\./,$l);
	print "@t[0]\n";
	system("qdel @t[0]");
}

	

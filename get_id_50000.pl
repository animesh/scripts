@files=<ecolflow.txtecol.blast.new.test.csv.*.result.out>;
#@files=<t.r.r.r.r.r.*.n>;
open(F,"ecolflow.txtecol.blast.new.testname.csv");
#open(F,"t1");
$mult=50000;
while(<F>){chomp;$c++;$name{$c}=$_;}
close F;
open(FOT,">ecolT.txt");
open(FOB,">ecolB.txt");
foreach (@files) {
	@tmp=split(/\./);
	open(F,$_);
	while(<F>){
		chomp;
		@tmp1=split(/\s+|\:/);
		#print "@tmp1[0] @tmp1[3] @tmp1[5]\n";
		if(@tmp1[5] eq "T"){
			#print "@tmp1[1] -> $name{@tmp1[1]+((@tmp[6]-1)*$mult)}\t";
			print FOT"$name{@tmp1[1]+((@tmp[6]-1)*$mult)}\n";
		}
		if(@tmp1[5] eq "B"){
			#print "@tmp1[1] -> $name{@tmp1[1]+((@tmp[6]-1)*$mult)}\t";
			print FOB"$name{@tmp1[1]+((@tmp[6]-1)*$mult)}\n";
		}
	}
	close F;
	print "@tmp[6]\n";	
	
}


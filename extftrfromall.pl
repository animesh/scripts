$input1=shift @ARGV;
$input2=shift @ARGV;

open(F1,$input1);
open(F2,$input2);
while($lval=<F2>){
	chomp $lval;
        @tex=split(/\,/,$lval);
        $length+=(@tex);
        print "There are $length features\n";
}
close F2;

$fo1="$input1.$input2.extftr.csv";
print "writing to file $fo1\n";
open(FOTP,">$fo1")or die $!;


	while($l=<F1>){
		chomp $l;
		$l=~s/^\s+//g;
		$l=~s/\s+$//g;
		@tlist=split(/\,/,$l);
		for($c=0;$c<$#tlist;$c++){
			$cp=$c+1;
			$ftrname="V$cp";
			$ftrval=@tlist[$c];
			for($cv=0;$cv<=$#tex;$cv++){
				if(@tex[$cv] eq $ftrname){
					print FOTP"$ftrval,";
				}
			}
		}
		$class=@tlist[$c];
		print FOTP"$class\n";
		print "$class\n";
	}
	close F1;
    print "Select\t@tex\tfrom file $input1\n";


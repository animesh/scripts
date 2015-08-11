$input=shift @ARGV;
chomp $input;
$valtop=shift @ARGV;
chomp $valtop;
$appendi=$valtop;
open(F,$input);
$fo1=$input."$appendi.conc.csv";
$fo2=$input."$appendi.class.csv";
print "writing to file $fo1 and $fo2\n";
open(FOTP,">$fo1")or die $!;
open(FOTPC,">$fo2")or die $!;
while($lval=<F>){
	chomp $lval;
        @t=split(/\s+/,$lval);
        $line1++;
	if($line1<=$valtop){
	$out="@t[0]_toML.txt";
        print "$line1\t$out\t@t\n";
	open_file($out,$lval);
	}
}
close F;


sub open_file {
	$rown=0;
	$file=shift;
	$extftrarr=shift;
	@namef=split(/\_/,$file);
	$namef=@namef[0].@namef[1];
	open(FOF,$file);
	while($l=<FOF>){
		chomp $l;
		$l=~s/^\s+//g;
		$l=~s/\s+$//g;
		@tlist=split(/\s+/,$l);
		$rown++;
		for($c=0;$c<$#tlist;$c++){
			$out=@tlist[$c]+0;
			$cp=$c+1;
			$ftrname="FC$cp";
			$ftrval=$out;
			$filevalhash{"$namef-$ftrname"}.="$ftrval,";
		}
		$out=@tlist[$c]+0;
		$classname="C$out";
		$fileclasshash{"$namef"}.="$classname,";
	}
	close FOF;
    print "Select\t$extftrarr\tfrom file $file\n";
}


foreach  (keys %filevalhash) {
        @temp=split(/\-/,$_);
	$cv="@temp[0]";
        print FOTP"$_,$filevalhash{$_}\n";
        #print FOTP"$cvf,$filevalhash{$_}\n";
        print FOTPC"CLASS,$fileclasshash{\"$cv\"}\n";
}

        print FOTP"CLASS,$fileclasshash{\"$cv\"}\n";


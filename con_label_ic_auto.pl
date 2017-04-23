@files=<IC_1*.csv>;
foreach (@files){
$file2=$_;
open(F2,$file2);
$fout="$file2.class.csv";
open(FO,">$fout");
$file1="label.txt";
open(F1,$file1);
while($l1=<F1>){
	$l1line++;
	chomp $l1;
        @t=split(//,$l1);
	$len=$#t;
	print "$len\t@t[0]\n";
	if($len!=0||$l1line>66){die"label file incorrect or more labels"}
	else{push(@lab,@t[0])};
}
close F1;
$ica=$file2;
$ica=~s/\.csv/\_/g;
print "$ica\n";
#__END__
while($l=<F2>){
        $l=~s/^\s+//;
        $l=~s/\s+$//;
        @t=split(/\,/,$l);
        $line++;
        if($line==1){
                        for($c=0;$c<=$#t;$c++){
                                $cp=$c+1;
                                print FO"$ica","V$cp,";
                        }
                        print FO"CLASS\n";
        }
        for($c=0;$c<=$#t;$c++){
                $out=@t[$c]+0;
                print FO"$out,";
        }
        $out=@lab[$line-1]+0;
        print FO"C$out\n";
        print "$line Class $out\n";
}
close F2;
}

$f1=shift @ARGV;
chomp $f1;
$f2=shift @ARGV;
chomp $f2;
open(F1,$f1);
open(F2,$f2);
open(F,">readanno.txt");
while(<F1>){
        chomp $_;
        @t1=split(/\s+/,$_);
        $c1{@t1[0]}=$_;
}
while(<F2>){
	chomp $_;
	@t2=split(/\s+/,$_);
	$c2{@t2[0]}=$_;
}
foreach $r1 (keys %c1) {
	$c++;
	foreach $r2 (keys %c2) {
		if($r1 eq $r2){
			print F"$r1-$r2\t$c1{$r1}\t$c2{$r2}\n";
		}
	}
	if($c%1000==0){print "$c\n";}
}


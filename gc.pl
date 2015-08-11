mesh@astrakan ecoli]$ cat gs.pl
$f1=shift @ARGV;
chomp $f1;
$f2=shift @ARGV;
chomp $f2;
$break=shift @ARGV;
chomp $break;
print "Sorting $f1\n";
system("sort $f1 > $f1.s");
print "Sorting $f2\n";
system("sort $f2 > $f2.s");
open(F1,"$f1.s");
open(F2,"$f2.s");
open(F,">$f1.$f2.out");
while(<F1>){
        chomp $_;
        @t1=split(/\s+/,$_);
        $c1{@t1[0]}=$_;
	push(@n1,@t1[0]);
	$fcnt++;
}
print "Read file $f1\n";
while(<F2>){
        chomp $_;
        @t2=split(/\s+/,$_);
	push(@n2,@t2[0]);
        $c2{@t2[0]}=$_;
}
print "Read file $f2\n";
system("rm $f1.s $f2.s");
for($c=0;$c<=$#n1;$c++) {
	$r1=@n1[$c];
        for($cc=0;$cc<=$#n2;$cc++) {
		$r2=@n2[$cc];
                #print "$c\t$cc\t$r1\t$r2\n";
                if($r1 eq $r2){
                        print F"$r1-$r2\t$c1{$r1}\t$c2{$r2}\n";
			@n2=@n2[$cc+1..$#n2];
                        last;
                }
        }
        if($c%($fcnt/$break)==0){print "Processed $c\n";}
}


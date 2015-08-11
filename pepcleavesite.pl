use strict;
my $file=shift;chomp $file;
my $pep=shift;chomp $pep;$pep=uc($pep);
my $id=0;
my $s=3;
my $e=10;
open(F,$file);
print "MeropsID\tEnzyme\tPattern\tPosition\tAmbiguity\n";
while(my $line=<F>){
        my @tmp=split(/\t/,$line);
        #my $mat = join('', @tmp[$s..$e]);
        my $mat;
        for(my $c=$s;$c<=$e;$c++){
                $tmp[$c]=uc($tmp[$c]);
                if($tmp[$c]=~/[A-Z]/ && length($tmp[$c])==1){
                        $mat.=$tmp[$c];
                }
                if($tmp[$c]=~/[A-Z]/ && length($tmp[$c])>1){
                        $mat.="[$tmp[$c]]";
                }
                else{$mat.="[A-Z]";}
        }
        my $num=$mat=~s/\[A\-Z\]/\[A\-Z\]/g;
        $mat=~s/^\[A\-Z\]+//g;
        if($num!=($e-$s+1) and $mat=~/[A-Z]/ and $pep =~ /$mat/){
		my @temp;
		while($pep =~ /$mat/g){
			my $posi=pos($pep);
			$posi=($posi-($e-$s+1));
			push(@temp,$posi);
		}
		print "$tmp[$id]\t$tmp[$id+1]\t$pep\t$mat\t@temp\t$num\n";
        }
}


8.90E+06

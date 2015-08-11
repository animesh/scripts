if( @ARGV ne 1){die "\nUSAGE\t\"ProgName SeqFile\t\n\n\n";}
$file1 = shift @ARGV;
open (F, $file1) || die "can't open \"$file1\": $!";
$seq="";
while ($line = <F>) {
	if ($line =~ /^>/){
		$c++;
		chomp $line;
		push(@seqname1,$line);	
		if ($seq ne ""){
			push(@seq1,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@seq1,$seq);
close F;
$per=10;
@base=qw/A T G C/;
#open(FT,">$file1.errinj");
for($c1=0;$c1<=$#seq1;$c1++){
	$len=length($seq1[$c1]);
	$toterr=int($len*$per/100);
	$errornum=int(rand($toterr));
	while($errornum>0){
		$errornum--;
                $pcl = int(rand($len));
                #$pcl = int(gaussian_rand()*$len);
		substr($seq1[$c1], $pcl, 1) = "$base[int(rand(4))]";
	}
	print "$errornum-$pcl-$c1-$per-$toterr-$len-$seqname1[$c1]\n";
	#print FT"$seqname1[$c1]\n$seq1[$c1]\n";

}	
#close FT;

sub gaussian_rand {
    my ($u1, $u2);  # uniformly distributed random numbers
    my $w;          # variance, then a weight
    my ($g1, $g2);  # gaussian-distributed numbers

    do {
        $u1 = 2 * rand() - 1;
        $u2 = 2 * rand() - 1;
        $w = $u1*$u1 + $u2*$u2;
    } while ( $w >= 1 );

    $w = sqrt( (-2 * log($w))  / $w );
    $g2 = $u1 * $w;
    $g1 = $u2 * $w;
         return wantarray ? ($g1, $g2) : $g1;
}


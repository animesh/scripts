use strict;
my $f = shift @ARGV;
my $break=1000;

open (F, $f) || die "can't open \"$f\": $!";
my $seq="";
while (my $line = <F>) {
	if ($line !~ /^>/){
		$line=~s/\s+//g; 
		chomp $line;
	 	$seq=$seq.uc($line);
      	}
}
close F;

my $len=length($seq);
for(my $cnt=0;$cnt<=$len;$cnt+=$break){
	    my $sseq=substr($seq,$cnt,$break);
	    my $g=$sseq=~s/G/G/g;
	    my $c=$sseq=~s/C/C/g;
	    my $gc=$g+$c;
	    my $cntm=$cnt+$break/2;
	    print "$cntm\t$gc\n";
}	


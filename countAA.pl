my $f = @ARGV[0];
open (F1, $f) || die "can't open \"$f\": $!";
my $aa = @ARGV[1];
if($aa eq ""){die "provide the single letter code for the amino-acid to count \"$aa\": $!";}
use strict;
use Text::ParseWords;
my %nh;
my %seqc;
my %seqh;
my %ph;
my $cntt;
my $lc;
my $header;
my $seqc;

open(F1,$f);
while(my $l1=<F1>){
	chomp $l1;
	$l1=~s/\r//g;
	if($l1=~/^>/){$seqc=$l1;$seqc=~s/^>ProteinCenter:sp_tr_incl_isoforms\|//;my @tmpn=split(" ",$seqc);$seqc=$tmpn[0];}
	else{$seqh{$seqc}.=uc($l1);}
}
close F1;

print "Name\tCount\tLength\n";
foreach my $seqc (keys %seqh){
		print "$seqc\t";
		#for(my $c=1;$c<=$#tmp;$c++){
		#	print $ph{"$ncc-$c"},"\t";
		#}
		my $e=$seqh{$seqc}=~s/$aa/$aa/g;
		my $len=length($seqh{$seqc});
		print "$e\t$len\n";
}


while (my $line = <F1>) {
 $line =~ s/\r//g;
 $lc++;
 chomp $line;
 if($lc==1){$header=$line;}
 else{
	 my @tmp=parse_line('\t',0,$line);
	 my @tmpp=split(/-/,$tmp[0]);
	 my $aa=substr($tmpp[1],0,3);
	 $nh{$aa}++;
	 for(my $c=1;$c<=$#tmp;$c++){
		 $ph{"$aa-$c"}+=$tmp[$c];
	 }
 }
}

__END__
perl countAA.pl L:\promec\HF\Lars\2021\march\Ingrid\KO\210317_Ingrid1.fasta E > L:\promec\HF\Lars\2021\march\Ingrid\KO\210317_Ingrid1.fasta.count.E.txt

use strict;
use warnings;
use Text::ParseWords;

my %seqh;
my %seqm;
my $seqc;
my $f1=shift @ARGV;

open(F1,$f1);
while(my $l1=<F1>){
	chomp $l1;
	$l1=~s/\r//g;
	if($l1=~/^>/){$seqc=$l1;$seqc=~s/^>//;}
	else{$seqh{$seqc}.=uc($l1);}
}
close F1;

foreach my $seq (keys %seqh){
	$seqm{$seqh{$seq}}.="$seq;";
}

print "Sequence\tNames\tLength\n";
foreach my $seqs (keys %seqm){
	my $len=length($seqs);
	print "$seqs\t$seqm{$seqs}\t$len\n";
}


__END__

perl fas2tablen.pl /cygdrive/l/Davi/Christina/Elite/E.coli_Transcriptome_count\ data/subset30_prots.faa > /cygdrive/l/Davi/Christina/Elite/E.coli_Transcriptome_count\ data/subset30_prots.txt 2>0



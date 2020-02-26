use strict;
use warnings;
use Text::ParseWords;

my %seqn;
my $f1=shift @ARGV;

open(F1,$f1);
while(my $l1=<F1>){
	if($l1=~/^>/){
    $l1=~s/^>//;
    $l1=~s/\,//;
    my @tmp1=split(/ /,$l1);
    #print "$tmp1[0]=$tmp1[5]\n";
    $seqn{$tmp1[0]}=$tmp1[5];
  }
}
close F1;

my $f2=shift @ARGV;
open(F2,$f2);
#my $l;
while(my $l2=<F2>){
  foreach my $sn (keys %seqn){
    $l2 =~ s/\Q$sn\E/$seqn{$sn}/g;
  }
  print $l2;
}
close F2;

__END__
perl deepvariantSetup.pl ../JJOD01.fasta ../Aas-gDNA1-S1-PaE_S1_L001_Rx.vcf > ../Aas-gDNA1-S1-PaE_S1_L001_Rx.reform.vcf

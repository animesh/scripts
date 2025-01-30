#!/usr/bin/perl -w
use strict;
my $USAGE = "perl filterFasta.pl fasta-file seq-length\n";
my $f1  = shift @ARGV or die $USAGE;
my $slen  = shift @ARGV or die $USAGE;
my $seqc;
my %seqm;
open(F1,$f1);
while(my $l1=<F1>){
	chomp $l1;
	$l1=~s/\r//g;
	$l1=~s/\s+//g;
	if($l1=~/^>/){$l1=~s/>//g;$l1=~s/[^[:ascii:]]//g;$seqc=$l1;}
	else{$seqm{$seqc}.=uc($l1);}
}
close F1;

my $seqsLen;
foreach my $seqs (keys %seqm){
    $seqsLen=length($seqm{$seqs});
    if($seqsLen>=$slen){
        print ">$seqs-$seqsLen\n$seqm{$seqs}\n";
    }
}


__END__
(base) ash022@DMED7596:~/animeshs/scripts$ perl filterFasta.pl IRD_UtvidaSekvens_20241127.aa.us.fasta 7 > IRD_UtvidaSekvens_20241127.aa.us.L7.ascii.fasta
perl filterFasta.pl IRD_klon.6F.unstar.fasta 7 > IRD_klon.6F.unstar.L7.ascii.fasta
animeshs@dmed6942:~$ cd promec/promec/FastaDB/    
cat UP000005640_9606_unique_gene.fasta IRD_klon.6F.unstar.L7.ascii.fasta IRD_UtvidaSekvens_20241127.aa.us.L7.ascii.fasta > human.IRD.US.ascii.fasta   

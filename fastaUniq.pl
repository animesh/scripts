use strict;
use warnings;
my $f=shift @ARGV;
unless(-e $f){die "USAGE:perl fastaUniq.pl <fasta file>";}

my $seqn;
my %seq;
my %seqc;
my $lno;
open (F,$f);
while (my $line = <F>) {
	$lno++;
	$line =~ s/[\r\n]+$//;
	if($line=~/^>/){
		$line=~s/^>//;
		if($seq{$line}){print "$f-$lno multiple sequence with same name, $line added as Duplicate\n";$seqn="Duplicate";}
		else{$seqn=$line;}
	}
	elsif($line!~m/[^ATGC]/){
		$seq{$seqn}.=uc($line);
	}
	else{
		print "$f-$lno non ATGC detected, $seqn ignored due to $line\n";
		if($seq{$seqn}){undef $seq{$seqn};}
	}
}
close F;

open(FO,">$f.uniq.fasta");
my $rtseq;
foreach $seqn (keys %seq){
	if($seq{$seqn}){
		$seqc{$seq{$seqn}}++;
		$rtseq=reverse($seq{$seqn});
		$rtseq=~tr/ATGC/TACG/;
		$seqc{$rtseq}++;
		#print "$seqn\t$seq{$seqn}\t$seqc{$seq{$seqn}}\n$rtseq\t$seqc{$rtseq}\n";
	}
	elsif($seqc{$seq{$seqn}}==1 && $seqc{$rtseq}==1){
		print ">$seqn\n$seq{$seqn}\n";
	}
	#else{print "$seqc{$seq{$seqn}} $seqc{$rtseq}";}
}
close FO;

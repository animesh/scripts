#!/usr/bin/perl
use strict;
use warnings;
my $f=shift @ARGV;
unless(-e $f){die "USAGE:perl motif.pl <fasta file> <motif as regular expression>";}

my $motif=shift;
my $rev=shift;
if($rev){$motif=reverse($motif);$motif=~tr/][/[]/;}
my $seqn="";
my $seq="";
my $cnt=0;

sub motifind {
	my $flag=0;
	my $seql=shift;
	my $motf="";
	while($seql =~ /($motif)/gi){
		$motf.="$1,$-[0]-$+[0];";
		pos($seql) = $-[0] + 1;
		$flag+=()=$1=~/$motif/g;
	}
	$motf.="\t$flag";
	return $motf;
}

print "Sequence Header in $f\t$motif found as Sequence(s),Position(s,0 for 1st);\tTotalMotif(s)\tSequenceLine(s)*60~Len\n";
open (F,$f);
while (my $line = <F>) {
	$line =~ s/[\r\n]+$//;
	if($line=~/^>/){
		if($seq ne ""){print $seq,"\t",motifind($seq),"\t",$cnt,"\n";}
		$seqn=$line;
		$cnt=0;
		$seq="";
	}
	else{
		if($cnt==0){print "$seqn\t";}
		$line =~ s/[^a-zA-Z]//g;
		$seq.=$line;
		$cnt++;
	}
}
close F;

__END__
#example search for UNG motif as shown in https://www.genome.jp/tools/motif/MOTIF2.html for [RK]-[FWY]-[ALVI]-[GALVI]-[RK]
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
gunzip uniprot_sprot.fasta.gz
perl motif.pl uniprot_sprot.fasta "[RK][FWY][ALVI][GALVI][RK]" > uniprot_sprot.motif.txt
perl motif.pl uniprot_sprot.fasta "[RK][FWY][ALVI][GALVI][RK]" | awk -F '\t' '$3!=""' > uniprot_sprot.motif.found.txt

#to search for reverse form of the motif (only works for square bracket expression so far...)
perl motif.pl UNG.fasta "[ILMN]...[QVS]..[RKSE][ILM][QE].[NK][KR]..A[IL].[RLI][RLI]..[KR]" reverse | awk -F '\t' '$2!=""' | less

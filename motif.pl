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
		if($seq ne ""){print motifind($seq),"\t",$cnt,"\n";}
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
#example search for UNG motif as shown in https://febs.onlinelibrary.wiley.com/doi/full/10.1111/febs.12867
curl "https://www.uniprot.org/uniprot/?query=UNG&sort=score&format=fasta" -o UNG.fasta # create fasta file with API based search for UNG sequences in uniprot sorted by score https://www.uniprot.org/help/api_queries
perl motif.pl UNG.fasta "[ILMN]...[QVS]..[RKSE][ILM][QE].[NK][KR]..A[IL].[RLI][RLI]..[KR]" | awk -F '\t' '$2!=""' | less

#to search for reverse form of the motif (only works for square bracket expression so far...)
perl motif.pl UNG.fasta "[ILMN]...[QVS]..[RKSE][ILM][QE].[NK][KR]..A[IL].[RLI][RLI]..[KR]" reverse | awk -F '\t' '$2!=""' | less

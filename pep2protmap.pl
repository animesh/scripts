use strict;
use warnings;
my $seq;
my $seqc;
my $seql;
my %seqh;
my %seqn;
my @st;

open(F2,$ARGV[0]);
while(my $l1=<F2>){
	chomp $l1;
  $l1=~s/\r//g;
	$seql=$l1;
  if($l1=~/^>/){
		#print "$l1\t";
  	@st=split(/\s+/,$l1);
		$seqn{$st[0]}=$l1;
  	#print "$st[0]\t";
  }
  else{
	  $seql=~s/\s+|[0-9]|\n//g;
	  $seql=uc($seql);
		$seql=~s/I/L/g;
		$seqh{$st[0]}.=$seql;
	}
}
close F2;
my $size = keys %seqn;
print "\nRead# $size sequences from $ARGV[0]\n";

print "\nOpening peptide list from $ARGV[1]\n\n";
open(F4,$ARGV[1]);
my $cntSeq=0;
my $cntMat=0;
while(my $l1=<F4>){
	chomp $l1;
  $l1=~s/\r//g;
	if($l1=~/^>/){print "$l1\n";}
	else{
		my @st=split(/\t/,$l1);
		my $pep=$st[$ARGV[2]-1];
		#else{next;}
		$pep=~s/\r//g;
		chomp($pep);
		$pep=uc($pep);
		$pep=~s/I/L/gi;
		$pep =~ s/[^A-Z,]//g;
		foreach(keys %seqn){
			#print "$_\n$seqn{$_}\n$seqh{$_}\n";
			my $pos="";
			my $offset = 0;
			$seql=$pep;
			$seq=$seqh{$_};
			my $res = index($seq, $seql, $offset);
			while ($res != -1) {
				$pos.="$res;";
				$offset = $res + 1;
				$res = index($seq, $seql, $offset);
			}
			if($pos ne ""){print "$_\t$pos\n";$cntMat++;}
		}
	}
	$cntSeq++;
}
print "\nProcessed $cntSeq Sequences\nFound $cntMat Matches\n";
close F4;
__END__
C:\Users\animeshs\GD\scripts>perl pep2protmap.pl   "L:\promec\HF\Lars\2021\mai\MortenH\uniprot-mappedsequence__Q9NRI5-1_+OR+mappedsequence__A0A087WYX6-1_+O--.fasta" "L:\promec\HF\Lars\2021\mai\MortenH\Serie 2\combined\txt\peptides.txt" 1

Read# 18 sequences from L:\promec\HF\Lars\2021\mai\MortenH\uniprot-mappedsequence__Q9NRI5-1_+OR+mappedsequence__A0A087WYX6-1_+O--.fasta

Opening peptide list from L:\promec\HF\Lars\2021\mai\MortenH\Serie 2\combined\txt\peptides.txt


Processed 23266 Sequences
Found 0 Matches

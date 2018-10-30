use strict;
use warnings;
my $f=shift @ARGV;
unless(-e $f){die "USAGE:perl fastaUniq.pl <fasta file>";}
die "$f.uniq.fasta exists, bailing out for $f!\n" if -e "$f.singleline.fasta";

my $seqn;
my %seq;
my %seqc;
my $lno;
open (F,$f);
while (my $line = <F>) {
	$lno++;
	$line =~ s/[\r\n\s]+$//;
	$line = uc($line);
	if($line=~/^>/){
		$line=~s/^>//;
		if($seq{$line}){print "$f-$lno multiple sequence with same name, $line added as Duplicate\n";$seqc{$line}++;$seqn="$line-repeat$seqc{$line}";}
		else{$seqn=$line;}
	}
	else{
		$seq{$seqn}.=$line;
	}
}
close F;

$lno = keys(%seq) ;
print "processed $f and writing $lno fasta sequence(s) to $f.singleline.fasta\n";

open(FO,">$f.singleline.fasta");
foreach (keys %seq){
	print FO">$_\n$seq{$_}\n";
}
close FO;

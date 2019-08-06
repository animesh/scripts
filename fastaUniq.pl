use strict;
use warnings;
my $f=shift @ARGV;
unless(-e $f){die "USAGE:perl fastaUniq.pl <fasta FILE>";}
die "$f.uniq.fasta exists, bailing out for $f!\n" if -e "$f.uniq.fasta";

my %seqh;
my $seqc;
my $f1=shift @ARGV;
open(F1,$f);
while(my $l1=<F1>){
	chomp $l1;
	$l1=~s/\r//g;
	if($l1=~/^>/){$seqc=$l1;$seqc=~s/^>//;}
	else{$seqh{$seqc}.=$l1;}
}
close F1;
my $cnt = keys(%seqh) ;
print "processed $f containing $cnt fasta sequence(s)\n";

open(FO,">$f.uniq.fasta");
my %seqm;
foreach my $seq (keys %seqh){
  if(!$seqm{$seqh{$seq}}){
    my $ln=length($seqh{$seq});
    print FO">$seq\t$ln\n$seqh{$seq}\n";
		$seqm{$seqh{$seq}}++;
  }
	$seqm{$seqh{$seq}}.="$seq;";
}
$cnt = keys(%seqm) ;
print "writing non redundant $cnt fasta sequence(s) to $f.uniq.fasta\n";
close FO;

open(FOR,">$f.redundant.fasta");
$cnt = 0;
foreach my $seq (keys %seqm){
	my @seqs=split(/;/,$seqm{$seq});
	if($#seqs){
		my $ln=length($seq);
		print FOR">$seqm{$seq}\t$ln\n$seq\n";
		$cnt++;
	}
}
print "writing redundant $cnt fasta sequence(s) to $f.redundant.fasta\n";
close FOR;

__END__
wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640_9606.fasta.gz
gunzip UP000005640_9606.fasta.gz
perl fastaUniq.pl UP000005640_9606.fasta
processed UP000005640_9606.fasta containing 20667 fasta sequence(s)
writing non redundant 20602 fasta sequence(s) to UP000005640_9606.fasta.uniq.fasta
writing redundant 52 fasta sequence(s) to UP000005640_9606.fasta.redundant.fasta

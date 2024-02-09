use strict;
use warnings;
my $f=shift @ARGV;
unless(-e $f){die "USAGE:perl fastaUniq.pl <fasta FILE>";}
die "$f.uniq.fasta exists, bailing out for $f!\n" if -e "$f.uniq.fasta";

my %seqh;
my $seqc;
my $f1=shift @ARGV;
open(F1,$f);
my $cnt=0;
my %seqns;
while(my $l1=<F1>){
	chomp $l1;
	$l1=~s/\r//g;
	$l1=~s/\\t//g;
	$l1=~s/\\n//g;
	$l1=~s/\%//g;
	$l1=~s/\n//g;
	$l1=~s/\//-/g;
	if($l1=~/^>/){
		$seqns{$l1}++;
		$cnt++;
		if($seqns{$l1}>1){print "duplicate $seqns{$l1} of $l1\n";$seqc="";}
		else{$seqc=$l1;$seqc=~s/^>//;$seqc=~s/>/2/g;}}#print "$cnt\t$seqc\n";}}
	#else{$seqh{$seqc}.=$l1;}
	elsif($seqc ne ""){$seqh{$seqc}.=$l1;}
	else{next;}
}
close F1;
print "processed $f containing $cnt fasta sequence(s)\n";
$cnt = keys(%seqh) ;
print "writing unique $cnt fasta sequence(s) to $f.uniq.fasta\n";

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
cat  PD/Animesh/TK/fastq/TK*/variants/combined.spritz.snpeff.protein.fasta > PD/Animesh/TK/fastq/TK.combined.spritz.snpeff.protein.fasta
cat  PD/Animesh/TK/fastq/TK*/isoforms/combined.spritz.isoform.protein.fasta > PD/Animesh/TK/fastq/TK.combined.spritz.isoform.protein.fasta
cat  /cluster/projects/nn9036k/FastaDB/UP000005640_9606*  MSTK/TK.combined.spritz.*  > human.TK.combo.fasta
perl fastaUniq.pl human.TK.combo.fasta
processed human.TK.combo.fasta containing 1713276 fasta sequence(s)
writing unique 650366 fasta sequence(s) to human.TK.combo.fasta.uniq.fasta
writing redundant 109696 fasta sequence(s) to human.TK.combo.fasta.redundant.fasta
bash slurmMQrun.sh /cluster/projects/nn9036k/MaxQuant_v_2.4.13.0/bin/MaxQuantCmd.exe $PWD/MSTK $PWD/human.TK.combo.fasta.uniq.fasta mqpar.xml scratch.slurm

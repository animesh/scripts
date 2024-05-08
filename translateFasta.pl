#!/usr/bin/perl -w
use strict;

my $USAGE = "translate.pl file.fasta\n";

my %codon =
(
  "TTT" => "F", "TTC" => "F", "TTA" => "L", "TTG" => "L",
  "TCT" => "S", "TCC" => "S", "TCA" => "S", "TCG" => "S",
  "TAT" => "Y", "TAC" => "Y", "TAA" => "*", "TAG" => "*",
  "TGT" => "C", "TGC" => "C", "TGA" => "*", "TGG" => "W",
  "CTT" => "L", "CTC" => "L", "CTA" => "L", "CTG" => "L",
  "CCT" => "P", "CCC" => "P", "CCA" => "P", "CCG" => "P",
  "CAT" => "H", "CAC" => "H", "CAA" => "Q", "CAG" => "Q",
  "CGT" => "R", "CGC" => "R", "CGA" => "R", "CGG" => "R",
  "ATT" => "I", "ATC" => "I", "ATA" => "I", "ATG" => "M",
  "ACT" => "T", "ACC" => "T", "ACA" => "T", "ACG" => "T",
  "AAT" => "N", "AAC" => "N", "AAA" => "K", "AAG" => "K",
  "AGT" => "S", "AGC" => "S", "AGA" => "R", "AGG" => "R",
  "GTT" => "V", "GTC" => "V", "GTA" => "V", "GTG" => "V",
  "GCT" => "A", "GCC" => "A", "GCA" => "A", "GCG" => "A",
  "GAT" => "D", "GAC" => "D", "GAA" => "E", "GAG" => "E",
  "GGT" => "G", "GGC" => "G", "GGA" => "G", "GGG" => "G",
);


sub translate
{
  my $seqn = shift;
  my $seq = shift;
  my $start = shift;
  my $end = shift;

  return if !defined $seq;

  $start = 1 if !defined $start;
  $end = length($seq) if !defined $end;
 

  $start--;
  my $nona=$seq=~s/[^A-Z]//g;
  my $s = substr($seq, $start, $end-$start);
  my $l = length ($s);

  my $aaseq;

  for (my $i = 0; $i+2 < $l; $i+=3)
  {
    my $aa = $codon{uc(substr($s, $i, 3))};
    $aaseq .= $aa;
  }

  my $aalen = length($aaseq);
  print "$seqn|$start-$end|proteinLength-$aalen|hanging-",$l%3,"|UTR-$nona|\n$aaseq\n";
}



my $f1  = shift @ARGV or die $USAGE;
my $seqc;
my %seqm;
open(F1,$f1);
while(my $l1=<F1>){
	chomp $l1;
	$l1=~s/\r//g;
	$l1=~s/\s+//g;
	if($l1=~/^>/){$seqc=$l1;}
	else{$l1=~s/U/T/g;$l1=~s/u/T/g;$seqm{$seqc}.=uc($l1);}
}
close F1;

my $name;
foreach my $seqs (keys %seqm){
  my $fseqs=$seqs."_"."Fwd";
  translate($fseqs, $seqm{$seqs}, 1, length($seqm{$seqs}));
  translate($fseqs, $seqm{$seqs}, 2, length($seqm{$seqs}));
  translate($fseqs, $seqm{$seqs}, 3, length($seqm{$seqs}));
  my $rseqs=$seqs."_"."Rev";
  my $revseq=reverse($seqm{$seqs});
  $revseq=~tr/ATGC/TACG/;
  translate($rseqs, $revseq, 1, length($revseq));  
  translate($rseqs, $revseq, 2, length($revseq));  
  translate($rseqs, $revseq, 3, length($revseq));  
}


__END__
(casanovo_env) (base) ash022@DMED7596:~/Scripts$ perl translateFasta.pl vilnius.IRD.fasta > vilnius.IRD.aa.fasta
(casanovo_env) (base) ash022@DMED7596:~/Scripts$ grep "^>" vilnius.IRD.fasta | wc
     80    1573   12301
(casanovo_env) (base) ash022@DMED7596:~/Scripts$ perl translateFasta.pl vilnius.IRD.fasta > vilnius.IRD.aa.fasta
(casanovo_env) (base) ash022@DMED7596:~/Scripts$ grep "\*" vilnius.IRD.aa.fasta | wc
    341     341   25038
(casanovo_env) (base) ash022@DMED7596:~/Scripts$ grep "^>" vilnius.IRD.aa.fasta | wc
    480     480   85296
(casanovo_env) (base) ash022@DMED7596:~/Scripts$ perl transeqUnstar.pl vilnius.IRD.aa.fasta > vilnius.IRD.aa.us.fasta
(casanovo_env) (base) ash022@DMED7596:~/Scripts$ grep "^>" vilnius.IRD.aa.us.fasta | wc
   1608    1608  307348
(casanovo_env) (base) ash022@DMED7596:~/Scripts$ grep "\*" vilnius.IRD.aa.us.fasta | wc


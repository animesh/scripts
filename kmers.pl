#!/usr/local/bin/perl

use AMOS::AmosLib;

$N = 8;
$START = 60;
my %starts;
my %ends;
my $nseqs = 0;
while (<>){
 chomp;
 if (/^>/) {
  print STDERR "$nseqs\r";
  $nseqs++;
  $seq = uc($seq);
  #print "$seq\n";
  for ($i = 0; $i < length($seq) - $N + 1; $i++){
  #  print "nmer: ", substr($seq, $i, $N), "\n";
    if ($i <= 60) {
      $starts{substr($seq, $i, $N)}++;
#      $starts{reverseComplement(substr($seq, $i, $N))}++;
    } else {
      $ends{substr($seq, $i, $N)}++;
#      $ends{reverseComplement(substr($seq, $i, $N))}++;
    }
  }
  $seq = "";
  next;
 }
 $seq .= $_;
}
$seq = uc($seq);
for ($i = 0; $i < length($seq) - $N + 1; $i++){
  #  print "nmer: ", substr($seq, $i, $N), "\n";
    if ($i <= 60) {
      $starts{substr($seq, $i, $N)}++;
      $starts{reverseComplement(substr($seq, $i, $N))}++;
    } else {
      $ends{substr($seq, $i, $N)}++;
      $ends{reverseComplement(substr($seq, $i, $N))}++;
    }
}

while (($nmer, $n) = each %starts){
  print "$nmer\t$n\t$ends{$nmer}\n";
}

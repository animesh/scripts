use strict;
use warnings;
use Data::Dumper;
my $f=shift @ARGV;
unless(-e $f){die "USAGE:perl fastUniq.pl <fastq with \@name followed by sequence, can also work with fasta if seqeuences are in single line after >name>";}
die "$f.uniq.fasta exists, bailing out for $f!\n" if -e "$f.uniq.fasta";

my $seqn="";
my %seq;
my $cnt=0;
my %twoBit = ('T' => 0b00,'C' => 0b01,'G' => 0b10,'A' => 0b11, 0b00 => 'T',0b01 => 'C',0b10 => 'G',0b11 => 'A');

sub compress2bit{
  my $fasta=shift;
  my @bases = split //, $fasta;
  my $bits = '';
  for my $i ( 0 .. $#bases ) {vec( $bits, $i, 2 ) = $twoBit{ $bases[$i] };}
  return $bits;
}

open (F,$f);
open(FO,">$f.uniq.fasta");
while (my $line = <F>) {
	$line =~ s/[\r\n]+$//;
	$line = uc($line);
	if($line=~/^[@>]/){
		$line=~s/^[@>]//;
		$seqn=$line;
		$cnt=0;
	}
	elsif($cnt==0){
			$cnt++;
			$line=~s/\s+//g;
			my $rtseq=reverse($line);
			$rtseq=~tr/ATGC/TACG/;
			$rtseq=compress2bit($rtseq);
      my $lines=compress2bit($line);
      if($line!~m/[^ATGC]/ and $seq{$lines}<1 and $seq{$rtseq}<1){
        print FO">$seqn\n$line\n";
			}
      if($seq{$rtseq} eq ""){
				$seq{$rtseq}++;
        print "$seqn\trev cnt $seq{$rtseq}\n";
			}
      if(!$seq{$lines} eq ""){
        $seq{$lines}++;
        print "$seqn\tfwd cnt $seq{$rtseq}\n";
			}
			else{next;}
		}
		else{next;}
}
close F;
$cnt = keys(%seq) ;
print "processed $f and writing non redundant $cnt fasta sequence(s) to $f.uniq.fasta\n";
close FO;

use strict;
use warnings;
use Data::Dumper;
my $f=shift @ARGV;
unless(-e $f){die "USAGE:perl fastqUniq.pl <fastq with \@name followed by sequence, can also work with fasta if seqeuences are in single line after >name>";}
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

sub expand2bit{
	my $bits=shift;
	my $bitslen=shift;
  my $strings = '';
  for my $i (0 .. $bitslen-1){$strings.=$twoBit{vec($bits,$i,2)};}
  return $strings;
}

open (F,$f);
while (my $line = <F>) {
	$line =~ s/[\r\n]+$//;
	$line = uc($line);
	if($line=~/^[@>]/){
		$line=~s/^[@>]//;
		$seqn=$line;
		$cnt=0;
	}
	else{
		if($cnt==0){
			$cnt++;
			$line=~s/\s+//g;
			my $lenseq=length($line);
			my $rtseq=reverse($line);
			$rtseq=~tr/ATGC/TACG/;
			$rtseq=compress2bit($rtseq);
			if($seq{$rtseq}){
				$seq{$rtseq}.="revCom($seqn);$lenseq;";
				#print "$seqn\t$seq{$rtseq}\t$line\t$rtseq\n";
			}
			elsif($line!~m/[^ATGC]/){
				$line=compress2bit($line);
				$seq{$line}.="$seqn;$lenseq;";
			}
			else{next;}
		}
		else{next;}
	}
}
close F;

$cnt = keys(%seq) ;
print "processed $f and writing non redundant $cnt fasta sequence(s) to $f.uniq.fasta\n";

open(FO,">$f.uniq.fasta");
#print FO Dumper(%seq);
foreach (keys %seq){
	my @fastalen=split(/;/,$seq{$_});
	my $fasta=expand2bit($_,$fastalen[-1]);
	print FO">$seq{$_}\n$fasta\n";
}
close FO;
__END__
find . -name "*.fastq" | parallel --jobs 24 "perl $HOME/scripts/fastqUniq.pl {}"
#windows cmd
for %i in (*.fastq) do perl fastqUniq.pl %i
#for fastafile with same sequence spread across multiple lines, first convert multi line sequence to single Line
perl fastaUniq.pl <fasta file>

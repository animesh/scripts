use strict;
use warnings;
use Data::Dumper;
my $f=shift @ARGV;
unless(-e $f){die "USAGE:perl fastqUniq.pl <fastq with \@name followed by sequence, can also work with fasta if seqeuences are in single line after >name>";}
die "$f.uniq.fasta exists, bailing out for $f!\n" if -e "$f.uniq.fasta";

my $seqn="";
my %seq;
my $cnt=0;

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
			my $rtseq=reverse($line);
			$rtseq=~tr/ATGC/TACG/;
			if($seq{$rtseq}){
				$seq{$rtseq}.="revCom($seqn);";
				#print "$seqn\t$seq{$rtseq}\t$line\t$rtseq\n";
			}
			elsif($line!~m/[^ATGC]/){
				$seq{$line}.="$seqn;";
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
	print FO">$seq{$_}\n$_\n";
}
close FO;
__END__
find . -name "*.fastq" | parallel --jobs 24 "perl $HOME/scripts/fastqUniq.pl {}"
#windows cmd
for %i in (*.fastq) do perl fastqUniq.pl %i
#for fastafile with same sequence spread across multiple lines, first convert multi line sequence to single Line
perl fastaUniq.pl <fasta file>

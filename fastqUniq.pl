use strict;
use warnings;
my $f=shift @ARGV;
unless(-e $f){die "USAGE:perl fastqUniq.pl <fastq file>";}
die "$f.uniq.fasta exists, bailing out for $f!\n" if -e "$f.uniq.fasta";

my $seqn="";
my %seq;
my $cnt=0;

open (F,$f);
while (my $line = <F>) {
	$line =~ s/[\r\n]+$//;
	if($line=~/^@/){
		$line=~s/^@//;
		$seqn=$line;
		$cnt=0;
	}
	else{
		if($cnt==0 and $line!~m/[^ATGC]/){
			$seq{uc($line)}.="$seqn;";
			$cnt++;
		}
		else{next;}
	}
}
close F;

print "processing $f and writing non redundant fasta sequence to $f.uniq.fasta\n";
open(FO,">$f.uniq.fasta");
foreach $seqn (keys %seq){
	if($seq{$seqn}){
		print FO">$seq{$seqn}";
		my $rtseqn=reverse($seqn);
		$rtseqn=~tr/ATGC/TACG/;
		if($seq{$rtseqn}){
			print FO"(revcom)$seq{$rtseqn}\n$seqn\n";
			undef $seq{$rtseqn};
		}
		else{print FO"\n$seqn\n";}
	}
}
close FO;




__END__
find . -name "*.fastq" | parallel --jobs 24 "perl $HOME/scripts/fastqUniq.pl {}"

#can work with fasta if you change the ">" to "@"
sed 's/>/@/' fastafile > file.fastq

#windows cmd 
for %i in (*.fastq) do perl fastqUniq.pl %i

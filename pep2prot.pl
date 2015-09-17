use strict;
use warnings;
use Text::ParseWords;

my %seqh;
my %sfull;
my $seqc;
my $f1=shift @ARGV;
my $f2=shift @ARGV;
my $col=0;

open(F1,$f1);
while(my $l1=<F1>){
	chomp $l1;
        $l1=~s/\r//g;
        if($l1=~/^>/){my @comsplit=split(/;/,$l1);$seqc=$comsplit[0];}
        else{my @comsplitseq=split(/;/,$l1);$comsplitseq[0]=~s/[0-9]|\s+//g;$seqh{$seqc}.=uc($comsplitseq[0]);}
}
close F1;

open(F2,$f2);
while(my $l2=<F2>){
	if($l2!~m/^Sequence/){
		chomp $l2;
        $l2=~s/\r//g;
        my @temp=parse_line('\t',0,$l2);
        print "$temp[$col]\t";
		my $cntmat=0;
        foreach my $seq (keys %seqh){
        	if($seqh{$seq}=~/$temp[$col]/){
				my $loccntmat=$seqh{$seq}=~s/$temp[$col]/$temp[$col]/g;
				$seq=~s/^>//g;print "$seq;";
				$cntmat+=$loccntmat;
				}
        }
        print "\t$cntmat\n";
	}
}
close F2;

__END__

perl pep2prot.pl /cygdrive/x/FastaDB/SerpinB3P29508.fasta /cygdrive/x/Qexactive/LARS/2013/november/ole\ jan/SerpinResultsBlast.txt 2>0



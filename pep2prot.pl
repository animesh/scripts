use strict;
use warnings;
use Text::ParseWords;

my %seqh;
my %sfull;
my $seqc;
my $f1=shift @ARGV;
my $f2=shift @ARGV;
my $pid=1;
my $col=5;

open(F1,$f1);
while(my $l1=<F1>){
	chomp $l1;
        $l1=~s/\r//g;
        if($l1=~/^>/){my @st=split(/\|/,$l1);$seqc=$st[$pid];$sfull{$seqc}=$l1;}
        else{$l1=~s/[0-9]|\s+//g;$seqh{$seqc}.=uc($l1);}
}
close F1;

open(F2,$f2);
while(my $l2=<F2>){
	chomp $l2;
        $l2=~s/\r//g;
        my @temp=parse_line(',',0,$l2);
        foreach my $seq (keys %seqh){
        	if($seqh{$seq}=~/$temp[$col]/){print "$temp[$col],$sfull{$seq},$l2\n";}
        }
        print 
}
close F2;

__END__

perl pep2prot.pl /cygdrive/x/FastaDB/SerpinB3P29508.fasta /cygdrive/x/Qexactive/LARS/2013/november/ole\ jan/SerpinResultsBlast.txt 2>0



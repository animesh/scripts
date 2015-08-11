use strict;
use warnings;
use Text::ParseWords;

my %seqh;
my %sfull;
my $seqc;
my $f1=shift @ARGV;
my %pephsh;
my %pepcnt;
my %peplgt;

open(F1,$f1);
while(my $l1=<F1>){
	chomp $l1;
        $l1=~s/\r//g;
        if($l1=~/^>/){my @st=split(/\|/,$l1);$seqc=$st[1];$sfull{$seqc}=$l1;}
        else{$l1=~s/[0-9]|\s+//g;$seqh{$seqc}.=uc($l1);}
}
close F1;

foreach my $seq (keys %seqh){
	my @st=split(/[KR]/,$seqh{$seq});
	for(my $c1=0;$c1<=$#st;$c1++){
		$peplgt{$st[$c1]}=length($st[$c1]);
		$pephsh{$st[$c1]}.="$seq;";
		$pepcnt{$st[$c1]}++;
	}
}

foreach my $pep (keys %pepcnt){
	print "$pep\t$pepcnt{$pep}\t$peplgt{$pep}\t$pephsh{$pep}\n";
}

__END__

perl pep2prot.pl /cygdrive/l/Qexactive/Mirta/QExactive/Bcell_Project/combined.fasta  6 > /cygdrive/l/Qexactive/Mirta/QExactive/Bcell_Project/combinedpeplist5.txt





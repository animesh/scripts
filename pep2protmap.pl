use strict;
use warnings;
my $seq;
my $seqc;
my $seql;

open(F1,$ARGV[0]);
while(my $l1=<F1>){
	chomp $l1;
        $l1=~s/\r//g;
        if($l1=~/^>/){my @st=split(/\s+/,$l1);$seqc=$st[0];}
        else{$l1=~s/[0-9]|\s+//g;$seq.=uc($l1);}
}
close F1;

open(F2,$ARGV[1]);
while(my $l1=<F2>){
	chomp $l1;
        $l1=~s/\r//g;
	$seql=$l1;
        if($l1=~/^>/){
        	my @st=split(/\s+/,$l1);
        	print "$st[0]\t";
        }
        else{
        $seql=~s/\s+|[0-9]|\n//g;
        $seql=uc($seql);
	my $offset = 0;
	$seql=~s/I/L/gi;
	$seq=~s/I/L/gi;
	my $res = index($seq, $seql, $offset);
	while ($res != -1) {
		print "$res\t";
		$offset = $res + 1;
		$res = index($seq, $seql, $offset);
	}
	print "$seql\n";
	}
}
close F2;

__END__

use strict;
use warnings;
my $seq;
my $seqc;
my $seql;
my %seqn;
my %pep;

open(F1,$ARGV[0]);
while(my $l1=<F1>){
	chomp $l1;
  $l1=~s/\r//g;
	my @tmp=split(/\t/,$l1);
	my $p=$tmp[34]=~s/\:p\./\:p\./g;
	my @tmp2=split(/\;/,$tmp[34]);
	if($p>$#tmp2){
		#print $tmp2[0],"\t",$#tmp2,"\t",$p,"\n";
		for(my $c=0;$c<=$#tmp2;$c++){
			my @tmp4=split(/\./,$tmp2[$c]);
			$seqn{$tmp4[0]}++;
			$pep{$tmp[0]}=$tmp4[0];
		}
	}
}
close F1;
#foreach(keys %seqn){print "$_\t$seqn{$_}\n";}
foreach(keys %pep){print "$_\t$pep{$_}\n";}

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

use strict;
use warnings;
my %f1;

open(F1,$ARGV[0]);
while(my $l1=<F1>){
	chomp $l1;
	$l1=~s/\r//g;
        my @t1=split(/\t/,$l1);
        $f1{$t1[0]}=$l1;
}
close F1;

open(F2,$ARGV[1]);
while(my $l1=<F2>){
	chomp $l1;
	$l1=~s/\r//g;
        my @t1=split(/\t/,$l1);
        my $midx=0;
        foreach my $key (keys %f1){
        	if($key=~/$t1[0]/g){
        		print "$key\t$t1[0]\t$f1{$key}\t$l1\n";
        		$midx++;
        	}
        }
        if($midx==0){print "$t1[0]\tNot Found\n"}
}
close F2;

__END__

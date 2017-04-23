use strict;
use warnings; 
use Math::BigFloat lib => 'GMP';

#Accuracy upto 100th number

my $levelacc=100;
my $x1=Math::BigFloat->new(-1);
my $x2=Math::BigFloat->new(-1.57);
my $x3=Math::BigFloat->new(-113.1);
my $L1=$x1->bexp($levelacc); 
my $L2=$x2->bexp($levelacc);  
my $L3=$x3->bexp($levelacc);  
my $sum1=($L1);
my $sum2=($L1+$L2);
my $sum3=($L1+$L2+$L3);
print "$L1,$L2,$L3\t$sum1\t$sum2\t$sum3\n";

#Normal Way
$L1=exp(-1);
$L2=exp(-1.57);
$L3=exp(-113.1);
$sum1=($L1);
$sum2=($L1+$L2);
$sum3=($L1+$L2+$L3);
print "$L1,$L2,$L3\t$sum1\t$sum2\t$sum3\n";

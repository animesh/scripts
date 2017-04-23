#!/usr/bin/perl
$f1=shift@ARGV;
$f2=shift@ARGV;
open(F1,$f1);open(F2,$f2);
while($l1=<F1>)
{
chomp($l1);
push(@1,$l1);
}
while($l2=<F2>)
{
chomp($l2);
push(@2,$l2);
}
foreach $t1(@1)
	{foreach $t2(@2)
		{if($t1 eq $t2)
			{$n++;
			}
		}
	if($n == 0)
		{
		print "$t1 is unique\n";
		}
	else
		{
		print "$t1 is repeated $n times\n";
		}
	$n=0;
	}
		
#@unique=@2-@1;
#print foreach @unique;


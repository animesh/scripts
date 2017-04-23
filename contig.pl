#!/usr/bin/perl
open f1,"AC109365.txt";
while($line=<f1>)
{
chomp $line;
if($line=~/^>/)
{print "$line\t";}
if($line=~/Score/)
{print "$line\t";}
if($line=~/Identities/)
{print "$line\t";}
if($line=~/Query: /)
{print "$line\t";}
if($line=~/Sbjct/)
{print "$line\n";}

}

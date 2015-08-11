#!/usr/bin/perl
print "enter file name \n";
$file=<>;
chomp;
open F1,$file;
while($l=<F1>)
{
chomp($l);
$li=$li.$l;
}
@seq=split(//,$li);
$len=@seq;
print "$len\n";


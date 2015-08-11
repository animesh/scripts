#!/usr/bin/perl
#@base=qw/A T C G/;
open(F,"annofgeneshpfchr2.html")||die "can't open";
#$seq = "";
while ($line = <F>) {
if($line =~ /^>F/)
{print $line;}

}

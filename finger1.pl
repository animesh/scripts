#!/usr/bin/perl
$f=shift@ARGV;
for($c=0;$c<=100;$c++){
$t=$f.$c;
system("finger $t");
}


#!/usr/bin/perl
system "ls -1>tempfile.perl";
open F,"tempfile.perl";
while ($l=<F>)
{
chomp $l;
push(@NAMES,$l);
}
print "pw,\<matrixname\>,\<matrix name\>,1,pwmatrix,S\n";
foreach $n (@NAMES)
{
$nn=$n;
print " ,$nn,$nn, , , \n";

}
unlink "tempfile.perl";

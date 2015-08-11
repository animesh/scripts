#!/usr/bin/perl
system "ls -1>tempfile.perl";
open F,"tempfile.perl";
while ($l=<F>)
{
chomp $l;
push(@NAMES,$l);
}
foreach $n (@NAMES)
{
$nn=$n;
if($n =~ /^E/)
{
rename "myfile.txt","trash/myfile.txt";
$n =~ s/E//;
rename "$nn","$n";
print "$nn\t$n\n";
}
}
unlink "tempfile.perl";

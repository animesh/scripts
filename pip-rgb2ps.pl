#!/usr/local/bin/perl -w

while (<>)
{
    next if /^\s*$/;
    next if /^\s*#/;
    /^\s*(\w+)\s+(\w+)\s+([.\d]+)\s+([.\d]+)\s+([.\d]+)\s*$/ or die;
    my $color = sprintf("%-11s",$1);
    my $space = $2 eq "rgbi" ? "setrgbcolor" : "sethsbcolor";
    my $x = sprintf("%.2f", $3);
    my $y = sprintf("%.2f", $4);
    my $z = sprintf("%.2f", $5);
    print "/$color  { $x $y $z $space } def\n";
}

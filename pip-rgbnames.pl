#!/usr/local/bin/perl -w

while (<>)
{
    next if /^\s*$/;
    next if /^\s*#/;
    /^\s*(\w+)\s+(\w+)\s+([.\d]+)\s+([.\d]+)\s+([.\d]+)\s*$/ or die;
    printf "%s\n", $1;
}

#!/usr/local/bin/perl
if (@ARGV) { exit 1 unless -f $ARGV[0]; }
$_=<>;
exit ($_ == 0);

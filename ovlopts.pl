#!/usr/bin/env perl
use strict;
my @bat = (
"0000000001",
);
my @job = (
"h0000000001r0000000000",
);
my @opt = (
"-h 1-2241  -r 0-2241",
);
my $idx = int($ARGV[1]) - 1;
if      ($ARGV[0] eq "bat") {
    print "$bat[$idx]";
} elsif ($ARGV[0] eq "job") {
    print "$job[$idx]";
} elsif ($ARGV[0] eq "opt") {
    print "$opt[$idx]";
} else {
    print STDOUT "Got '$ARGV[0]' and don't know what to do!\n";
    print STDERR "Got '$ARGV[0]' and don't know what to do!\n";
    die;
}
exit(0);

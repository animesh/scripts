#!/usr/bin/perl -w

##############################
#
# This script prints out a single line of random ACG and T
# The number of bases supplied on command line
#
#############################

$count=$ARGV[0];

@bases =index.html qw( A   C   G   T );

print $bases[rand 4] while ($count--);
print "\n";

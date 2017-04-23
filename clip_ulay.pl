#!/usr/local/bin/perl -w
die "usage: lo hi\n" unless $#ARGV > 0;
my $lo = shift @ARGV;
my $hi = shift @ARGV;

sub min { return ($_[0] < $_[1]) ? $_[0] : $_[1]; }
sub max { return ($_[0] > $_[1]) ? $_[0] : $_[1]; }

while (<>) {
  if (/^(\s*)(\d+)(\s+)(\d+)(\s+.*)(Under|Block)(.*)$/s) {
    if (($2 <= $hi) && ($lo <= $4)) {
	my $a = max($2,$lo);
	my $b = min($4,$hi);
	print "$1$a$3$b$5$6$7";
    }
  } else {
    print;
  }
}

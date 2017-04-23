#!/usr/local/bin/perl -w
# group tag lines by row, optimizing setrow invocations

my $row = -1;
my %rows;

while (<>) {
    if (/^\s*((-|\d|\.)*\d+)\s+setrow/) {
	$row = $1;
	next;
    }
    $rows{$row} .= $_;
}

my($key, $val);
for $key (sort {$a <=> $b} keys %rows) {
    $val = $rows{$key};
    unless ($val =~ /^\s+$/) {
	print "$key setrow\n" unless $key == -1;
	print $val;
    }
}

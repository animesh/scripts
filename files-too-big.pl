#!/usr/local/bin/perl -w
my $default = 4_000_000;
my $max = $default;
my $n = 0;

my $piphome = $ENV{'PIPHOME'} || "";
if (open(F, "$piphome/etc/mailmax")) {
    $max = <F>;
    chomp $max;
    close F;
}

$max = $default unless $max =~ /\d+/;
foreach $f (@ARGV) { $n += ((stat($f))[7] || 0); }
exit ($n < $max);

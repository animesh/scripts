#!/usr/local/bin/perl -ws
# generate bookmarks from an ordered list of exons

use 5.006_000;
use warnings;
use strict;

# options: $::a  $::z
$::a = 0 unless defined $::a;
$::b = 0 unless defined $::b;

sub quote_for_ps {
    die unless (@_);
    for (@_) {
        $_ ||= "";
        s/[[:space:]]/ /g;
        s/[^[:print:]]/_/g;
        s/([[:punct:]])/\\$1/g;
    }
    return @_;
}

my @G = ();
my $e = undef;
my $g = undef;
while (<>) {
    if (/^\s*([<>])\s*(\d+)\s+(\d+)(\s*(.*)\s*)?$/) {
	#print STDERR "gene: $1; $2; $3; $5.\n";
	$e = [];
	$g = [[$2,$3,$5],$e];
	push(@G, $g);
    } elsif (/^\s*(\+)\s*(\d+)\s+(\d+)(\s*(.*)\s*)?$/) {
	#print STDERR "cds: $1; $2; $3; $5.\n";
    } elsif (/^\s*(\d+)\s+(\d+)(\s*(.*)\s*)?$/) {
	#print STDERR "exon: $1; $2;$3.\n";
	push(@$e, [$1,$2]);
    }
}

my $ngene = $#G+1;
if ($ngene > 0) {
    # XXX - DOCVIEW here only works if nothing else tries to set PageMode
    print  "[/PageMode /UseOutlines /DOCVIEW pdfmark\n";
    printf "[/Title (genes) /Count %d /OUT pdfmark\n", $ngene;
}
GENE: foreach my $gene (@G) {
    my ($a,$b,$g) = @{$gene->[0]};
    #print STDERR "gene: $a $b $g\n";
    my @E = @{$gene->[1]};
    my $gtitle = $g;
    #my $gdest = "gene.$a.$b"; # XXX -- this convention known elsewhere!
    my $gdest = "gene.$g"; # XXX -- this convention known elsewhere!

    if ($::a != 0 && $::z != 0) {
	next GENE unless ($a <= $::z && $::a <= $b);
    }

    quote_for_ps $gtitle;
    quote_for_ps $gdest;
    printf "[/Title (%s) /Dest (%s) cvn /Count %d /OUT pdfmark\n",
	$gtitle, $gdest, -($#E+1);
    for my $exon (@E) {
	my $a = $exon->[0];
	my $b = $exon->[1];
	my $d = "exon.$a.$b"; # XXX -- this convention known elsewhere!
	print "[/Title ($a $b) /Dest ($d) cvn /OUT pdfmark\n";
    }
}

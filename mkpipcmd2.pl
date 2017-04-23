#!/usr/local/bin/perl -w
# -- make pip-generating commands for blastz alignments

use 5.006_000;
use strict;
use warnings;

use subs qw(
	get_seqlen
);

my $PAGE_INCHES       = 8.0;
my $PAGE_WIDTH        = $PAGE_INCHES * 72;
my $ELT_HEIGHT_INCHES = 0.8;
my $ELT_HEIGHT        = $ELT_HEIGHT_INCHES * 72;

my $ELT_WIDTH = 20_000; # bp

my $TMP             = '.';
my $CLIPPED_ALIGN   = "$TMP/pip_clip_align";
my $CLIPPED_TAGS    = "$TMP/pip_clip_tags";
my $CLIPPED_ULAY    = "$TMP/pip_clip_ulay";
my $CLIP_ALIGN_PROG = 'clip_align';
my $CLIP_TAG_PROG   = 'clip_tag';
my $CLIP_ULAY_PROG  = 'clip_ulay';
my $EPS_NAME        = 'eps';

my $four_lines = 0;

if ($#ARGV == 4 && $ARGV[4] eq '4lines') {
	$four_lines = 1;
	pop(@ARGV);
}

if ($#ARGV != 3) {
	die "usage: $0 alignment header_file tag_file underlay_file [4lines]\n";
}

my $alignment     = $ARGV[0];
my $header        = $ARGV[1];
my $tag_file      = $ARGV[2];
my $underlay_file = $ARGV[3];

my $bp_on_page = ($four_lines ? 4 : 5) * $ELT_WIDTH;
my $to = get_seqlen($alignment);
my ($begin, $end, $y, $n, $page);
my $PPI = $ELT_WIDTH/$PAGE_INCHES;
my $Y100 = int(0.5 + $PPI * $ELT_HEIGHT_INCHES * 1.5);
my $Y50  = int(0.5 + $Y100 * 0.5);

$page = $n = 0;

for ($begin = 0; $begin < $to; $begin = $end) {
	if ($begin % $bp_on_page == 0) {
		$y = 6.0;
	}
	$end = $begin + $ELT_WIDTH;
	if ($end > $to) {
		$end = $to;
	}

	printf("%s %s %d %d >%s\n",
		$CLIP_ALIGN_PROG, $alignment, $begin, $end, $CLIPPED_ALIGN);
	printf("%s %s %d %d >%s\n",
		$CLIP_TAG_PROG, $tag_file, $begin, $end, $CLIPPED_TAGS);
	printf("%s %d %d <%s >%s\n",
		$CLIP_ULAY_PROG, $begin, $end, $underlay_file, $CLIPPED_ULAY);

	printf("pmps -Y %d -w 1 -align %s", $Y100, $CLIPPED_ALIGN);
	printf(" -utag %s", $CLIPPED_ULAY);
	printf(" -htag %s", $CLIPPED_TAGS);
	printf(" -dot -nb");
	printf(" -ppi=%d", $PPI);
	printf(" -vt=25 -ht=1000 -tl=2000 -landscape");
	printf(" -noprocset");
	printf(" -strictlabels -percent");
	printf(" -ticfontsize=9 -labelfontsize=10 -bannerfontsize=11");
	printf(" -y=%3.1f %d %d %d %d", $y, $begin, $end, $Y50, $Y100);
	printf(" > %s.%05d.%05d\n", $EPS_NAME, $page, $n);

	$y -= ($four_lines ? 2.0 : 1.5);
	$n += 1;
	if ($end < $to && ($end % $bp_on_page) == 0) {
		$page += 1;
	}
}


sub get_seqlen
{
	my $path = shift;
	open(SF, '<', $path) or die "$! ($path)";
    
	while (<SF>) {
		next unless (/^s \{/);
		last unless defined($_ = <SF>);
		return $3 if (/\s*("[^"]*")\s+(\d+)\s+(\d+)/);
		# XXX $3 <= 0?
	}
	close SF;
	die("could not find sequence length in alignment file.");
}

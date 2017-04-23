#!/usr/local/bin/perl
# synthesize a postscript string for the title from the 
# title file and the exons file.
#
# mktitle expects just the interior of the string,
# so don't print enclosing parens or trailing newline.
#
# usage: title exons
#
use 5.6.0;
use strict;
use warnings;

sub quote_for_ps {
    die unless (@_);
    for (@_) {
        $_ ||= "";
        s/[^[:print:]]/_/g;
        s/([[:punct:]])/\\$1/g;
    }
    return @_;
}

sub emit {
    print join("", @_);
}

if (defined($ARGV[0]) && open(F,'<',$ARGV[0])) {
    my $title = join(" ", <F>);
    close(F);
    if (defined($title) && $title !~ /^\s*$/) {
	emit quote_for_ps($title);
	exit 0;
    }
}

if (defined($ARGV[1]) && open(F,'<',$ARGV[1])) {
    my $title = <F>;
    close(F);
    if (defined($title) && $title !~ /^\s*$/) {
	emit quote_for_ps($title);
	exit 0;
    }
}

emit "Percent Identity Plot";
exit 0;

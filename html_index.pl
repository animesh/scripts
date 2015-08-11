#!/usr/bin/perl -w

# jkb 12/12/95
# Usage: html_index.pl DOCUMENT_toc.html

# Builds $ARGV.index Their use is as follows:
#
# $ARGV.index contains a mapping of node names to urls. The show_help Tcl
# command reads this file.

#$last = "";
#@sub = ();

$name = $ARGV[0];
$name =~ s/_toc.html//;
open(INDEX, "> $name.index") || die "Couldn't create $name.index";

print INDEX "{Contents} ${name}_toc.html\n";

#$"=":";
while (<ARGV>) {
#    if (/<UL>/) {
#	push(@sub, $last) if ($last ne "");
#    }
#
#    if (/<\/UL>/) {
#	pop(@sub);
#    }

    s/<CODE>(.*)<\/CODE>/$1/;
    if (/NODE:(.*) -->.*SEC.*HREF="(.*)">([^<]*)/) {
	print INDEX "{$1} $2\n";
#	if ($#sub>=0) {
#	    print INDEX "{@sub:$3} $2\n";
#	} else {
#	    print INDEX "{$3} $2\n";
#	}
#	$last=$3;
    }
}

close(INDEX);

#!/usr/bin/perl -w
#-- Dirty script to pull out desired quality score tables

if ( scalar(@ARGV) != 1 ) {
    die "USAGE: $0 <quality file>  <  <seq name list>\n";
}
$qualfile = $ARGV[0];

open (QUAL_INPUT, "<$qualfile")
    or die "ERROR: couldn't open qual file $!\n";

%tag_hash = ( );
while ( <QUAL_INPUT> ) {
    if ( /^>/ ) {
	($tag) = /^>(\S+)/;
	$tag_hash{$tag} = tell QUAL_INPUT;
    }
}

while ( <STDIN> ) {
    $tag = $_;
    chomp $tag;

    $seek = $tag_hash{$tag};
    if ( !defined($seek) ) {
	die "ERROR: could not find sequence for $tag\n";
    }

    seek QUAL_INPUT, $seek, 0;
    print ">$tag\n";

    while ( <QUAL_INPUT> ) {
	$line = $_;

	if ( $line =~ /^>/ ) {
	    last;
	} else {
	    print $line;
	}
    }
}

close (QUAL_INPUT)
    or die "ERROR: couldn't close qual file $!\n";

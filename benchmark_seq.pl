#!/usr/local/bin/perl -w
#- Dirty script to pull out and format sequences for web release

use strict;
use TIGR::Foundation;
use TIGR::FASTAreader;
use TIGR::FASTArecord;

my $tigr = undef;
my $err = undef;

my $fastafilename = undef;
my $libfilename = undef;
my $listfilename = undef;

my $fasta_reader = undef;
my @list = ( );

$tigr = new TIGR::Foundation;
if ( !defined ($tigr) ) {
    print (STDERR "ERROR: TIGR::Foundation could not be initialized");
    exit (1);
}

if ( scalar(@ARGV) != 3 ) {
    print (STDERR "USAGE: $0  <taglist>  <lib map>  <fasta>\n");
    exit (1);
}


$listfilename = $ARGV[0];
$libfilename = $ARGV[1];
$fastafilename = $ARGV[2];


open (LIST_INPUT, "<$listfilename")
    or die "ERROR: Could not open $listfilename $!\n";
while ( <LIST_INPUT> ) {
    chomp $_;
    
    if ( !/^\S+\s[+-]$/  &&  !/^\S+$/ ) {
	print (STDERR "ERROR: Could not parse $listfilename\n");
	print (STDERR "       \"$_\"\n");
	exit (1);
    }
    push @list, $_;
}
close (LIST_INPUT)
    or die "ERROR: Could not close $listfilename $!\n";

my %libhash;
my %version_hash = (
		    "B" => 2,
		    "C" => 3,
		    "D" => 4,
		    "E" => 5,
		    "F" => 6,
		    "G" => 7,
		    );

my $lib_id;
my $lib_uid;
my $version;
my $clone_id;
my $clearl;
my $clearr;
my $dir;

open (MAP_INPUT, "<$libfilename")
    or die "ERROR: Could not open $libfilename $!\n";
while ( <MAP_INPUT> ) {
    ($lib_id, $lib_uid) = split;
    $libhash{$lib_id} = $lib_uid;
}
close (MAP_INPUT)
    or die "ERROR: Could not close $libfilename $!\n";

$fasta_reader = new TIGR::FASTAreader $tigr;
$fasta_reader->open($fastafilename)
    or die "ERROR: Could not open $fastafilename $!\n";

my $line = undef;
foreach $line (@list) {
    my $fasta_record = undef;
    my $identifier = undef;

    ($identifier) = $line =~ /^(\S+)/;

    $fasta_record = $fasta_reader->getRecordByIdentifier($identifier);

    if ( !defined ($fasta_record) ) {
	print (STDERR "ERROR: Could not find \"$identifier\"\n");
	exit (1);
    }

    my $sequence = undef;
    $sequence = $fasta_record->getData( );

    if ( !defined ($sequence) ) {
	print (STDERR "ERROR: Sequence for \"$identifier\" is not valid\n");
	exit (1);
    }

    $lib_id = undef;
    $lib_uid = undef;
    $version = undef;
    $clone_id = undef;
    $clearl = undef;
    $clearr = undef;
    $dir = undef;

    if ( length($identifier) < 7 ) {
	die "ERROR: invalid identifier $identifier\n";
    }
    $lib_id = substr($identifier, 0, 4);
    $lib_uid = $libhash{$lib_id};
    if ( !defined($lib_uid) ) {
	print STDERR "WARNING: unknown library $lib_id, ignoring sequence\n";
	next;
    }
    $clone_id = substr($identifier, 0, 7);
    if ( $identifier =~ /([FRNS])([B-G]?)$/ ) {
	($dir, $version) = $identifier =~ /([FRNS])([B-G]?)$/;
	if ( defined($dir)  &&  $dir ne "" ) {
	    if ( $dir eq "N" ) {
		$dir = "F";
	    } elsif ( $dir eq "S" ) {
		$dir = "R";
	    }
	} else {
	    die "ERROR: missing direction\n";
	}
	if ( defined($version)  &&  $version ne "" ) {
	    $version = $version_hash{$version};
	} else {
	    $version = "1";
	}
    } else {
	$dir = "W";
	$version = "1";
    }
    my $header = $fasta_record->getHeader( );
    ($clearl, $clearr) = $header =~ /(\S+)\s+(\S+)$/;
    if ( !($clearl =~ /^\d+$/)  ||  !($clearr =~ /^\d+$/)  ||
	 $clearl < 0  ||  $clearr < 0 ) {
	die "ERROR: invalid clear range ($clearl) ($clearr)\n";
    }

    if ( !defined($lib_uid) || !defined($dir)  ||
	 !defined($version) || !defined($clone_id) ||
	 !defined($clearl) || !defined($clearr) ) {
	die "ERROR: missing header data\n" .
         ">$identifier\t$lib_uid\t$clone_id\t$dir$version\t$clearl\t$clearr\n";
    }

    print
	">$identifier\t$lib_uid\t$clone_id\t$dir$version\t$clearl\t$clearr\n";
    my $seg = undef;
    while ( (defined ($seg = substr $sequence, 0, 60,''))  &&
	    ($seg ne '')) {
	print "$seg\n";
    }
}

$fasta_reader->close( )
    or die "ERROR: Could not close $fastafilename $!\n";

#-- end of script

#!/usr/local/bin/perl

use AMOS::AmosLib;
use TIGR::Foundation;

use strict;

my $VERSION = '$Revision: 1.6 $ ';
my $HELP = q~
    amos2mates [-i infile] [-o outfile] 

    if -i and -o are not provided reads from STDIN and writes to STDOUT
    if -i is provided but -o is not, outfile is same as infile except for the
  extension
    otherwise -i and -o are those specified in the command line
    if -i is provided the filename must end in .afg
~;

my $base = new TIGR::Foundation();
if (! defined $base) {
    die("A horrible death\n");
}


$base->setVersionInfo($VERSION);
$base->setHelpInfo($HELP);

my $infile;
my $outfile;
my $inname = "stdin";
my $accession = 1;
my $date = time();
my $firstunv = 1;
my %libids;
my %frg2lib;
my %rd2lib;
my %rdids;
my %mates;

my $err = $base->TIGR_GetOptions("i=s"   => \$infile,
				 "o=s"   => \$outfile);



# if infile is provided, make sure it ends in .afg and open it
if (defined $infile){
    if ($infile !~ /\.afg$/){
	$base->bail ("Input file name must end in .afg");
    }
    $inname = $infile;
    open(STDIN, $infile) || $base->bail("Cannot open $infile: $!\n");
}

# if infile is provided but outfile isn't make outfile by changing the extension
if (! defined $outfile && defined $infile){
    $outfile = $infile;
    $outfile =~ s/(.*)\.afg$/\1.mates/;
}

# if outfile is provided (or computed above) simply open it
if (defined $outfile){
    open(STDOUT, ">$outfile") || $base->bail("Cannot open $outfile: $!\n");
}

while (my $record = getRecord(\*STDIN)){
    my ($type, $fields, $recs) = parseRecord($record);

    if ($type eq "LIB"){
	# only use the first DST record  
	if ($#$recs < 0){
	    $base->bail("LIB record doesn't have any DST record at or around line $. in input");
	}
        my ($sid, $sfs, $srecs) = parseRecord($$recs[0]);
	if ($sid ne "DST"){
	    $base->bail("LIB record doesn't start with DST record at or around line $. in input");
	}
	my $min = int($$sfs{mea} - 3 * $$sfs{std});
	my $max = int($$sfs{mea} + 3 * $$sfs{std});
	$min = 0 if $min < 0;
	
	print "library\t$$fields{iid}\t$min\t$max\n";
    } # type is LIB
    
    if ($type eq "FRG"){
	$frg2lib{$$fields{"iid"}} = $$fields{"lib"};
        if ( exists $$fields{"rds"} ) {
            $$fields{"rds"} =~ /^(\d+),(\d+)/;
            $mates{$1} = $2;
        }
    } # type is FRG

    if ($type eq "RED"){
	$rd2lib{$$fields{"iid"}} = $frg2lib{$$fields{"frg"}};
	
	my $seqname;
	if ( defined $$fields{eid} ) {
	    $seqname = $$fields{eid};
	} else {
	    $seqname = $$fields{iid};
	}

	$rdids{$$fields{"iid"}} = $seqname;
    } # type is RED
} # while each record

foreach my $rd1 ( keys %mates ) {
    my $rd2 = $mates{$rd1};
    if ($rd2lib{$rd1} != $rd2lib{$rd1}){
        $base->bail("Reads $rd1 and $rd2 don't appear to map to the same library ($rd2lib{$rd1} != $rd2lib{$rd2})");
    }
    print "$rdids{$rd1}\t$rdids{$rd2}\t$rd2lib{$rd1}\n";
} # for each mate

exit(0);

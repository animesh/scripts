#!/usr/local/bin/perl

use AMOS::AmosLib;
use TIGR::Foundation;

use strict;

my $VERSION = '$Revision: 1.5 $ ';
my $HELP = q~
    amos2sq [-i] infile [-o outprefix]

    infile must end in .afg
    outputs will be placed in outprefix.seq and outprefix.qual
    if -o is not specified, outprefix is infile stripped of .afg
~;

my $base = new TIGR::Foundation();
if (! defined $base) {
    die("A horrible death\n");
}


$base->setVersionInfo($VERSION);
$base->setHelpInfo($HELP);

my $infile;
my $outprefix;
my %libinfo;
my %frg2lib;

my $err = $base->TIGR_GetOptions("i=s"   => \$infile,
				 "o=s"   => \$outprefix);



# if infile is provided, make sure it ends in .afg and open it
if (!defined $infile){
    $infile = $ARGV[0];
}

if (! defined $infile){
    $base->bail ("You must supply an input file");
}
 
if ($infile !~ /\.afg$/){
    $base->bail ("Input file name must end in .afg");
}
if (! defined $outprefix){
    $outprefix = $infile;
    $outprefix =~ s/.afg$//;
}
open(IN, $infile) || $base->bail("Cannot open $infile: $!\n");


# if infile is provided but outfile isn't make outfile by changing the extension
open(SEQ, ">$outprefix.seq") || $base->bail("Cannot open $outprefix.seq :$!\n");
open(QUAL, ">$outprefix.qual") || $base->bail("Cannot open $outprefix.qual: $!\n");

while (my $record = getRecord(\*IN)){
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
	my $med = int($$sfs{mea});
	my $min = int($$sfs{mea} - 3 * $$sfs{std});
	my $max = int($$sfs{mea} + 3 * $$sfs{std});
	$min = 0 if $min < 0;

	$libinfo{$$fields{iid}} = "$min $max $med";

    } # type is LIB
    
    if ($type eq "FRG"){
	$frg2lib{$$fields{"iid"}} = $$fields{"lib"};
    } # type is FRG

    if ($type eq "RED"){
	my @lines;
	@lines = split('\n', $$fields{seq});
	my $sequence = join('', @lines);
	@lines = split('\n', $$fields{qlt});
	my $qualities = join('', @lines);

	my $seqname;
	if ( defined $$fields{eid} ) {
	    $seqname = $$fields{eid};
	} else {
	    $seqname = $$fields{iid};
	}

	my ($cll, $clr) = split(',', $$fields{clr});
	$cll++; # TIGRize coordinates

	my $quals = sprintf("%02d", ord(substr($qualities, 0, 1)) - ord('0'));
	for (my $c = 1; $c < length($qualities); $c++){
	    $quals .= sprintf(" %02d", ord(substr($qualities, $c, 1)) - ord('0'));
	}
	printFastaSequence(\*SEQ, "$seqname $libinfo{$frg2lib{$$fields{frg}}} $cll $clr", uc($sequence));
	printFastaQual(\*QUAL, "$seqname", $quals);
    } # type is RED
} # while each record

close(IN);
close(SEQ);
close(QUAL);

exit(0);

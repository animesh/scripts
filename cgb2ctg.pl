#!/usr/local/bin/perl

use AMOS::AmosLib;
use TIGR::Foundation;

use strict;

my $VERSION = '$Revision: 1.4 $ ';
my $HELP = q~
    cgb2ctg [-i infile] [-o outfile] -f frgfile

    if -i and -o are not provided reads from STDIN and writes to STDOUT
    if -i is provided but -o is not, outfile is same as infile except for the
  extension
    otherwise -i and -o are those specified in the command line
    if -i is provided the filename must end in .cgb
~;

my $base = new TIGR::Foundation();
if (! defined $base) {
    die("A horrible death\n");
}


$base->setVersionInfo($VERSION);
$base->setHelpInfo($HELP);

my $infile;
my $outfile;
my $frgfile;
my %clears;
my $uidmap;

my $err = $base->TIGR_GetOptions("i=s"   => \$infile,
				 "o=s"   => \$outfile,
				 "f=s"   => \$frgfile,
				 "map=s" => \$uidmap);



# if infile is provided, make sure it ends in .afg and open it
if (defined $infile){
    if ($infile !~ /\.cgb$/){
	$base->bail ("Input file name must end in .afg");
    }
    open(STDIN, $infile) || $base->bail("Cannot open $infile: $!\n");
}

# if infile is provided but outfile isn't make outfile by changing the extension
if (! defined $outfile && defined $infile){
    $outfile = $infile;
    $outfile =~ s/(.*)\.cgb$/\1.ctg/;
}

# if outfile is provided (or computed above) simply open it
if (defined $outfile){
    open(STDOUT, ">$outfile") || $base->bail("Cannot open $outfile: $!\n");
}

if (defined $uidmap){
    open(UID, ">$uidmap") || $base->bail("Cannot open $uidmap: $!\n");
}

if (defined $frgfile){
    open(FRG, $frgfile) || $base->bail("CAnnot open $frgfile: $!\n");
    while (my $record = getRecord(\*FRG)){
	my ($type, $fields, $recs) = parseRecord($record);
	if ($type eq "FRG"){
	    my $id = $$fields{acc};
	    my @lines = split('\n', $$fields{src});
	    my $seqname = join('', @lines);
	    if ($seqname =~ /^\s*$/){
		$seqname = $$fields{acc};
	    }
	    $clears{$seqname} = $$fields{clr};
	}
    }
    close(FRG);
}

while (my $record = getRecord(\*STDIN)){
    my ($type, $fields, $recs) = parseRecord($record);
    if ($type eq "IUM"){
	print "##$$fields{acc} $$fields{nfr} $$fields{len} bases\n";
    }
    for (my $r = 0; $r <= $#$recs; $r++){
	my ($sid, $sfs, $srecs) = parseRecord($$recs[$r]);
	if ($sid eq "IMP"){
	    my $id = $$sfs{mid};
	    my @lines = split('\n', $$sfs{src});
	    my $seqname = $lines[0];
	    my $cll; my $clr;
	    my ($asml, $asmr) = split(',', $$sfs{pos});
	    if (defined $uidmap){
		print UID "$seqname $id\n";
	    }
	    if (exists $clears{$seqname}){
		($cll, $clr) = split(',', $clears{$seqname});
	    } else {
		$cll = ($asml < $asmr) ? $asml : $asmr;
		$clr = ($asml > $asmr) ? $asml : $asmr;
	    }

	    my $len = $clr - $cll;
	    if ($asml > $asmr){
		my $tmp = $asml;
		$asml = $asmr;
		$asmr = $tmp;
		$tmp = $cll;
		$cll = $clr;
		$clr = $tmp;
	    }
	    my $off = $asml;

	    printf("#%s(%d) %d bases {%d %d} <%d %d>\n", $seqname, $off, $len, $cll, $clr, $asml, $asmr);
	}# if IMP
    }# if IUM
} # for each record

if (defined $uidmap){
    close(UID);
}

exit(0);

#!/usr/local/bin/perl

use POSIX qw(strftime);
use TIGR::Foundation;
use AMOS::AmosLib;

my $VERSION = '$Revision: 1.5 $';
my $HELPTEXT = "ctgovl -o <ovlfile> (-c <ctgfile> | -a <asmfile>) [-x <xmlfile>]";

my $base = new TIGR::Foundation;

if (! defined $base){
    die("Walk, do not run, to the nearest Exit!\n");
}

$base->setHelpInfo($HELPTEXT);
$base->setVersionInfo($VERSION);



my $ctgfile;
my $ovlfile;
my $frgfile;
my $xmlfile;
my $uidmap;

my $err = $base->TIGR_GetOptions("c=s" => \$ctgfile,
				 "o=s" => \$ovlfile,
				 "a=s" => \$asmfile,
				 "x=s" => \$xmlfile,
				 "map=s" => \$uidmap);

my $contig;
my %readctg;
my %readlen;
my $contiglen = 0;
my %contiglen;
my %uid2iid;
my $linkid = 1;

if (defined $uidmap){
    open(UID, $uidmap) || $base->bail("Cannot open $uidmap: $!\n");
    while (<UID>){
	chomp;
	my ($name, $id) = split(' ', $_);
	$uid2iid{$name} = $id;
    }
    close(UID);
}

if (defined $asmfile){
    print STDERR "Doing $asmfile\n";
    open(ASM, $asmfile) || $base->bail("Cannot open $asmfile: $!\n");

    while ($record = getRecord(\*ASM)){
        my ($type, $fields, $recs) = parseRecord($record);
        if ($type eq "AFG"){
            my $ids = $$fields{acc};
	    $ids =~ /\((\d+),(\d+)\)/;
	    $uid2iid{$1} = $2;
	}
	if ($type eq "CCO"){
	    my $contig = getCAId($$fields{acc});
	    $contiglen{$contig} = $$fields{len};
	    for (my $i = 0; $i <= $#$recs; $i++){
		my ($sid, $sfs, $srecs) = parseRecord($$recs[$i]);
		if ($sid eq "MPS"){
		    my ($asml, $asmr) = split(',', $$sfs{"pos"});
		    $readctg{$uid2iid{$$sfs{"mid"}}} = "$contig,$asml,$asmr";
		}
	    }
	}
    }
    close(ASM);
}


if (defined $ctgfile){
    open(CTG, "$ctgfile") || die ("Cannot open $ctgfile: $!\n");
    
    while (<CTG>){
	chomp;
	if (/^C (\d+)/){
	    if ($contiglen != 0){
		$contiglen{$contig} = $contiglen;
	    }
	    $contig = $1;
	    $contiglen = 0;
	    next;
	}
	if (/\#\#(\S+) (\d+) (\d+)/){
	    $contig = $1;
	    $contiglen{$contig} = $3;
	}
	if (/(\d+) (\d+) (\d+)/){
	    if ($contiglen < $2) {$contiglen = $2;}
	    if ($contiglen < $3) {$contiglen = $3;}
	    $readctg{$1} .= "$contig,$2,$3 ";
	    if (! exists $readlen{$1}){
		$readlen{$1} = abs($2 - $3);
	    } else {
		if ($readlen{$1} != abs($2 - $3)){
		    print STDERR "Already saw read $1 (", abs($2 - $3), ") but with length $readlen{$1}\n";
		}
	    }
	}
	if (/\#(\S+)\((\d+)\).*\{(\d+) (\d+)\} <(\d+) (\d+)>/){
	    my $id = $uid2iid{$1};
	    $readctg{$id} .= "$contig,";
	    if ($3 < $4){
		$readctg{$id} .= "$5,$6 ";
	    } else {
		$readctg{$id} .= "$6,$5 ";
	    }
	}
    }
    
    if ($contiglen != 0){
	$contiglen{$contig} = $contiglen;
    }
    
    close(CTG);
}

if (defined $xmlfile){
    open(XML, ">$xmlfile") || $base->bail("Cannot open $xmlfile: $!\n");
    print XML "<?xml version = \"1.0\" ?>\n";
    print XML "<EVIDENCE ID = \"olap2ovl\"\n";
    print XML "        DATE = \"" . (strftime "%a %b %e %H:%M:%S %Y", gmtime) . "\"\n";
    print XML "     PROJECT = \"$ovlfile\"\n";
    print XML "  PARAMETERS = \"". join(" ", @ARGV) . "\">\n";

    while (my ($ctg, $len) = each %contiglen){
	print XML "    <CONTIG ID = \"contig_$ctg\" NAME = \"$ctg\" LEN = \"$len\"/>\n";
    }
}

open(OVL, "$ovlfile") || die ("Cannot open $ovlfile: $!\n");

while (<OVL>){
    chomp;
    
    if (/\s*(\d+)\s*(\d+) ([IN])\s*(-?\d+)\s*(-?\d+)/){
	my $rdA = $1;
	my $rdB = $2;
	my $ori = $3;
	my $Ahang = $4;
	my $Bhang = $5;

	if (! exists $readctg{$rdA} || ! exists $readctg{$rdB}){
	    # no need to worry.  
	    next;
	}
	my @ctgA = split(' ', $readctg{$rdA});
	my @ctgB = split(' ', $readctg{$rdB});

	for (my $i = 0; $i <= $#ctgA; $i++){
	    for (my $j = 0; $j <= $#ctgB; $j++){
		my ($ctgA, $la, $ra) = split(',', $ctgA[$i]);
		my ($ctgB, $lb, $rb) = split(',', $ctgB[$j]);
		if ($ctgA == $ctgB){
		    next; # no need to look at these
		}
		$pair{"$ctgA $ctgB"} .= "$rdA,$rdB,$ori,$Ahang,$Bhang,$la,$ra,$lb,$rb ";
	    }
	}
    }
}
close(OVL);

my %seenpair;
while (my ($pair, $evidence) = each %pair){
    my ($ctgA, $ctgB) = split(' ', $pair);
    my $ohangA;
    my $ohangB;

    my @evs = split(' ', $pair{$pair});

    print "$ctgA($contiglen{$ctgA}) $ctgB($contiglen{$ctgB})\n";
    for (my $i = 0; $i <= $#evs; $i++){
	print "\t$evs[$i]  \t";
	my @fields = split(',', $evs[$i]);

	my $da;
	my $db = $fields[3];
	my $dc;
	my $dap;
	my $dbp = $fields[4];
	my $dcp;

# here's the situation
#
#     ctgA       =======================================
#                                    da'
#  and the read    da  -------->db'
# second read           db <------- dc'
#                     dc
#    ctgB          ==============================
#
#
# ohangA is da + db - dc where da is offset in first contig, db is the overhang
# for the beginning of the read, and dc is the offset in the second contig
#
# Similarly ohangB is db' + dc' - da'

	my $aori; my $bori;
	
	if ($fields[5] < $fields[6]){
	    print "> ";
	    $aori = ">";
	    $da = $fields[5];
	    $dap = $contiglen{$ctgA} - $fields[6];
	} else {
	    print "< ";
	    $aori = "<";
	    $da = $contiglen{$ctgA} - $fields[5];
	    $dap = $fields[6];
	}
	if ($fields[7] < $fields[8]) {
	    $bori = (($fields[2] eq "N") ? ">" : "<");
	    print "$bori ";
	    $dc = (($fields[2] eq "N") ? $fields[7] : $contiglen{$ctgB} - $fields[8]);
	    $dcp = (($fields[2] eq "N") ? $contiglen{$ctgB} - $fields[8] : $fields[7]);
	} else {
	    $bori = (($fields[2] eq "N") ? "<" : ">");
	    print "$bori ";
	    $dc = (($fields[2] eq "N") ? $contiglen{$ctgB} - $fields[7] : $fields[8]);
	    $dcp = (($fields[2] eq "N") ? $fields[8] : $contiglen{$ctgB} - $fields[7]);
	}

	$ohangA = $da + $db - $dc;
	$ohangB = $dbp + $dcp - $dap;

	if ($aori eq $bori){
	    $type = "N";
	} else {
	    $type = "I";
	}
	print "    ";

	if ($aori eq "<") {
	    $aori = ">";
	    if ($bori eq ">") {$bori = "<";} else {$bori = ">"}
	    my $tmp = $ohangA;
	    $ohangA = -$ohangB;
	    $ohangB = -$tmp;
	} 
	print "$aori $bori $ohangA $ohangB\n";
	
    }

    if (defined $xmlfile && ! exists $seenpair{"$ctgA $ctgB"} && ! exists $seenpair{"$ctgB $ctgA"}){
	my $lnksize = $contiglen{$ctgA} - $ohangA;
	my $oriB = ($bori eq ">") ? "BE" : "EB";
	print XML "    <OVL ID = \"ovl_$linkid\">\n";
	print XML "        <CONTIG ID = \"contig_$ctgA\" ORI = \"BE\" HANG=\"$ohangA\"/>\n";
	print XML "        <CONTIG ID = \"contig_$ctgB\" ORI = \"$oriB\" HANG=\"$ohangB\"/>\n";
	print XML "    </OVL>\n";
	$linkid++;
	$seenpair{"$ctgA $ctgB"} = 1;
    }
    print "\n";
}

if (defined $xmlfile){
    print XML "</EVIDENCE>\n";
    close(XML);
}

exit(0);

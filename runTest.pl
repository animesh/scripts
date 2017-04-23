#!/usr/local/bin/perl

# this program generates Celera Assembler test data and then runs
# the assembler on it.

use TIGR::Foundation;
use strict;

my $MY_VERSION = " Version 1.0 (Build " . (qw/$Revision: 1.2 $/ )[1] . ")";
my $MY_HELPTEXT = qq~
    runTest
~;


########## Main

my $base = new TIGR::Foundation;

if (! defined $base){
    print STDERR "Nasty error, hide!\n";
    exit(1);
}

$base->setDebugLevel(1);

$base->setHelpInfo($MY_HELPTEXT);
$base->setVersionInfo($MY_VERSION);
my $asRoot = "/local/asmg/bin/CA"; #$ENV{CA_ROOT};
$base->addDependInfo($asRoot);
$ENV{"AS_ROOT"} = $asRoot;  # set environment for Celera programs

my $asBin = "$ENV{CA_ROOT}/bin";
if (! -e "bin"){
    symlink($asBin, "bin") || 
	$base->bail("Cannot symlink \"$asBin\" to \"./bin\": $!");
}

my $celsim = "$asRoot/bin/celsim";
$base->addDependInfo($celsim);
my $assembler = "$ENV{CA_ROOT}/scripts/assembler.pl";
$base->addDependInfo($assembler);
my $gatekeeper = "$ENV{CA_ROOT}/bin/gatekeeper";
$base->addDependInfo($gatekeeper);
my $populator = "$ENV{CA_ROOT}/bin/PopulateFragStore";
$base->addDependInfo($populator);
my $grep = "/bin/grep";
$base->addDependInfo($grep);
my $cata = "/local/asmg/bin/ca2ta";
$base->addDependInfo($cata);
my $caqc = "/usr/local/common/caqc";
$base->addDependInfo($caqc);
my $makeofg = "$ENV{CA_ROOT}/bin/make_OFG_from_FragStore";
$base->addDependInfo($makeofg);
my $meryl = "$ENV{CA_ROOT}/bin/meryl";
$base->addDependInfo($meryl);
my  $ca2scaff = "/local/asmg/work/mpop/Tools/CA/ca2scaff.pl";
$base->addDependInfo($ca2scaff);

my $infile;
my $justasm;

my $err = $base->TIGR_GetOptions("i=s" => \$infile,
				 "justasm" => \$justasm);

if ($err == 0){
    $base->bail("Command line parsing failed.  See -h option");
}

if (!defined $infile){
    $infile = $ARGV[0];
}

if ($infile !~ /\.conf$/){
    $base->bail("Input file must end in .conf");
}
$infile =~ /(.*)\.conf$/;
my $prefix = $1;

my $MIN_READ = 500;
my $MAX_READ = 700;
$base->logLocal("Will generate reads between $MIN_READ and $MAX_READ bases", 1);

my $MATE_FAIL = 0.3;
my $CHIMERAS = 0.01;
$base->logLocal("Assuming mates fail rate is $MATE_FAIL and chimera rate is $CHIMERAS", 1);

my $MIN_ERR = 0.0001;
my $MAX_ERR = 0.008;

$base->logLocal("Reading configuration file \"$infile\"", 1);
open(IN, $infile) || $base->bail("Cannot open \"$infile\": $!\n");

my $lib;
my $range;
my $frac;
my $genome;
my $nreads;
my %libraries;
my %fractions;
my %genomes;
my %size;
my $seed = undef;
while (<IN>){
    if (/^lib_id=(\w+)/){
	$lib = $1;
	if (defined $libraries{$lib}){
	    $base->bail("At line $. in $infile:\n  \"$lib\" library already seen");
	}
	next;
    }
    if (/^lib_range=(\d+,\d+)/){
	$range = $1;
	$libraries{$lib} = $range;
	$base->logLocal("Found library \"$lib\" with range $range", 1);
	next;
    }
    if (/^lib_frac=(\d+\.?\d*)/){
	$frac = $1;
	$fractions{$lib} = $frac;
	$base->logLocal("Will do $frac % of library \"$lib\"", 1);
	next;
    }
    if (/^genome_file=(\S+)/){
	$genome = $1;
	if (! -r $genome){
	    $base->bail("At line $. in $infile:\n  File \"$genome\" is unreadable");
	}
	next;
    }
    if (/^min_read=(\d+)/){
	$MIN_READ = $1;
	next;
    }
    if (/^max_read=(\d+)/){
	$MAX_READ = $1;
	next;
    }
    if (/^genome_size=(\d+)/){
	$size{$genome} = $1;
	next;
    }
    if (/^coverage=(\d+)/){
	if (! exists $size{$genome}){
	    $base->bail("you must define a genome size for genome $genome at line $. in $infile\n");
	}
	$genomes{$genome} = int( $1 * $size{$genome} / (($MIN_READ + $MAX_READ)/ 2));
	next;
    }
    if (/^nreads=(\d+)/){
	$nreads = $1;
	$genomes{$genome} = $nreads;
	$base->logLocal("Will generate $nreads reads from file \"$genome\"\n");
	next;
    }
    if (/^err=([0-9]*\.?[0-9]+),([0-9]*\.?[0-9]+)/){
	$MIN_ERR = $1;
	$MAX_ERR = $2;
	next;
    }
    
    if (/^seed=(\d+)/){
	$seed = $1;
	next;
    }
    if (/^\#/){
	next;
    }
    if (/^\s*$/){
	next;
    }
    $base->bail("Line $. from \"$infile\" cannot be parsed:\n  $_");
}

close(IN);

$base->logLocal("Using error ramp from $MIN_ERR to $MAX_ERR", 1);
$base->logLocal("Done reading configuration", 1);

my $ngen = 1;
my @gennames;
my $name;
my @fragfiles;
my $accession = 1;
while (($genome, $nreads) = each %genomes){
    $name = "${prefix}_" . $ngen++;
    $gennames[++$#gennames] = $name;
    
  REDO:
    $base->logLocal("$name will have $nreads reads read from \"$genome\"", 1);
    my $simfile = $name . ".sim";
    $base->logLocal("simulation file is in \"$simfile\"", 1);
    open(OUT, ">$simfile") || $base->bail("Cannot open \"$simfile\": $!\n");
    
#    my $seed = time ^ ($$ + ($$ << 15)) ; # straight out of perlfunc
    if (! defined $seed) {$seed = 17131;} # Art's lucky and magic seed
    print OUT 
qq~
.seed
$seed

.dna
A < $genome ;
~;

    while (($lib, $frac) = each %fractions){
       my $libreads = int($nreads * ($frac / 100.0));
       my ($minlib, $maxlib) = split(',', $libraries{$lib});
    
       print OUT 
qq~

.sample
$libreads
$MIN_READ $MAX_READ .5
0 0 0 0
$MIN_ERR $MAX_ERR 0.33 0.33
$MATE_FAIL $minlib $maxlib $CHIMERAS
~;
    } # while ($lib, $frac)
    close(OUT);

    if (! defined $justasm){
       $base->logLocal("Generating .frg file for \"$name\"", 1);
       my $celsim_cmd = "$celsim -a $accession $simfile";
       $base->logLocal("Running \"$celsim_cmd\"", 1);
       my $errno = $base->runCommand($celsim_cmd);
       if ($errno != 0){
          $base->bail("Command \"$celsim_cmd\" failed with code: $errno");
       }
    }

    my $frgname = "$name" . "_A00001" . ".frg";
    if (! -e $frgname || -z $frgname){
       $base->bail("Celsim appears to have failed");
    }

    my $actual = `$grep -c \'^{FRG\' $frgname`;
    if (abs($actual - $nreads) > 10){
        chomp $actual;
        $base->logLocal("Celsim messed up: $actual ne $nreads", 1);
        $base->logLocal("Trying again", 1);
        goto REDO;
    }

    $fragfiles[++$#fragfiles] = "$frgname";
    $base->logLocal("Generated frg file \"$frgname\"", 1);
    open(ACC, "$grep \'^acc\' $frgname |") ||
       $base->bail("Cannot run $grep on \"$frgname\": $!\n");
    while (<ACC>){
       $_ =~ /acc:(\d+)/;
       if ($1 > $accession) {
	   $accession = $1;
       } 
    }
    close(ACC);
    $accession++;
    $base->logLocal("Setting accession to $accession", 1);
} # while ($genome, $nreads)

$base->logLocal("Doing assembly", 1);

my $create_mode;
for (my $file = 0; $file <= $#fragfiles; $file++) {
    if ($file == 0) {
       $create_mode = "-f";
    } else {
       $create_mode = "-a";
    }
    
    my $gateStore = $prefix . ".gkpStore";
    my $gateCmd = "$gatekeeper -X -C -N -Q -P $create_mode $gateStore $fragfiles[$file]";
    $base->logLocal("Running \"$gateCmd\"", 1);
    my $errno = $base->runCommand($gateCmd);
    if ($errno != 0){
       $base->bail("Command \"$gateCmd\" failed with code: $errno");
    }
}

for (my $file = 0; $file <= $#fragfiles; $file++) {
    if ($file == 0) {
       $create_mode = "-f";
    }else {
       $create_mode = "-a";
    }

    $fragfiles[$file] =~ /(.*)\.frg/;
    my $inpfile = $1 . ".inp";
    my $populateCmd = "$populator -c -f -o $prefix.frgStore $create_mode $inpfile";
    $base->logLocal("Running \"$populateCmd\"", 1);
    my $errno = $base->runCommand($populateCmd);
    if ($errno != 0){
       $base->bail("Command \"$populateCmd\" failed with code: $errno");
    }
}

my $ofgCmd = "$makeofg $prefix.frgStore > $prefix.ofg";
$base->logLocal("Running \"$ofgCmd\"", 1);
my $errno = $base->runCommand($ofgCmd);
if ($errno != 0){
    $base->bail("Command \"$ofgCmd\" failed with code: $errno");
}

my $merylCmd = "$meryl -s $prefix.frgStore -m 22 -n 200 -o $prefix.nmers.fasta";$base->logLocal("Running \"$merylCmd\"", 1);
$errno = $base->runCommand($merylCmd);
if ($errno != 0){
    $base->bail("Command \"$merylCmd\" failed with code: $errno");
}

my $asmCmd = "$assembler -root=$asRoot -start=402 -prefix=$prefix";
$base->logLocal("Running \"$asmCmd\"", 1);
$errno = $base->runCommand($asmCmd);
if ($errno != 0){
    $base->bail("Command \"$asmCmd\" failed with code: $errno");
}

# my $cataCmd = "$cata -justfasta $prefix.asm";
# $base->logLocal("Running \"$cataCmd\"", 1);
# $errno = $base->runCommand($cataCmd);
# if ($errno != 0){
#     $base->bail("Command \"$cataCmd\" failed with code: $errno");
# }

my $caqcCmd = "$caqc $prefix.asm > $prefix.qc";
$base->logLocal("Running \"$caqcCmd\"", 1);
system($caqcCmd);

my $ca2scaffCmd = "$ca2scaff $prefix.asm -o $prefix";
$base->logLocal("Running \"$ca2scaffCmd\"", 1);
$errno = $base->runCommand($ca2scaffCmd);
if ($errno != 0){
    $base->bail("Command \"$ca2scaffCmd\" failed with code: $errno");
}

$base->logLocal("Succesful finish!", 1);
exit(0);

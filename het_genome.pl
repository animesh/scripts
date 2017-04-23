#!/usr/bin/perl

########################################
#
# BUG ?
# 4461	scaffold12371	2185	Genome	contig697437
#		scaffold12371	1093	Variant	contig697437
# is the only one it loks
# Note base start is wrong
#
########################################

# Input:
# from the gapCover script from Roger Winer:
# NewScaffolds.txt file
# AltPaths.txt file
# from an assembly
# 454Scaffolds.txt
# 454ContigGraph.txt file
# 454AllContigs.fna file
#
# Output:
# GenomeScaffolds.txt		--> modified after NewScaffolds, with one contig for each closed gap + neighbours
# AllGenomeContigs.fna		--> same as original 454AllContigs.fna, but with the new concatenated contigs added
# AltPathContigs.fna		--> the alternative paths, with their neighbour contigs
# Variants.tsv				--> table describing the genome contigs with the variants at that position
# Variants.fna				--> fasta sequences with the header describing the information in the Variants.tsv file
#							NOTE not for positions where there is a 'direct conenction'
# Genome_all_stats.tsv	--> new all_stats.tsv file


# Developed by Lex Nederbragt
# lex.nederbragt@bio.uio.no
# December 2009

# to implement:
# generate quality files
# together with Roger Winer, removal of contigs
# that are now scaffolded and do not appear
# elsewhere in the genome

# NOTE	Assumes current folder is where the assembly is
# NOTE	if the All contigs threshold is set to 0, the part of getting
#		the tiny contigs from the graph file is not necessary (%lens)

use strict;
use warnings;

my $nextctg;		# one higher than contig with highest number in the assembly
my %seqs;			# contigXXXXX ==> contig sequence based on 454AllContigs.fna
my %tinyseqs;		# contigXXXXX ==> contig sequence, based on 454ContigGraph.txt (for <100 bp)
my %lens;			# contigXXXXX ==> contig length (not necessary as long as all contigs are in the 454AllContigs.fna file)
my %depths;			# contigXXXXX ==> contig depth
my @ctgs;			# list of contigs to concatanate (or just one contig)
my @ctgs_ori;		# list of orientation of contigs to concatanate (or just one contig): + = normal, - = reverse complement
my $scafname;		# name of current scaffold (column 1 in 454Scaffold.txt file)
my $firstctg;		# name of the first contig in a concatenated contig
my $start = 1;		# start position of the merged contig (column 2 in 454Scaffold.txt file)
my $stop;			# stop position of the merged contig (column 3 in 454Scaffold.txt file)
my $linenum;		# line number of the scaffold (column 4 in 454Scaffold.txt file)
my $ctgname = "";	# name of the (merged) contig (column 6 in 454Scaffold.txt file)
my $ctglen=0;		# length of the (merged) contig (column 8 in 454Scaffold.txt file)
my %merges;			# newcontigname ==> tab-separated list of contigs to merge (in correct order)
my %new_ctg_first;	# newcontigname ==> name of the first contig in it
my %scafctgs;		# scaffoldXXXXX\tcontigname ==> 1 for contigs in the original scaffolds
my %genctgs;		# scaffoldXXXXX\tcontig (from original scaffolds) ==> entire line(s) from NewScaffolds.txt for gap filling contig(s)
my %varctgs;		# scaffoldXXXXX\tcontig (from original scaffolds) ==> output line based on info from AltPaths.txt for Variant.tsv file
my $fromctg;		#
my $counter;

my $test;

if($#ARGV == -1) {
   print "USAGE: het_genome.pl NewScaffolds.txt-file AltPaths.txt-file
   Assumes current folder is where the assembly is
   Will generate files:
   'GenomeScaffolds.txt'
   'AllGenomeContigs.fna'
   'AltPathContigs.fna'
   'Variants.tsv'
   \n";
   exit(0);
}

open(INGRAPH,"< 454ContigGraph.txt") || die "Cannot open 454ContigGraph.txt file: $!\n";
open(INSCAF,"< $ARGV[0]") || die "Cannot open NewScaffolds file '$ARGV[0]': $!\n";
open(INALT,"< $ARGV[1]") || die "Cannot open AltPath file '$ARGV[0]': $!\n";
open(INCTG,"< 454AllContigs.fna") || die "Cannot open 454AllContigs.fna file: $!\n";

open(OUTSCAF,"> GenomeScaffolds.txt") || die "Cannot open GenomeScaffolds.txt file for writing.\n";
open(OUTCTG,"> AllGenomeContigs.fna") || die "Cannot open AllGenomeContigs.fna file for writing.\n";
open(OUTSTATS,"> Genome_all_stats.tsv") || die "Cannot open Genome_all_stats.tsv file for writing.\n";

#open(OUTALTCTG,"> AltPathContigs.fna") || die "Cannot open AltPathContigs.fna file for writing.\n";
open(OUTVARS,"> Variants.tsv") || die "Cannot open Variants.tsv file for writing.\n";
open(OUTVARS2,"> Variants.fna") || die "Cannot open Variants.fna file for writing.\n";


####### Step 1 #######
# get largest used contig number 
# and tiny contigs (below 100bp)
# from 454ContigGraph.txt file

print "Processing 454ContigGraph.txt\n";
while(<INGRAPH>){
	if (/contig/){
		my @ele=split;				# number, contigname, length, depth
		$nextctg=$ele[0]+1; 		# determine number of highest contig, add 1 for new contigs
		$lens{$ele[1]}=$ele[2];		# add length to hash
		$depths{$ele[1]}=$ele[3];	# add depth to hash
	}
	if (/^S/){	# example: S       2       97897   73:+;gap:925;74:+;gap:316;75:+; <...snip...> gap:1212;98:+;gap:1676;99:+
	  my ($scaffoldNumber,$linePart) = ($_ =~/S\s+(\d+)\s+\d+\s+(\d+:.+)/);
	  for my $ele (split ";" , $linePart){
	  	if ($ele =~ /(\d+):+/){
			# record neigbouring contigs (have gap inbetween)
			$scafctgs{$fromctg}=sprintf("contig%05d",$1) if defined $fromctg; 				# example: scaffold00002\tcontig00077 ==> contig00078
		  	$fromctg=sprintf("scaffold%05d",$scaffoldNumber)."\t".sprintf("contig%05d",$1);	# example: scaffold00002\tcontig00077
		}
      # record scaffold end
      $scafctgs{$fromctg}="scaffold_end"; # example: scaffold00002\tcontig00099 ==> scaffold_end
	  }
	}
	# load tiny contigs (<100 bp) in hash
	$tinyseqs{sprintf("contig%05d",$1)}=$2 if (/^I\s(\d+)\s([a-zA-Z]+)\s/&&length($2)<100);
}

# DEBUG scafctgs
# print "$_\t$scafctgs{$_}\n" for sort keys %scafctgs; exit[0];
 
####### Step 2 #######
# Read in 454AllContigs.fna

print "Processing 454AllContigs.fna\n";
$/=">"; # set the record separator to the '>' symbol
		# this forces each sequence into $_
		# note however, that each sequence ENDS with the '>' symbol
		# and that the first 'entry' (record) is consisting of ONLY the '>' symbol
<INCTG>;		# remove the empty first 'sequence'
while (<INCTG>){
	chomp;	# remove the trailing '>' symbol
	my @lines = split(/\n/,$_);	# split the entry into individual lines based on the newline character
	my $header = shift @lines;	# the header is the first line (now without the '>' symbol)

	# build a hash of sequences
	$seqs{$1}=join "", @lines if $header =~ /(contig\d+)/;
}
$/="\n"; # reset the record separator

####### Step 3 #######
# process NewScaffolds.txt fle
# and generate GenomeScaffolds.txt file
# so that there is again only one contig
# between the gaps

print "Generating GenomeScaffolds.txt\n";
$fromctg=undef;
my $prevline=-2;	# holds line number, $ele[3], from previous line
my $prevpos = 0;	# holds start position, $ele[1], from previous line
while (<INSCAF>){
	chomp;
	my @ele=split;
	if ($ele[4] eq "W"){	# contig, collect info 
		if (defined $scafctgs{"$ele[0]\t$ele[5]"}){	# contig is from original scaffolds 
			# check for direct link (non-existing gap)
			$genctgs{"$ele[0]\t$fromctg"} = "$ele[0]\t$prevpos\tdirect_connection\n" if ($prevline + 1 == $ele[3] && defined $fromctg); #	the current contig is the gapless neighbor of the previous one
			$fromctg = $ele[5];
			$prevline = $ele[3];
			$prevpos = $ele[1];
		}
		else{
			$genctgs{"$ele[0]\t$fromctg"}.=$_."\n" if defined $fromctg;	# scaffoldXXXXX\tfromcontig ==> add entire line
		}
		if ($ele[1]==1){	# new scaffold, report last contig
			if (defined $scafname){	# NOT scaffold 1
				# report last contig
				&outcontig;
				$linenum=0;	# reset linenumber for new scaffolds
				$start=1;	# start of the next contig is base 1 with new scaffold
			}
		$scafname=$ele[0];
		$prevline=1;
		}
		# process current scaffold
		$stop=$ele[2];					# always contains the number for the last contig
		push (@ctgs,$ele[5]);			# add contig to list of contigs at this position
		push (@ctgs_ori,$ele[8]);		# add contig orientation (+ or -) to list of contigs at this position
		$ctglen+=$ele[7];
		if ($ctgname eq ""){$ctgname=$ele[5]} # holds the name of the contig when it is the only one, OR the first contig if several are to be merged
	}
	if ($ele[4] eq "N"){	# gap, report previous contig(s), then current gap
		&outcontig;
		# GAP line
		$linenum++;
		$ele[3] = $linenum;
		print OUTSCAF join "\t", @ele;print OUTSCAF "\n";
		# reset variables
		@ctgs=();
		@ctgs_ori=();
		$start=$ele[2]+1;	# start of the next contig is one base end of this gap
		$ctgname="";
		$ctglen=0;
	}	
}

# end of file, output last line
&outcontig;


######## Subroutines #########

sub outcontig {
	# CONTIG line output
	$linenum++;
	# take the next higher contig number for concatenated contigs
	$ctgname = sprintf("contig%05d",$nextctg++) if ($#ctgs>0);
	# write line
	print OUTSCAF join "\t",($scafname,$start,$stop,$linenum,"W",$ctgname,1,$ctglen,"+");print OUTSCAF "\n";
	# add contigs to concatenate
		if ($#ctgs>0){	# for contigs to be merged
			my $new_seq;
			$firstctg=$ctgs[0];
			$merges{$ctgname}= join ":",@ctgs;	# for contigs to be merged
			$new_ctg_first{$firstctg}=$ctgname;	# name of first contig for this concatenated contig
			for (0..$#ctgs){
				# $ctgs[$_] is contig to add; $ctgs_ori[$_] is orientation of it
				my $ctg_to_add;
				if (defined $seqs{$ctgs[$_]}){$ctg_to_add=$seqs{$ctgs[$_]}} 			# contig present in the 454AllContigs.fna file, add sequence
				elsif (defined $tinyseqs{$ctgs[$_]}){$ctg_to_add=$tinyseqs{$ctgs[$_]}}	# tiny contig present in the 454ContigGraph.txt file, add sequence
				else {																	# contig missing!
					print "Missing contig in concatenated contig $ctgname: $ctgs[$_], filling with $lens{$ctgs[$_]} Ns\n";
					$ctg_to_add="N"x$lens{$ctgs[$_]};
				}
			$ctg_to_add=revcomp($ctg_to_add) if $ctgs_ori[$_] eq "-";	# check for orientation
			$new_seq.=$ctg_to_add;										# add contig
			}
			# add merged contig to hashes containing all sequences, lengths and depths
			$seqs{$ctgname}=$new_seq;
			$lens{$ctgname}=length($new_seq);
			$depths{$ctgname}=0;	# temporary (?) solution
		}
	# reset variables
	@ctgs=();
	@ctgs_ori=();
	$ctgname="";
	$ctglen=0;
}

# DEBUG genctgs
# print "$_\n$genctgs{$_}" for sort keys %genctgs; exit[0];


####### Step 4 #######
# Generate new 454AllContigs.fna file

print "Generating AllGenomeContig.fna file\n";
print OUTSTATS "contig\tlength\tdepth\tgc\n";
for (sort keys %seqs){
	my $merged = "";
	$merged=" ".$merges{$_} if defined $merges{$_};
	print OUTCTG ">$_ length=$lens{$_}$merged\n$seqs{$_}\n" if $lens{$_}>99;
    my $gc_perc = ($seqs{$_} =~ tr/C|c|G|g//)/($lens{$_}-($lens{$_} =~ tr/N|n|N|n//));     # calculate GC%: (Number of G + C) divided by (length minus number of N)
	print OUTSTATS "$_\t$lens{$_}\t$depths{$_}\t".sprintf "%.3f", $gc_perc;
	print OUTSTATS "\n";
}

####### Step 6 #######
# Generate AltPathContigs.fna file
print "Processing AltPath.txt\n";

my $startctg = "";
my $lastctg;
my $varlines = "";	# lines containing info on the variant paths
$counter = 1;		# Number of alternate paths
while (<INALT>){
	chomp;
	my @ele=split;
	if (/direct/){	# line mentioning 'direct connection to'
		$scafname=$ele[0];
		$varlines = "$ele[0]\t$ele[1]\tdirect_connection\n";
	}
	if ($ele[0] eq "AltPath"){
		# report previous
		&outaltcontig if defined $ctgs[0]; #if not first line of file;
		# process nextline
		if ($startctg eq $ele[1]){$counter++}else{$counter=1}; #	more than one alternate path or not
		$startctg=$ele[1];		# startcontig name
		push (@ctgs,$ele[1]);	# startcontig name
		push (@ctgs_ori,"+");	# startcontig orientation is always '+'
		$lastctg=$ele[3];		# startcontig name, last contig name
		next;
	}
	if ($ele[4] eq "W"){	# contig, collect info 
		$scafname=$ele[0];
		push (@ctgs,$ele[5]);		# add contig to list of contigs at this position
		push (@ctgs_ori,$ele[8]);	# add contig orientation (+  or -) to list of contigs at this position
		$varlines.= "$_\n";			# add variant info
	}
}

# end of file, output last line
&outaltcontig;

sub outaltcontig{
	# Process variants 
	# exclude variant if it is the same as at this position in the genome
	$varctgs{"$scafname\t$startctg"}.= &ctg_var_format("Variant",$varlines) if &ctg_var_format("Genome",$genctgs{"$scafname\t$startctg"}) ne &ctg_var_format("Genome",$varlines);
	$varlines = "";
}

sub revcomp{
# reverse
	my $rcseq = reverse $_[0];
# complement
	$rcseq =~ tr/ACMGRSVTWYHKDBNacmgrsvtwyhkdbn
	            /TGKCYSBAWRDMHVNtgkcysbawrdmhvn/;
	return $rcseq
}

# DEBUG varctgs
#print "$_\n$varctgs{$_}" for sort keys %varctgs; exit[0];

####### Step 7 #######
# Generate Variants.txt file
print "Generating Variants files\n";

$scafname='';
print OUTVARS "counter\tscaffold\tstart_base\tcontig_type\tcontig(s)\tlength(s)\tdepth(s)\torientation(s)\ttotalLentgh\tsequence\n";
$counter=1;
for (sort keys %varctgs){
	($scafname, $fromctg) = split;	# key is scaffold name, contig after which the variant occurs
	# output genome situation
	print OUTVARS $counter++,"\t",&ctg_var_format("Genome",$genctgs{$_});
	if ($genctgs{$_} !~/direct/){
		my @ele=split "\t", &ctg_var_format("Genome",$genctgs{$_});
		my $seq = pop @ele;
		print OUTVARS2 ">".join "_", ($ele[0],"base",$ele[1],$ele[2],$ele[3],"length(s)",$ele[4],"depth(s)",$ele[5],"totalLength",$ele[7]);
		print OUTVARS2 "\n$seq";
	}
	# output variant(s)
	foreach(split "\n", $varctgs{$_}){
	print OUTVARS "\t$_\n";
	if ($_ !~/direct/){
			my @ele=split "\t", $_;
			my $seq = pop @ele;
			print OUTVARS2 ">".join "_", ($ele[0],"base",$ele[1],$ele[2],$ele[3],"length(s)",$ele[4],"depth(s)",$ele[5],"totalLength",$ele[7]);
			print OUTVARS2 "\n$seq\n";
		}
	}
}

sub ctg_var_format{
	my $result;	# will be returned
	my $type = shift;	# first argument is "Genome" or "Variant"
	$start = undef;
	my @ele;
	my @contigs;
	my @lengths;
	my @depths;
	my @oris;
	my $genseq="";
	foreach my $entry (@_){
		foreach (split "\n", $entry){
			my $ctg_to_add;
			@ele=split;
			if ($ele[2] eq "direct_connection"){		# direct connection is a special case
				$result = "$ele[0]\t$ele[1]\t$type\tdirect_connection\t\t\t\t0\n"
			}
			else {	# real variant
				$start = $ele[1] if !defined $start;
				push @contigs,$ele[5];			# add contig ID
				push @lengths,$ele[7];			# add contig length
				push @depths,sprintf "%.0f", $depths{$ele[5]};	# add contig depth
				push @oris,$ele[8];				# add otiantation + or -
				#################
				# OPTIONAL: get sequence 1) from $seqs, 2) from tinyctgs, 3) fill with gaps
				#################
				$ctg_to_add = $seqs{$ele[5]};	# get contig sequence
				$ctg_to_add = revcomp($ctg_to_add) if $ele[8] =~ /-/;	# revcomp sequence if orientation '-'
				$genseq.=$ctg_to_add;			# add contig sequence
			}
		}
	}
	if ($ele[2] ne "direct_connection"){
		$result="$ele[0]\t$start\t$type\t".join ("," , @contigs);
		$result.="\t". join "," , @lengths;
		$result.="\t". join "," , @depths;
		$result.="\t". join "," , @oris;
		$result.="\t". length($genseq)."\t$genseq\n";
	}
	return $result;
}
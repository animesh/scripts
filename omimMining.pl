#!/usr/bin/perl

############################################################################
###                                                                      ###
### Text Mining Program for OMIM part 1                                  ###
###											                             ###
### Input : OMIM text file (e.g. omim.txt)                               ###
### Output: outOmimMining.txt				                             ###
###                                                                      ###
### Original Author: Dr. Shawn Rusaw                                     ###
### Partially Modified by: Byron Kuo,                                    ###
###                        Steve Sung                                    ###
###                                                                      ###
### BC CANCER AGENCY                                                     ###
### BC GENOME SCIENCES CENTRE                                            ###
###                                                                      ###
### Copyright 2004 Chris Bajdik, Shawn Rusaw, Byron Kuo, Steve Sung      ###
###                                                                      ###
### This file is part of CGMIM.                                          ###
###                                                                      ###
### CGMIM is a free software; you can redistribute it and/or modify      ###
### it under the terms of the GNU General Public License as published    ###
### by the Free Software Foundation; either version 2 of the License, or ###
### (at your option) any later version.                                  ###
###                                                                      ###
### CGMIM is distributed in the hope that it will be useful,             ###
### but WITHOUT ANY WARRANTY; without even the implied warranty of       ###
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        ###
### GNU General Public License for more details.                         ###
###                                                                      ###
### You should have received a copy of the GNU General Public License    ###
### along with CGMIM; if not, write to the Free Software                 ###
### Foundation, Inc., 59 Temple Place, Suite 330, Boston,                ###
### MA  02111-1307  USA                                                  ###
############################################################################

use strict;
use PorterStemmer;
use IO::Handle;

my $cont;

system("date");

if (@ARGV != 1) {
	print "USAGE: [command] [omim text input file name]\n";
	exit;
}

PorterStemmer::initialise(); # init the stemmer
my %stems;

###################
### Import Data ###
###################

# import the cancer synonym data from the sorted_syn directory
if (!open(IN, "sorted_syn/cancer_syn.txt")) {
	die "Cannot open cancer thesaurus file.\n"
}

my @cancers;

while (my $line = <IN>) {
	$line =~ s/^\s*//; # remove leading whitespace
	$line =~ s/\s*$//; # remove trailing whitespace
	if ($line ne "") {
		push @cancers, PorterStemmer::stem($line);
	}
}
close IN;

# import the cancer type synonym data
#my @types = ("BLADDER", "CERVIX", "LYMPHOMA", "LEUKEMIA", "MYELOMA", "PROSTATE", "TESTIS", "BRAIN", "COLORECTAL", "KIDNEY", "LUNG", "OVARY", "THYROID", "BREAST", "ESOPHAGUS", "LARYNX", "ORAL", "PANCREAS", "STOMACH", "BODY_OF_UTERUS", "MELANOMA" );
my @types = ("STOMACH");

my %types_hash;
foreach my $type (@types) {

	# open synonyms for every site
	if (!open(IN, "sorted_syn/$type" . "_syn.txt")) {
		die "Cannot open $type thesaurus file.\n"
	}
	my @syns;
	while (my $line = <IN>) {
		$line =~ s/^\s+//; # remove leading whitespace
		$line =~ s/\s+$//; # remove trailing whitespace

		# if line matches with a quoted word (i.e. "gum")
		# then push the term (unquoted) into the array
		# also stores one in the hash
		if ($line =~ m/\"(.*)\"/) {
			push @syns, $line;
			$stems{$line} = $line;
		}

		# otherwise, the unquoted terms are processed by PorterStemmer (remove suffixes)
		# and pushed into the array
    
		else {
			push @syns, PorterStemmer::stem($line);
		}
	}

	# push every synonyms array to the types_hash
	$types_hash{$type} = [ @syns ];
	close IN;
}

#-------------------------------------------------------------------------------------

######################
### Read OMIM Text ###
######################

# read in all the OMIM text entries, keeping track
# of which cancers are mentioned in each
if (!open(OUT, ">outOmimMining.txt")) {
	die "Cannot open results file outOmimMining.txt for writing.\n"
}

if (!open(IN, "$ARGV[0]")) {
	die "Cannot open results file ($ARGV[0]) for writing.\n"
}

# process the data file
my $done = 0;
while (!$done) {
	my $rectext = 0;		# flag for recording text
	my $donerectext = 0;	# flag for whether recording text is done or not
	my $text = "";			# string variable for storing text information
	my $recid = 0;			# flag for recording id
	my $donerecid;			# flag for whether recording id is done or not
	my $id = "";			# string variable for storing MIM number

	################################################
	## Read and Record until the end of aan entry ##
	################################################
    while (my $line = <IN>) {
		chomp $line;

		###########################
		## Record the Text Field ##
		###########################

		# if the currenly line is the beginning of the text field
		# reset  the $text string variable to null
		# and set the $rectext flag to 1 (true)
		if ($line =~ m/\*FIELD\* TX/) {
			$rectext = 1;
			$text = "";
		}

		# else if it matches some other field
		# if $rectext is true, set $donerectext flag to 1 (true) denoting it's done
		# reset $rectext to 0 (false)
		elsif ($line =~ m/\*.+\*/){
			if ($rectext) {
				$donerectext=1;
			}	
			$rectext = 0;
		} 

		# else if $rectext is true and current line is in the text field
		# concatenate the $line to $text
		elsif ($rectext) {
			$text .= $line . " ";
		}

		#########################
		## Record the ID Field ##
		#########################

		# if $line matches the MIM number field
		# set $recid to 1 (true)
		# reset the $id variable to null
		if ($line =~ m/\*FIELD\* NO/) {
			$recid = 1;
			$id = "";
		}

		# else if $line matches some other field
		# if $recid is true, set $donerecid to 1 (true) denoting it's done
		# reset $recid to 0 (false)
		elsif ($line =~ m/\*.+\*/) {
			if ($recid) {
				$donerecid=1;
			}
			$recid = 0;
		} 

		# else if $recid is true
		# concatenate $id with $line
		elsif ($recid) {
			$id .= $line;
		}

		# if both $donerectext and $donerecid are true
		# this means we have finished reading one record
		# break the loop
		if ($donerectext && $donerecid) {
			last;
		}
	}

	#############################
	## Finish Reading an Entry ##
	#############################

	# if either $donerectext or $donerecid is false
	# we have finished reading the whole text
	# set $done to true
	# break whole loop
	if (!$donerectext || !$donerecid) {
		$done = 1;
		last;
	}

	# remove spaces before and after the MIM number
	$id =~ s/^\s+//;
	$id =~ s/\s+$//;

	# this indicates a retired record number
	if ($id =~ m/^\^/) {
		next;
	}

	###################
	## stem the text ##
	###################
	my $start = 1;
	my $stemmed_text = "";

	# keep the loop if $text matches zero or more alphanumeric characters
	# or if $start is true
	while ($text =~ m/\G(\w*)/gc || $start) {
		$start = 0;

		# calls the stem_word() function and concatenate the returned value
		# to $stemmed_text
		$stemmed_text .= stem_word($1);
	
		# if $text matches zero or more alphanumeric characters
		while ($text =~ m/\G(\W*)/gc) {
			$stemmed_text .= $1;
		}
	}

	##############################################
	## split the stemmed text it into sentences ##
	##############################################
	my @stemmed_sentences = split /\./, $stemmed_text;
	my @sentences = split /\./, $text;

	# check length
	if (scalar(@sentences) != scalar(@stemmed_sentences)) {
		die "Sentence arrays are not the same length.\n";
	}

	################################
	## Mining within the sentence ##
	################################
	# for each cancer type, use the text string of current entry to match the 
	# existence of a cancer synonym with the existence of a type synonym
	# if a match is found, print out the sentence
	foreach my $key (keys %types_hash) {
		my $match = text_contains_cancer_sentence(\@cancers, \@{$types_hash{$key}}, \@stemmed_sentences);
	
		if ($match) {
			print OUT "$id\t$key\n";
			flush OUT;
	    }
	}
}

system("date");
close OUT;
close IN;
exit(0);

##########################################
## The following are the functions used ##
##########################################

# FUNCTION: returns the value of the key $word in the hash
#           if the value is not defined, then process the key using PorterStemmer
#           transform the result to lower case and store as value
# INPUT:  $word as a key to hash
# OUTPUT: the value of the key
sub stem_word() {
	my $word = shift;

	# if the parameter $word is undefined in the hash
	if (!defined $stems{$word}) {

		# process the $word with PorterStemmer, change all letters to lower case
		# and store into the hash
		$stems{$word} = lc(PorterStemmer::stem($word));
    }

	# return the value of this key
	return $stems{$word};
}


# FUNCTION: finds whether or not a site (or its synonyms) and cancer (or synonyms)
#           occur within the same sentence
# INPUT:  a reference of cancer synonyms array
#         a reference of type synonyms array
#         a reference of the array of sentences
# OUTPUT: return the position of the sentence plus one
#         or return 0 if no such pattern is found
sub text_contains_cancer_sentence() {
	my $cancer_syn = shift;
	my $type_syn = shift;
	my $sentences = shift;

	for (my $i = 0; $i < scalar(@$sentences); $i++) {
		my $sentence = ${@$sentences}[$i];
		foreach my $cancer (@$cancer_syn) {
			if ($sentence =~ m/$cancer/) {
				foreach my $type (@$type_syn) {
					if ($sentence =~ m/$type/) {
						return $i+1;
					}
				}
			}
		}
	}
	return 0;
}
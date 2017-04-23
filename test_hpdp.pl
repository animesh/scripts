##############################################################
 # These materials (including  without limitation all articles,
 #  text, images, logos, software, and designs) are copyright 
 # © 2006,2007,2008 Helicos BioSciences Corporation.  All rights 
 # reserved.
 #
 # This program is free software; you can redistribute it and/or
 # modify it under the terms of the GNU General Public License
 # as published by the Free Software Foundation version 2
 # of the License
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software
 # Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
 # 02110-1301, USA.
#################################################################


use strict;
use Test::More tests => 16;

# Test is of the following alignment
#
#  ref   ATCG-ATTTCGAT-G         13
#  tag   AGCGGAT--CG-TCG         12
#

my $config_file      = $ENV{HPDP_CONFIG_FILE};
my $nohp_config_file = $ENV{HPDP_NOHP_CONFIG_FILE};
my $reference_file   = $ENV{HPDP_REFERENCE_FILE};
my $tags_file        = $ENV{HPDP_TAGS_FILE};
my $hpdp_outfile = 'hpdp.out';

my %reg = ( ReferenceNonHomoPolymerGap => -4,
	    ReferenceHomoPolymerGap    => -1,
            TagNonHomoPolymerGap       => -4,
	    TagHomoPolymerGap          => -1,
	    NucleotideMatch            => 5,
	    NucleotideToNMatch         => -2,
	    NucleotideMismatch         => -4 );


my $num_ref_nonhp_gap                  = 1;
my $num_ref_hp_gap                     = 1;
my $num_regular_match                  = 9;
my $num_regular_mismatch               = 1;
my $num_tag_nonhp_gap                  = 1;
my $num_tag_hp_gap                     = 2;

my $score = 
    $reg{'NucleotideMatch'}            * $num_regular_match +
    $reg{'NucleotideMismatch'}         * $num_regular_mismatch +
    $reg{'ReferenceHomoPolymerGap'}    * $num_ref_hp_gap +
    $reg{'ReferenceNonHomoPolymerGap'} * $num_ref_nonhp_gap +
    $reg{'TagHomoPolymerGap'}          * $num_tag_hp_gap +
    $reg{'TagNonHomoPolymerGap'}       * $num_tag_nonhp_gap;

if ($ENV{TEST_VERBOSE}) { print "Benchmark HPDP test score is $score\n"; }


my $result = 1;
#Test execution
is(system("./hpdp --referenceFile $reference_file --tagsFile $tags_file --configFile $config_file > $hpdp_outfile"),0,'hpdp execution test');

#Test result
open RESULT, $hpdp_outfile or die "Unable to open hpdp output file $hpdp_outfile\n";
my $result = '';
while ( my $line = <RESULT>) {
    if ($ENV{TEST_VERBOSE}) { print "$line"; }
    chomp $line;
    $result .= $line . ' ';
}
close RESULT;

is($result =~ /Score\: $score/ms,1,"Test alignment score");
is($result =~ /Num_Regular_Match\: $num_regular_match/,1,"Test regular match");
is($result =~ /Num_Regular_Mismatch\: $num_regular_mismatch/,1,"Test regular mismatch");
is($result =~ /Num_Seq1HPGap\: $num_ref_hp_gap/,1,"Test reference HP gap");
is($result =~ /Num_Seq1NonHPGap\: $num_ref_nonhp_gap/,1,"Test reference non-HP gap");
is($result =~ /Num_Seq2HPGap\: $num_tag_hp_gap/,1,"Test tag HP gap");
is($result =~ /Num_Seq2NonHPGap\: $num_tag_nonhp_gap/,1,"Test tag non-HP gap");


# Test with HP option off
$num_ref_nonhp_gap                  = 2;
$num_ref_hp_gap                     = 0;
$num_regular_match                  = 8;
$num_regular_mismatch               = 2;
$num_tag_nonhp_gap                  = 0;
$num_tag_hp_gap                     = 0;

$score = 
    $reg{'NucleotideMatch'}            * $num_regular_match +
    $reg{'NucleotideMismatch'}         * $num_regular_mismatch +
    $reg{'ReferenceHomoPolymerGap'}    * $num_ref_hp_gap +
    $reg{'ReferenceNonHomoPolymerGap'} * $num_ref_nonhp_gap +
    $reg{'TagHomoPolymerGap'}          * $num_tag_hp_gap +
    $reg{'TagNonHomoPolymerGap'}       * $num_tag_nonhp_gap;

if ($ENV{TEST_VERBOSE}) { print "Benchmark HPDP test score is $score\n"; }


is(system("./hpdp --referenceFile $reference_file --tagsFile $tags_file --configFile $nohp_config_file > $hpdp_outfile"),0,'test execution');

#Test result
open RESULT, $hpdp_outfile or die "Unable to open hpdp output file $hpdp_outfile\n";
my $result = '';
while ( my $line = <RESULT>) {
    if ($ENV{TEST_VERBOSE}) { print "$line"; }
    chomp $line;
    $result .= $line . ' ';
}
close RESULT;

is($result =~ /Score\: $score/ms,1,"Test alignment score");
is($result =~ /Num_Regular_Match\: $num_regular_match/,1,"Test regular match");
is($result =~ /Num_Regular_Mismatch\: $num_regular_mismatch/,1,"Test regular mismatch");
is($result =~ /Num_Seq1HPGap\: $num_ref_hp_gap/,1,"Test reference HP gap");
is($result =~ /Num_Seq1NonHPGap\: $num_ref_nonhp_gap/,1,"Test reference non-HP gap");
is($result =~ /Num_Seq2HPGap\: $num_tag_hp_gap/,1,"Test tag HP gap");
is($result =~ /Num_Seq2NonHPGap\: $num_tag_nonhp_gap/,1,"Test tag non-HP gap");


unlink($hpdp_outfile);

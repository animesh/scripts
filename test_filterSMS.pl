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


# Test designed to be run via make check
# Should return 0 for success, non-zero for failure and 
# the special value of 77 for 'ignore me'.
# 
# check executables are run without arguments, but values can be added via
# TESTS_ENVIRONMENT automake variable
#

use strict;
use Test::More tests => 3;

my $sms_file              = $ENV{SMS_FILE};
my $filtered_sms_file     = $ENV{FILTERED_SMS_FILE};
my $hpdp_scores_file      = $ENV{HPDP_SCORES_FILE};
#my $sample_size           = 955;
my $maxlen_cutoff         = 9;                      #Maxlen cutoff value.  Should cut total to maxlen_expected
my $minlen_cutoff         = 9;                      #Minlen cutoff value.  Should cut total to minlen_expected
my $minlen_expected       = 160000;                 #Expected number of reads given minlen cutoff
my $maxlen_expected       = 160000;                 #Expected number of reads given maxlen cutoff
my $io_redirect = '';
$io_redirect = '2> /dev/null > /dev/null' unless $ENV{TEST_VERBOSE};

system("cp -f $hpdp_scores_file .") && die "Unable to copy hpdp scores file $hpdp_scores_file\n";

my $result = 1;
# Test execution, filter by length
is(system("./filterSMS --input_file $sms_file --output_file $filtered_sms_file --maxlen $maxlen_cutoff $io_redirect"),0,'filterSMS execution test')
    or $result = 0;
is(`./smsls --sms_file $filtered_sms_file` =~ /Total reads: $maxlen_expected/,1,'maxlen cutoff test')
    or $result = 0;

system("./filterSMS --input_file $sms_file --output_file $filtered_sms_file --minlen $minlen_cutoff $io_redirect");
is(`./smsls --sms_file $filtered_sms_file` =~ /Total reads: $minlen_expected/,1,'minlen cutoff test')
    or $result = 0;


#exit($result);

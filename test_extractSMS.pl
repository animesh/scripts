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
use Test::More tests => 2;

my $sms_file              = $ENV{SMS_FILE};
my $channels_per_flowcell = $ENV{CHANNELS_PER_FLOWCELL};
my $reads_per_channel    = $ENV{READS_PER_CHANNEL};
my $positions_per_channel = $ENV{POSITIONS_PER_CHANNEL};
my $fc1_ext_sms_file      = $ENV{FC1_EXT_SMS_FILE};
my $fc1_extracted_reads = $channels_per_flowcell * $reads_per_channel;
my $io_redirect = '';
$io_redirect = '2> /dev/null > /dev/null' unless $ENV{TEST_VERBOSE};


my $result = 1;
# Test execution; extract flow cell 1
is(system("./extractSMS --input_file $sms_file --output_file $fc1_ext_sms_file --flow_cells 1 --positions 1-$positions_per_channel $io_redirect"),0,'extractSMS execution test')
    or $result = 0;
is(`./smsls --sms_file $fc1_ext_sms_file` =~ /Total reads: $fc1_extracted_reads/,1,'flow cell extraction')
    or $result = 0;

#exit($result);

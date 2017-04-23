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
my $compressed_sms_file   = $ENV{COMPRESSED_SMS_FILE};
my $smsls_out_file        = 'smsls.out';
my $flow_cell_count       = $ENV{FLOW_CELL_COUNT};
my $channels_per_flowcell = $ENV{CHANNELS_PER_FLOWCELL};
my $reads_per_channel    = $ENV{READS_PER_CHANNEL};
my $total_reads = $flow_cell_count * $channels_per_flowcell * $reads_per_channel;

my $smsls_header = "FlowCellBarcodeFlowCellIDChannelPositionsReads";
my $smsls_last   = "Total reads: $total_reads";


my $result = 1;
# Test execution
is(system("./smsls --sms_file $sms_file > $smsls_out_file"),0,'smsls execution test')
    or $result = 0;

# Read the smsls output
open SMSLS_OUT, "$smsls_out_file";
my @lines = <SMSLS_OUT>;

#Remove whitespace and check header
$lines[0] =~ s/\s//g;
is($lines[0],$smsls_header,'check header')
    or $result = 0;

#Check total number of reads (after chomping)
chomp $lines[$#lines];
is($lines[$#lines],$smsls_last,'smsls total reads')
    or $result = 0;
#exit($result);

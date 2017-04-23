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

my $sms_file          = $ENV{SMS_FILE};
my $csv_file          = $ENV{CSV_FILE};
my $fasta_file        = $ENV{FASTA_FILE};
my $flowcell          = 1;
my $channel           = 25;
my $reads_per_channel = $ENV{READS_PER_CHANNEL};
my $io_redirect = '';
$io_redirect = '2> /dev/null > /dev/null' unless $ENV{TEST_VERBOSE};

my $result = 1;
# Test execution
is(system("./sms2txt --sms_file $sms_file --fa_file $fasta_file --csv_file $csv_file --flowcell $flowcell --channel $channel $io_redirect"),0,'sms2txt execution test')
    or $result = 0;
is(`grep -c '^VHE' $csv_file` =~ /$reads_per_channel/,1,'csv output test')
    or $result = 0;
is(`grep -c '^>' $fasta_file` =~ /$reads_per_channel/,1,'fasta output test')
    or $result = 0;

#exit($result);

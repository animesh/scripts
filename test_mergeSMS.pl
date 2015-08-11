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

my $merge1_file           = $ENV{MERGE1_FILE};
my $merge2_file           = $ENV{MERGE2_FILE};
my $merge_result_file     = $ENV{MERGE_RESULT_FILE};
my $merge_result_sha1     = $ENV{MERGE_RESULT_SHA1};
my $io_redirect = '';
$io_redirect = '2> /dev/null > /dev/null' unless $ENV{TEST_VERBOSE};

my $result = 1;
# Test execution, filter by length
is(system("./mergeSMS --input_file $merge1_file --input_file $merge2_file --output_file $merge_result_file $io_redirect"),0,'mergeSMS execution test')
    or $result = 0;
is(system("sha1sum -c $merge_result_sha1"),0,'merge result test')
    or $result = 0;


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

my $ms_read_file             = $ENV{MS_READ_FILE};
my $ms_ref_file              = $ENV{MS_REF_FILE};
my $ms_config_file           = $ENV{MS_CONFIG_FILE};
my $ms_output_file           = $ENV{MS_OUTPUT_FILE};
my $io_redirect = '';
$io_redirect = '2> /dev/null > /dev/null' unless $ENV{TEST_VERBOSE};

my $result = 1;
# Test execution
is(system("./moveSummaryTool --read_file $ms_read_file --reference_file $ms_ref_file --config_file $ms_config_file $io_redirect"),0,'moveSummaryTool execution test')
   or $result = 0;

open OUTFILE, "$ms_output_file" or die "Unable to open moveSummaryTool output file $ms_output_file\n";
my @output_lines = <OUTFILE>;
close OUTFILE;

if ( $ENV{TEST_VERBOSE} ) { print @output_lines; }
is($output_lines[0] =~ /^#PROGRAM=moveSummaryTool/,1,'moveSummaryTool output test')
   or $result = 0;

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
use Test::More tests => 6;

my $srf_file            = $ENV{SRF_FILE};
my $sms_file            = $ENV{SMS_FILE};
my $compressed_sms_file = $ENV{COMPRESSED_SMS_FILE};
my $xml_file            = $ENV{XML_FILE};
my $io_redirect = '';
$io_redirect = '2> /dev/null > /dev/null' unless $ENV{TEST_VERBOSE};

my $result = 1;
# Test execution
is(system("./srf2sms --srf_file $srf_file --sms_file $sms_file --xml_file $xml_file $io_redirect"),0,'srf2sms execution')  
    or $result = 0;
# Test normal file creation
is( -e $sms_file, 1, 'sms file generated') 
    or $result = 0;
is( -e $xml_file, 1, 'xml file generated')
    or $result = 0;

# Test compressed file creation
is(system("./srf2sms --srf_file $srf_file --sms_file $compressed_sms_file --compress 1 --xml_file $xml_file $io_redirect"),0,'srf2sms execution')
    or $result = 0;
is( -e $compressed_sms_file, 1, 'compressed sms file generated') 
    or $result = 0;

# Test failure if srf not specified
is(system('./srf2sms $io_redirect') > 0,1,'srf2sms fail if no srf file')
    or $result = 0;
#exit($result);
     


    


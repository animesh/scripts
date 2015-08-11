# EXPANDPATH Get expanded version of the file path.
# Copyright 2007 The MathWorks, Inc.

use strict;
use Win32;

my $Argument = shift;
my $PathName;
if ($Argument eq "")
{
 	die "$0: Please give the path name to expand\n";
}
else
{
 	$PathName = $Argument;
}

print Win32::GetLongPathName($PathName);

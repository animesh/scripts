# Abstract:
#   This script will automatically generate a help object for UDD
#   objects with constructors whose methods cannot be found on the
#   MATLAB path.  The script extracts the help line from the method
#   in the object stored in <srcfile> and creates a new object
#   <dstfile>. Optionally, the script can replace each occurence of 
#   <strfrom> with <strto> in the file.
#
#   Usage:
#       perl mkhelp.pl <srcfile> <dstfile> [<strfrom> <strto>]
#
# $RCSfile: util_mkhelp.pl,v $
# $Revision: 1.1.6.1 $ $Date: 2009/01/23 21:28:43 $
# Copyright 2006-2008 The MathWorks, Inc.
#

#-------------#
# Check usage #
#-------------#

$nargs = $#ARGV + 1;

if ($nargs < 2) {&Usage; exit(1);}

$srcfile = $ARGV[0];
$dstfile = $ARGV[1];

if ($nargs == 4){
    $strfrom = $ARGV[2];
    $strto   = $ARGV[3];
}

# derive destination directory name from $dstfile
if ($dstfile =~ /^(.*)\/\w*\.m$/) {$dstdir = $1;}
else {$dstdir = '.';}

#--------------------#
# Create help object #
#--------------------#


# first, remove help object if it exists
if (-e $dstfile)
{
    printf("Removing $dstfile\n");
    unlink $dstfile || die "Could not remove $dstfile: $!\n";
}

#-------------------------------------
# Create help dir if it does not exist
#-------------------------------------
unless (-e $dstdir){
    mkdir($dstdir, 0777) || die "Unable to create destination directory $dstdir: $!\n";
    printf("Created destination directory $dstdir\n");
}

#------------------#
# Load src *.m file
#------------------#

# make sure srcfile is a *.m file
unless ($srcfile =~ /^.*\.m$/){
    print "WARNING: srcfile is not an m-file\n";
    &Usage; exit(1);
}

print "$srcfile --> $dstfile\n";

#open source file
open(SRCFILE, "$srcfile") || die "Couldn't open $srcfile: $!\n";

# read first line but skip % test
$tmp = <SRCFILE>;
$tmp =~ s/classdef.*$/function vd = adivdsp(varargin)/g;

# read one line at a time
$includeinhelp = 1;
while ($line = <SRCFILE>)
{
    #get first character
    $char = substr($line,0,1);
    
    #include in help only the first contiguous block of comments
    if($char ne '%') {
	$includeinhelp = 0;
    }
    
    if($includeinhelp){
	if($strfrom && $strto){
	    $line =~ s/$strfrom/$strto/g;
	}
	$tmp .= $line;
    }

    #include in help the Copyright line updated with current year;
    #once done, no need to read the rest of the file
    if($line =~ /Copyright/){
	$year = sprintf("%d", (gmtime)[5] + 1900);
	$line =~ s/[0-9]+\s*[-\s*[0-9]+]*/$year /g;
	$tmp .= "\n$line";
	last;
    }
}


#close source file
close(SRCFILE) || die "Couldn't close $file: $!\n";

#open new destination file
open(DSTFILE, ">" . $dstfile) || die "Couldn't create $file: $!\n";

#write to file
print(DSTFILE $tmp);

#close destination file
close(DSTFILE) || die "Couldn't close $file: $!\n";

#------#
# Done #
#------#
exit(0);

#-------------------#
# Subroutine: Usage #
#-------------------#

sub Usage {
    print "Usage: mkhelp.pl <srcfile> <dstfile> [<strfrom> <strto>]\n";
}

# EOF [mkhelp.pl]

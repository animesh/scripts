# File : rm.pl
#
# Abstract :
# 
# 	Deletes a list of files from a set of glob patterns
#
# Usage
#
# 	perl rm.pl *.exe *.c *.f
#
#
# $Revision: 1.1.4.3 $
# $Date: 2007/11/28 17:52:39 $
#
# Copyright 2002-2007 The MathWorks, Inc.
$globpatterns = join(' ',@ARGV);
@files = glob($globpatterns);
$nfiles = $#files + 1;
if ($nfiles > 0){
	$_files = join("\n",@files);
	print "Deleting $nfiles file(s)\n"; 
	foreach $file (@files) {
		print " => $file -> ";
      # check file existence before deleting
      if (-e $file) {
   		if (unlink($file)){
	   		print "Deleted.\n";
   		} else{
	   		print "Failed to delete.\n";
   		}
      } else {
         print "Does not exist, skipping deletion.\n";
      }
	}
}


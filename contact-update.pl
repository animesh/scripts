#!/usr/bin/perl -w
#
# updates the contact list for everybuddy
#
# Ben Rigas <ben@everybuddy.com>
#
#	* Now fixes empty group problem * 
#
#############################################################################

if ( $ENV{"HOME"} ) {

	$file = $ENV{"HOME"} . "/.everybuddy/contacts";

} else {

	chomp($who = `whoami`);
	$file = "/home/$who/.everybuddy/contacts";
}



sub convert {

   my @old = @_;

   chomp(@old);
   $i= 0;	


   open (FILE, ">$file") 
      or die "Can't open contact file to write new format: $!\n";

# loop through the whole file

   while ($i <= $#old) {

# get the group name

      if ($old[$i] =~ /GROUP\s+(.*)/i) {	

# print <GROUP> and NAME=thing we just got

         print FILE "<GROUP>\n   NAME=\"$1\"\n";
         $i++;

# increment lines, and loop through until the next group

         until ($old[$i] =~ /GROUP\s(.*)/i) {  

            if ($old[$i] eq "") { 
                  print "Found empty group! Done!\n"; 
                  print FILE "</GROUP>\n"; 
                  exit; 
            }
 
# print Contact start and name, increment lines

            print FILE "   <CONTACT>\n      NAME=\"$old[$i]\"\n";
            $i++;

# print protocol, and skip two lines, ignoring the default chat thing

            print FILE "      DEFAULT_PROTOCOL=\"$old[$i]\"\n";
            $i = $i + 2;

# go through each account proto/name for each contact

            until ($old[$i] eq "END") {
              
               print FILE "      <ACCOUNT $old[$i]>\n";
               $i++;
               print FILE "         NAME=\"$old[$i]\"\n      </ACCOUNT>\n";
               $i++;

            }       
            print FILE "   </CONTACT>\n";

# catch the last line, so it doesnt get incremented and give us
# $i = $#old+1, that would screw everything up

               if ($i == $#old) {
                  print FILE "</GROUP>\n";
                  exit;
#otherwise increment lines and go through group again

               } else {
                  $i++;
               }
            

         }  print FILE "</GROUP>\n"; 

      } 
     
   }

   close(FILE);
   print "Conversion complete: $i contacts updated.\n";


}

sub main {

	open (OLDFILE, "$file") 
		or die "Can't open contact file($file) for reading: $!\n";
	@oldfile = <OLDFILE>;
	close(OLDFILE);	

#        chomp(@oldfile);

        if (scalar (@oldfile) == 0)
	{
	    exit;
	}

	if ($oldfile[0] =~ /<GROUP>/)
	{
	    exit;
	}

	open (BACKUP, ">$file.backup")
	    or die "Can't open file to make backup: $!\n";
	print BACKUP @oldfile;
	close (BACKUP);

	convert(@oldfile);
}



main();


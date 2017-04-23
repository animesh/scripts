# $Revision: 1.1.6.2 $
#
# Takes in 3 arguments
#   arg1 : The file to be taken the replacement
#   arg2 : Comma separated list that built-in types (rtw types) should be 
#          replaced
#   arg3 : Comma separated list that replacement types should replace 
#          the built-in types

# compare 2 arrays, same return 1, else return 0
sub cmpList {
	my($array1, $array2) = @_;		# pass reference
	for ($i = 0; $i <= $#$array1; $i ++) {
		if ($$array1[$i] ne $$array2[$i]) {
			return 0;
		}
	}
	return 1;
}



# Initialize the inputs
@rtwTypeList = split /,/, $ARGV[1];
@repTypeList = split /,/, $ARGV[2];

open (INFILE, "$ARGV[0]") or die ("Cannot open file $ARGV[0]: $!\n");
@fileText = <INFILE>;
close (INFILE);

@origFileText = @fileText;

foreach $repType (@repTypeList)
{
  $rtwType = shift(@rtwTypeList);
  foreach(@fileText)
  {
     $tst = s/\b$rtwType(?!\.)\b/$repType/xg; 
     if($tst==1){print "$new ";}
  }
}

if (!cmpList(origFileText, fileText))
{ 
    open (OUTFILE, ">$ARGV[0]");
    print OUTFILE @fileText;    # print name field to file  
    close (OUTFILE);
}

exit();






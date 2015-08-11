# your shell command goes here
#
# Hacking EAN numbers to a form usable with WLEAN.MF.
#
# September 3, 1997
# Peter Willadt
#
# Added hacking any text for coding with code 128
# 1998-01-24
#
# Added checksumming for code 93
# 1998-11-29
#
# 2003-05-24
# cleaned up the code in several places and
# corrected code 93 checksumming due to a hint by
# Jacek Ruzyczka <uv_centcom@yahoo.com>
#
# 2003-05-24
# removed an error introduced the same day
#
# This file is free to use without any further permissions.
# This file comes with no warranty of any kind.
#
# The TeX file to be filtered may contain any number of lines
# that have one of the following commands
# starting at the leftmost position.
#
# \ean{12 or 13 digit number}
# the number gets coded as EAN, 
# if it is only 12 digits long, the checksum gets calculated
#
# \embed{number}
# the number is used as a base for embedding article numbers & c.
# \eean{number}
# a number to be embedded with an ean.
#
# \isbn{number}
# an isbn to make an embedded ean of.
#
# \cxxviii{any 7 bit ascii values}
# code as barcode 128 (see rules below!)
#
# \xciii{uppercase text or number}
# text to be coded as code 128
#
# example:
# You want the isbn 0-201-13448-9 to be embedded.
# so you say \isbn{0201134489},
# but you may also say \embed{9780000000000} and, 
# somewhere later in the file, \eean{020113448}
# In this case you have to leave the last digit out,
# as isbn loose their check digit in favour of the
# ean check digit.
# anyway you do it, you get your command replaced by 
# \EAN{13-digit-number-coded-strange}
# in the output file.
#
#
# code 128 rules:
# you write a line starting with \cxxviii{
# followed by arbitrary 7 bit characters, delimited by a right brace}.
# as perl is greedy, it will be the rightmost right brace (no fence matching),
# but as perl is also nice, you will be warned if there is another
# right brace.  Please note that even the percent character % will be
# included.  So it is better to write the \cxxviii{...} statement onto
# a line of its own.  You may replace any character by ^^00 and
# similiar codes, preferably you will do this to non-printable ascii
# characters, or right braces and the like. This routine will try to find
# an efficent way to make code 128 (sorry, not necessarily the most 
# efficient way) out of your input and then it will
# insert a line like \CXXVIII{3a 70 12 ... @@} in the output file.
# The code 128 special characters can be included by the following codes:
# ^^80 FNC3
# ^^81 FNC2
# ^^82 SHIFT
# ^^83 CODE C/CODE C/99
# ^^84 CODE B/FNC4/CODE B
# ^^85 FNC4/CODE A/CODE A
# ^^86 FNC1
# ^^87 START A
# ^^88 START B
# ^^89 START C
# ^^8a STOP

use strict;

use vars qw ( @ABTAB $ifname $ofname );
# code switch table for ean

@ABTAB=(0,0,0,0,0,0,     #0
	0,0,1,0,1,1,     #1
	0,0,1,1,0,1,     #2
	0,0,1,1,1,0,     #3
	0,1,0,0,1,1,	 #4 and so on
	0,1,1,0,0,1,
	0,1,1,1,0,0,
	0,1,0,1,0,1,
	0,1,0,1,1,0,
	0,1,1,0,1,0,
	);

# command line processing: Need input file

if($ARGV[0]){
    $ifname=$ARGV[0];
}else{
    print "Enter name of file to be processed: ";
    $ifname = <>;
    chomp($ifname);
}

# command line processing: need output file

if($ARGV[1]){
    $ofname=">$ARGV[1]";
}else{
    print "Enter name of output file: ";
    $ofname = <>;
    chomp($ofname);
    $ofname = '>' . $ofname;
}

# make an ean

sub eancod{
    my ($i, $j, $checksum, $disone);
    my $srcstr=shift;
    # first digits first
    my $precod=substr($srcstr,0,1);
    # Starting output string
    my $eastring=$precod . " +";
    # digits 2--7
    for($i=0;$i<6;$i++){
	my $disone=substr($srcstr,$i+1,1);
	$disone =~ tr/0123456789/ABCDEFGHIJ/;
	$disone= lc ($disone) if( @ABTAB[$precod*6 + $i]==1);
	$eastring .=$disone;
    }$eastring .= "-";
    # digits 8--13
    for($i=0;$i<6;$i++){
	# if checksum misses, do your own
	if(($i==5) && (length($srcstr)==12)){
	    for($j=0,$checksum=0;$j<12;$j++){
		$checksum+=substr($srcstr,$j,1)*(1+($j&1)*2);
	    };
	    $checksum%=10;
	    $checksum=10-$checksum;
	    $checksum%=10;
	    $disone="$checksum";
	}else {
	    $disone=substr($srcstr,$i+7,1);
	}
	$disone =~ tr/0123456789/KLMNOPQRST/;
        $eastring .=$disone;
    }$eastring .="+";
    return $eastring;
}

##################################################
# here starts the code 128 stuff
#
##################################################
# get the numerical value of a hex character, 
# e.g. 65 from 41
#  
sub hexchar{
    my $src=shift;
    my ($i, $j, $result);
    $src =~ tr/a-f/A-F/;
    $i=ord(substr($src,0,1));
    $j=ord(substr($src,1,1));
    if($i >= ord("A")){
	$i += (10-ord('A'));
    }else{
	$i -= ord("0");
    }
    if($j >= ord("A")){
	$j += (10-ord("A"));
    }else{
	$j -= ord("0");
    }
    $result=16*($i)+$j;
    return $result;
}


# globals:
# @cxxchars holds the characters the user wants to code
# @cxxlength is the size of this array
# @ctbl holds the possible codings for these chars
# @cxxout holds the codes to be output for code 128
# @cxxoutout holds the codes to be output for code 128

use vars qw ( @cxxchars $cxxlength @ctbl @cxxout @cxxoutout);

##################################################
# build up the switching table for code 128

sub makectbl{
    # locals
    my $i;
    for($i=0;$i < $cxxlength; $i++){
	if(($cxxchars[$i] >= ord("0"))&&($cxxchars[$i] <= ord("9"))){
            # digits
	    $ctbl[$i]=7;
	}elsif(($cxxchars[$i] >= ord(" "))&&($cxxchars[$i] <= ord("_"))){
	    # common Chars
	    $ctbl[$i]=3;
	}elsif($cxxchars[$i] < ord(" ")){
            # ascii control chars
	    $ctbl[$i]=1;
	}elsif(($cxxchars[$i] >=ord("`"))&&($cxxchars[$i] <= ord("\x7f"))){
	    # lowercase
	    $ctbl[$i]=2;
	    if($cxxchars[$i] == ord("}")){
		print "Encountered right brace in argument to cxxviii\n";
	    }
	}else{	                                              # Function Codes
	    $ctbl[$i] =7;
	}
    }
    $ctbl[$i]=0; # makes a stop.
}

##################################################
# make a character array from a string 
# looking like aBc\x41def^^41 or so.
#
sub unhex{
    my ($i, $j, $b);
    my $srcstr=shift;
    $j=0;
    for($i=0;($b=ord(substr($srcstr,$i,1))) > 0;$i++){
	if($b == ord("\\")){
	    if(substr($srcstr,$i+1,1) =~ /[xX]/){	 # hex input
		$cxxchars[$j] = hexchar(substr($srcstr,$i+2,2));
		$i += 3;
	    }else{
		$cxxchars[$j] = ord("\\");
	    }
	}elsif($b == ord("^")){
	    if(ord(substr($srcstr,$i+1,1)) == ord("^")){ # hex input
		$cxxchars[$j] = hexchar(substr($srcstr,$i+2,2));
		$i += 3;
	    }else{
		$cxxchars[$j] = ord("^");
	    }
	}else{
	    $cxxchars[$j] = $b;
	}
	$j++;
    }
    return $j;
}

##################################################
# write out a chunk of code 128 in hex symbols
#
sub cxxchunk{
    my $j=shift;
    my ($i, $sum, $k);
    $sum=7;
    for($i=0;$sum & $ctbl[$j+$i]; $i++){
	$sum &= $ctbl[$j+$i];
    }
    if($sum==1){
	$cxxout[$j]=101;
    }else{
	$cxxout[$j]=100;
    }
    for($k=0;$k<$i;$k++){
	if(($sum==1)&&($cxxchars[$j+$k] < ord(" "))){
	    $cxxout[$j+$k+1]=$cxxchars[$j+$k] + 64;
	}else{
	    $cxxout[$j+$k+1]=$cxxchars[$j+$k] - ord(" ");
	}
    }
    $k++;
    return $k;
}

##################################################
# consecutive digits may perhaps be efficiently
# coded with charset C
#
sub pastedigits{
    my $digitcount=shift;
    my $j=shift;
    my $firstdigit=shift;
    my $lastset=shift;
    my $k;
    if($digitcount==0){      # nothing to do
	return $j;
    }elsif($digitcount<4){
	# digits here, but unfortunately not enough digits.
	# so just copy them
	for($k=0;$k<$digitcount;$k++){
	    $cxxoutout[$j] = $cxxout[$firstdigit+$k];
	    $j++;
	}
	return $j;
    }else{
	# is there an odd number of digits?
	if(($digitcount & 1)==1){
	    $cxxoutout[$j] = $cxxout[$firstdigit];
	    $firstdigit++;
	    $digitcount--;
	    $j++;
	}elsif(($cxxout[$j-1]>=99)&&($cxxout[$j-1]<=101)){
	    # Switched immediately before digits.
	    # so overwrite the switch
	    $j--;
	}
	$cxxoutout[$j] = 99; # switch to set C
	$j++;
	# copy digits in compressed format
	for($k=0;$k<$digitcount;$k+=2){
	    $cxxoutout[$j] = ($cxxout[$firstdigit+$k]-16)*10
		+$cxxout[$firstdigit+$k+1]-16;
	    $j++;
	}
	# reset char set, if you have to
	if($lastset > 0){
	    $cxxoutout[$j] = $lastset;
	    $j++;
	}
    }
    return $j;
}

sub digitoptimize{
    # change to charset C if there are at least four numbers in a row.
    # copy to @cxxoutout
    my ($lastset, $firstdigit, $digitcount, $i,$j,$k);
    $lastset   =0;
    $firstdigit=0;
    $digitcount=0;
    $j=0;
    for($i = 0; $i < $cxxlength; $i++){
	if(($cxxout[$i]>=16)&&($cxxout[$i]<=25)){
	    # it's a number
	    if($digitcount == 0){
		$firstdigit=$i;
	    }
	    $digitcount++;
	    next;
	}
	if($digitcount >0){
	    $j=pastedigits($digitcount,$j,$firstdigit,$lastset);
	    $digitcount=0;
	}
	$cxxoutout[$j] = $cxxout[$i];
	$j++;
	if(($cxxout[$i]>=99)&&($cxxout[$i]<=101)){
	    # it's a code switch
	    $lastset=$cxxout[$i];
	}else {
	    $lastset=0;
	}
    }
    # $lastset is zero here, as there is no further need 
    # to switch the char set any more - we're at the end
    $j=pastedigits($digitcount,$j,$firstdigit, 0);
    return $j;
}

##################################################
# code 128 is a little complicated
# if you have read till here, you already know.
#
sub codcxxviii{
    # locals
    my ($i, $j, $sum);
    my $srcstr=shift;
    # first step: unhexing
    $cxxlength = unhex($srcstr);
    # @cxxchars now holds the characters the user wants
    makectbl();
    # @ctbl now contains the possible tables for the chars in $j;
    for($i =0; $i < $cxxlength;){
	$i += cxxchunk($i);
    }
    # change codeset switch to start
    $cxxlength=$i;
    $j=digitoptimize();
    # Start symbols are different from switch symbols
    if($cxxoutout[0]==99){
	$cxxoutout[0]=105;
    }elsif($cxxoutout[0]==100){
	$cxxoutout[0]=104;
    }else{
	$cxxoutout[0]=103;
    }
    # calculate checksum and build output string
    for($i=1,$sum=$cxxoutout[0];$i<$j;$i++){
	$sum+=$cxxoutout[$i]*$i;
    }
    $sum %=103;
    $cxxoutout[$j]=$sum;
    $j++;
    $cxxoutout[$j]=106; #stop sign
    $srcstr="";
    for($i=0;$i<($j+1);$i++){
	$srcstr .= sprintf "%02X", $cxxoutout[$i];
    }
    $srcstr .= "@@";
    return $srcstr;
}

##################################################
# do code 93 -- it's easy
##################################################
sub codxciii{
    my $srcstr=shift;
    my $cstbl='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%()[]';
    my ($i, $j, $sumc, $sumh, $checkchar);
    $sumc=$sumh=0;
    for ($i=0;$i<length($srcstr);$i++){
	$j=index($cstbl, substr($srcstr,$i,1),0);
	# $j is the check value of the character.
	$sumh=$sumh+$j;
	$sumc=$sumc+$sumh;
    }
    $srcstr=$srcstr . substr($cstbl,$sumc%47,1);
    $sumc=$sumc+$sumh+($sumc%47);
    $checkchar=substr($cstbl,$sumc%47,1);    
    $srcstr =  $srcstr . $checkchar;
    $srcstr =~ s/\$/\\\$/g;
    $srcstr =~ s/%/\\%/g;
    $srcstr =~ s/ /\\char\'040/g;
    return $srcstr;
}

##################################################
# we got both input and output file,
# we defined all subroutines,
# so here we go...
#
use vars qw ( $line $embedded $embtmp $mycod $eastring);

open(EINGABE, $ifname) or die "No file";
open(AUSGABE, $ofname) or die "Can't open output file";
while($line=<EINGABE>){
    # save 0.0005 (est.) % running time
    unless ($line =~ /^\\/){
	print AUSGABE $line;
	next;
    }
    if($line =~ /^\\embed{(\d+)\}/){
	$embedded=$1;
	print AUSGABE $line;
    }elsif($line =~ /^\\eean\{(\d+)\}(.*)/){
	# embedded EAN
	$embtmp=substr($embedded,0,12-length($1));
	$mycod=$embtmp . $1;
	$eastring=eancod($mycod);
	print AUSGABE "\\EAN{$eastring}$2 % embedded($1)\n";
    }elsif ($line =~ /^\\ean\{(\d+)\}(.*)/){
	# normal ean
	$eastring=eancod($1);
	print AUSGABE "\\EAN{$eastring}$2 %($1)\n";
    }elsif($line =~ /^\\isbn\{([\dxX]+)\}(.*)/){
	# isbn to be embedded
	$embtmp=substr($1,0,9);
	$mycod='978' . $embtmp;
	$eastring=eancod($mycod);
	print AUSGABE "\\EAN{$eastring}$2 % ISBN($1)\n";
    }elsif($line =~ /^\\cxxviii\{(.+)\}(.*)/){
	# code 128
	$eastring=codcxxviii($1);
	print AUSGABE "\\CXXVIII $eastring $2 % Code128($1)\n";
    }elsif($line =~ /^\\xciii\{(.+)\}(.*)/){
	# code 93
	$eastring=codxciii($1);
	print AUSGABE "\\XCIII{$eastring}$2 % Code93($1)\n";
    }else {
	print AUSGABE $line;
    }
}

##################################################
# we're done, so we do some cleanup and quit.
close (EINGABE);
close (AUSGABE);
print "Done.\n";

##################################################
# what we do here is called
# 'falling off the edge of the world'
# in the camel book.
##################################################

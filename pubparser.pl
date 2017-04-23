#!/usr/bin/perl
print "enter the name of the swissprot file\n";
$file=<>;
chomp $file;
open F1,$file;
$file=~s/\.txt//;
open F2,">$file\.csv";
while($line=<F1>)
{

if($line =~ /^RN/)
	{$line=~s/RN//;
	#print $line;
	@ID=split(/\s+/,$line);
	print F2"@ID[1]";
	}
if($line =~ /^RA/)
	{$line=~s/RA//;$line=~s/\n//;$line=~s/;//;
	#print $line;
	@ID=split(/\,/,$line);
	foreach $ra (@ID)
	{print F2"\,$ra\n";}
	#print "@ID\t";
	}
if($line =~ /^RT/)
	{$line=~s/RT//;$line=~s/,//;$line=~s/\.//;$line=~s/;//;$line=~s/"//;$line=~s/\n//;
	#print $line;
	#@ID=split(/\,/,$line);
	print F2"\,\,$line";
	}
if($line =~ /^RL/)
	{$line=~s/RL//;
	#print $line;
	#@ID=split(/\,/,$line);
	print F2"\,\,\,$line";
	}
if($line =~ /^ID/)
	{
	#print $line;
	@ID=split(/\s+/,$line);
	print F2"\,\,\,\,@ID[1]";
	}
#do{
                                        $linenew=<F>;
                                        chomp ($linenew);
                                        $lines = $lines.$linenew;
#                                                }until ($linenew =~ /^RL/)
#

}




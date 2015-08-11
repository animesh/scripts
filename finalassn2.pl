#!/usr/bin/perl
$linenew="";
open (FH,"AC109365.fas.2") || die "cant open file : $!";
while ($line1=<FH>){
chomp $line1;
$linenew=$linenew.$line1;
}
$linenew="0".$linenew;
#print "$linenew\n";
$count=0;
open (F, "AC109365.fas.2.glimmerR") || die "cant open file : $!";
while ($line=<F>){chomp$line;
if($line =~ /^\s+[1-9]/){
$line=~s/\t/\s/g;
#print $line."\n";
$line=~s/\s+/\t/g;
#print "$line\n";
@splitt = split (/\t/ , $line);
#$fele=$splitt[1];
#print"1= $splitt[1] , 2e=$splitt[2] 3-=$splitt[3] 5=$splitt[5]  7sp=$splitt[7] \n";
#if ($fele ==$firstel[$count-1]
#{ 
push (@firstel,$splitt[1]);
push (@exon,$splitt[2]);
push (@strand,$splitt[3]);
push (@startpt ,$splitt[5]);
push (@length,$splitt[7]);
}
}
#print "$#firstel ,$#exon ,$#strand ,$#startpt, $#length \n";
#@removed=splice (@firstel ,0,3);
#rint "@startpt \n @length\n";

#rint "@firstel \n";
# $test=@firstel;
# $subseqnew="";
$j=1;
for ($i=0;$i<=$#firstel;$i++)
{

	if ($firstel[$i]==$firstel[$j])
	{
		#$cpi=$i;
		while($firstel[$i]==$firstel[$j])
		{
			#print " i=$firstel[$i] ,j=$firstel[$j] \n";
		    	$subseq=$subseq.substr($linenew , $startpt[$i] , $length[$i]); 
                                              $i++;$j++;
		}

	#	$subseq=$subseq.substr($linenew , $startpt[$i] , $length[$i]);
		#$j++;
		#print "out loop i=$firstel[$i] j= $firstel[$j] \t";
  		#print "$subseq \n\n";
		#$subseq="";
	}


	$subseq=$subseq.substr($linenew,$startpt[$i],$length[$i]);
	if ($strand[$i] eq "-")
	{
		$subseq=reverse($subseq);
		chomp$subseq;
		@seqel=split(//,$subseq);
		foreach $seqel(@seqel)
		{
                                        if ($seqel eq "A")
                                        {
                                        $seqel="T";
                                        $newseq=$newseq.$seqel;
                                        }
                                        elsif($seqel eq "T")
                                        {
                                        $seqel="A";
                                        $newseq=$newseq.$seqel;
                                        }
                                         elsif ($seqel eq "G")
                                        {
                                        $seqel="C";
                                        $newseq=$newseq.$seqel;
                                        }
                                        elsif($seqel eq "C")
                                        {
                                        $seqel="G";
                                        $newseq=$newseq.$seqel;
                                        }

                               }
                               $subseq=$newseq;
                }

	print "> SEQUENCE $firstel[$i]=$subseq \n\n";
                $j++;
	$subseq=""; $newseq="";
}
 #do{
 #$subseqnew=$subseqnew.$subseq;
#print "$subseqnew \n\n";
 #}until(@firstel[$i]=@firstel[($i+1)]);
 #}





















































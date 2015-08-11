#!/usr/bin/perl
#to extract the intergenic sequences for a given genome.

print "print the name of the sequence file \n";
$file=<>;
chomp$file;
open (o,"$file") || die "cant open $file \n ";
$filename=<o>;
while ($filename=<o>)
{
chomp$filename;
$count=0;$count1=0;$k=0;
@cdx=();@cdy=();@compcdx=();@compcdy=();@interseq=();@elements=();
open (p,"$filename") || die "cant open $filename \n ";
$line=<p>;
while ($line=<p>)
        {
                chomp$line;
                if ($line=~/Location/)
                        {
                                $loc=rindex($line,"Location");
                                $line=substr($line,$loc,(length($line)-$loc));
                                #print $line."\n";
                                if ($line=~/complement/)
                                        {
                                                $line=~s/[a-zL()=]//g;
                                                @fields=split(/\.\./,$line);
                                                $compcdx[$count]=$fields[0];
                                                $compcdy[$count]=$fields[$#fields];                                 #this part takes care whether a join is there or not -if yes then it stores the last element in compcdy
                                                #print "$compcdx[$count],$compcdy[$count]\n";
                                                $count++;
                                                @fields=0;
                                         }

                                else                                                                   # store the start ,stop for the leading strand
                                         {
                                                $line=~s/[a-zL()=]//g;
                                                @fields1=split(/\.\./,$line);
                                                $cdx[$count1]=$fields1[0];
                                                $cdy[$count1]=$fields1[$#fields1];                                 #this part takes care whether a join is there or not -if yes then it stores the last element in compcdy
                                                #print "$cdx[$count1],$cdy[$count1]\n";
                                                $count1++;
                                                @fields1=0;
                                        }
                        }   # initial if brace
              else
                          {
                                   if ($line=~/^[ATGCatgc]{5,10}/  )
                                         {
                                                 #print "sequence \n";
                                                 $num++;
                                                 #$line=~s/[\s+\d]//g;
                                                 chomp($line);
                                                 #print "$line\n";
                                                 $seq=$seq.$line;
                                         }

                         }



       }             # while loop for individual files





# to read sequence

@elements=split(//,$seq);
#print "$#elements ,$num \n";
unshift (@elements,0);
#print "count=$count , count1 =$count1 \n";
#to change all cds into 1s
for ($i=0;$i<$count1;$i++)            #starting from 0th key
        {
         $start=$cdx[$i];
         $stop=$cdy[$i];
         #print "$start  , $stop \n";
         for ($j=$start;$j<=$stop;$j++)         #starting from the start of CDS till stop
                {
                #print "change";
                $elements[$j]=1;
                }
        }
#to replace all complement cds with 2s
for ($k=0;$k<$count;$k++)            #starting from 0th key
        {
         $start=$compcdx[$k];
         $stop=$compcdy[$k];
         #print $start ,$stop ,$compcdy[$k]." comp\n";
         for ($j=$start;$j<=$stop;$j++)
                {
                if ($elements[$j]=~/[a-zA-Z]/)
                        {
                         # print " complement changing \n";
                                $elements[$j]=2;
                        }
                else                      ##overlaps
                        {
                                $elements[$j]=$elements[$j]+2;
                                #print "$elements[$j] , position =$j ";
                        }
                }
          }

#to finally separate the intergenic sequences.
$seq="";
push(@elements,0);
for ($i=1;$i<=$#elements;$i++)
        {
                if ($elements[$i]=~/[a-zA-Z]/)
                        {
                                $seq=$seq.$elements[$i];
                        }
                else
                        {
                                if ($seq ne "")
                                        {
                                        $lengthseq=length($seq);
                                        if ($lengthseq>=50)
                                                {
                                                        push(@interseq,$seq);
                                                }
                                        }
                                $seq="";
                        }
        }
$num=1;
open (OUT,">$filename.intergenic.out") ||die "cant open";
foreach $interseq(@interseq)
{       $len=length($interseq);
        print  OUT">$filename intergenic sequence number $num , length =$len  \n";
        print  OUT"$interseq \n";
        $num++;
}

 close(p);

 close (OUT);
}      #outer while loop
close (o);

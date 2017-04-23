#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Code base of Animesh Sharma [ sharma.animesh@gmail.com ]

#!/usr/bin/perl
print "Name of the file containing multiple sequences in FASTA format : \n";
$file=<STDIN>;
chomp $file;   $least=10000;
$seq="";
open (F,"testseq")||die "cant open  :$!";
while ($line = <F>)
{
        chomp ($line);
        if ($line =~ /^>/)
        {
            $line =~ s/>//;
            push(@seqname,$line);
            if ($seq ne "")
            {
              push(@seq,$seq);
              $seq = "";
            }
        }
        else
        {
            $seq=$seq.$line;
        }
}
push(@seq,$seq);
unshift ( @seq,0);
$num=0;
for ($i=1;$i<=$#seq;$i++)
{
        for($k=1;$k<=$#seq;$k++)
        {
                 if ($i==$k)
                 {
                        $distij[$i][$k]=10000;
                        print "\t$distij[$i][$k]";
                 }
         else
                 {
                        $s=$seq[$i];
                        $t=$seq[$k];
                        alignment($s,$t);
                        $dist=$counter/(length($foutputmat));
                        if ($dist<$least)
                        {
                                $least=$dist;
                                $leastrow=$i;
                                $leastcol=$k;
                        }
                        $distij[$i][$k]=$dist;
                        print "\t$distij[$i][$k]";
                 }
         }
   print "\n";
}
$least[$num]=$least;
$leastrow[$num]=$leastrow;
$leastcol[$num]=$leastcol;
print "  \n$least[$num], row=$leastrow[$num], col=$leastcol[$num]\n\n";
# to begin clustering
$count=$#seq-1;
#print "total seq=$#seq\n";
while ( $count!=1)
{       @copydistij=@distij;
        $least=10000; $dist=$least;
        for ($i=1;$i<=$#seq;$i++)
        {       # print "i=$i ";
                for($k=1;$k<=$#seq;$k++)
                {
                        # print "\tk=$k ";
                        if ($i==$leastrow[$num])
                        {
                                if ($k==$leastcol[$num] or $i==$k)
                                {
                                $distij[$i][$k]=10000;
                                print "\t$distij[$i][$k]";
                                }
                                else
                                {
                                        $dist=(($copydistij[$i][$k])+($copydistij[$leastcol[$num]][$k]))/2;
                                        $distij[$i][$k]=$dist;
                                        print "\t$distij[$i][$k]";
                                }
                        }
                        elsif ($i==$leastcol[$num])
                        {
                        $distij[$i][$k]=10000;
                        print "\t$distij[$i][$k]";
                        }
                        elsif ($k==$leastcol[$num] )
                        {       print "c";
                               $dist=(($copydistij[$i][$k])+($copydistij[$i][$leastrow[$num]]))/2;
                               $distij[$i][$k]=$dist;
                               print "\t$distij[$i][$k]";
                        }
                        elsif ($k==$leastrow[$num])
                        {      print "r";
                               $dist=(($copydistij[$i][$k])+($copydistij[$i][$leastcol[$num]]))/2;
                               $distij[$i][$k]=$dist;
                               print "\t$distij[$i][$k]";
                        }

                        else
                        {       $dist=$distij[$i][$k];
                                print "\t$distij[$i][$k]";
                        }

                        if ($dist<$least)
                        {       print "le";
                                $least=$dist;
                                $leastrow=$i;
                                $leastcol=$k;
                        }

               }
        print "\n";}
        $num++;
        $least[$num]=$least;
        $leastrow[$num]=$leastrow;
        $leastcol[$num]=$leastcol;
        $count--;
        print "  \n$least[$num], row=$leastrow[$num], col=$leastcol[$num]\n\n";
}
#print the least pairs
@leastrow=reverse(@leastrow);
@leastcol=reverse(@leastcol);
 $j=0;
foreach $r(@leastrow)
{
        print " \nleast pair = $r ,$leastcol[$j]";
        $j++;
}

sub alignment {
$gap=-2;
$match=2;
$counter=0; @sequencecol=();@sequencerow=(); @point1=();@fscore1=(); @mysymbol=();
$point;
$foutputmat="";
$foutputrow="";
$foutputcol="";
$outputrow="";
$outputcol="";
$outputmat="";
$sequence=shift;
@sequencerow=split(//,$sequence);      #split each element and store in array
unshift(@sequencerow,0);                    #add 0 as first element
$sequence1=shift;
@sequencecol=split(//,$sequence1);
unshift(@sequencecol,0);
for ($row=0;$row<=$#sequencerow;$row++)        {
              for ($column=0;$column<=$#sequencecol;$column++){
                              if ($row==0 )
                                    {
                                            $fscore1[$row][$column]=$gap*$column;
                                             $point1[$row][$column]="h";
                                             #print "\t $fscore1[$row][$column]  ";
                                    }
                              else{
                                            if ($row>0 and $column==0)
                                                 {
                                                         $fscore1[$row][$column]=$gap*$row;
                                                         $point1[$row][$column]="v";
                                                    #     print "\t $fscore1[$row][$column]  ";

                                                 }
                                            else                                                                   #calculating values for the matching score for i,j
                                                {
                                                 if (($sequencecol[$column]) eq ($sequencerow[$row]))
                                                         {
                                                                 $score=$match;
                                                                 $mysymbol[$row][$column]="|";
                                                         }

                                                  else
                                                          {
                                                                                 $score=0;
                                                                                 $mysymbol[$row][$column]="X";
                                                           }

                                                 $scoreij=$score+$fscore1[$row-1][$column-1];                #calculating the final score for each cell and storing the pointer
                                                 if ($scoreij>(($fscore1[$row-1][$column])+$gap))
                                                         {
                                                                  $fscore=$scoreij;
                                                                  $point='d';
                                                         }
                                                 else
                                                         {
                                                                  $fscore=($fscore1[$row-1][$column])+$gap;
                                                                  $point="v";
                                                         }
                                                 if ($fscore>(($fscore1[$row][$column-1])+$gap))
                                                          {
                                                                 $fscore1[$row][$column]=$fscore;
                                                                 $point1[$row][$column]=$point;
                                                          }
                                                 else
                                                          {
                                                                 $fscore1[$row][$column]=($fscore1[$row][$column-  1])+$gap;
                                                                 $point1[$row][$column]="h";
                                                          }

                                             #    print "\t $fscore1[$row][$column]  ";

                                                 #print "$point1[$row][$column]  ";
                                          }
                                    }
                  }
               # print "\n";
               }


# TRACEBACK
$row--,$column--;
$scorealignment=$fscore1[$row][$column];
while ($row!=0 or $column!=0)
    {

       if ($point1[$row][$column] eq "d")
                 {
                         $outputrow=$outputrow.$sequencerow[$row];
                         $outputcol=$outputcol.$sequencecol[$column];
                         $outputmat=$outputmat.$mysymbol[$row][$column];
                         $row--;$column--;
                 }
       else
                 {
                         if ( $point1[$row][$column] eq "h")
                                 {
                                          $outputrow=$outputrow."-";
                                          $outputcol=$outputcol.$sequencecol[$column];
                                          $outputmat=$outputmat."X";
                                          $column--;
                                  }
                         else
                                  {
                                         $outputrow=$outputrow.$sequencerow[$row];
                                         $outputcol=$outputcol."-";
                                         $outputmat=$outputmat."X";
                                         $row--;
                                  }
                  }
         }
$foutputrow=uc(reverse($outputrow));
$foutputcol=uc(reverse($outputcol));
$foutputmat=reverse($outputmat);
$counter= $foutputmat =~ s/X/X/g;
return $counter;
}
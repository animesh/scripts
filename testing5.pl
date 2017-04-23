#!/perl/user/bin/perl
use Bio::SeqIO;
# use Bio::Seq;
open(FILEHANDLE,"ngbr") ||
              die "can't open $name: $!";
while ($line=<FILEHANDLE>) {
    chomp($line);
    if ($line =~ /\.\./)
    {
    push(@arr,$line) ;
    }
  }
   print "@arr \n";
  @first= shift @arr ;
  print "@first \n";
       foreach $a (@first) {
             @f=split(/\.\./,$a) ;
             }
            print "@f \n";
              @ff=@f[0]-10;
              @fa=@f[1]+10;
             print "@ff \n";
              print "@fa \n";
            @ter=pop @arr;
          print "@ter \n";
          print "@arr \n";
                 foreach $b (@ter) {
                 @t=split(/\.\./,$b);
                 }
                 print "@t \n";
                   @tt=@t[0]-10;
                   @ta=@t[1]+10;
                  print "@tt \n";
                  print "@ta \n";
       print "@arr \n";
                         foreach $c(@arr){
                          @c= split (/\.\./,$c);
                          $xx=@c[0]-10;
                          $yy=@c[1]+10;
                          push (@xx,$xx);
                          push (@yy,$yy);

                          print "@c \n";
                            }
 print "@xx \n";
#push (@xx," ");
  print "@yy \n";
  #$length=@xx;
  #print "$length \n";
  ##########################1 st exon#######################################
  $in  = Bio::SeqIO->new('-file' => "ngb.tfa",
                         '-format' =>'Fasta');
    my $seq = $in->next_seq();
    $x = $seq->subseq(@ff,@fa);
    print "subseq 1st exon @ff - @fa is \n";
   print "$x \n";
    $ffz = $seq->subseq($ff[$i],$ff[$i]+30); # part of the sequence as a string
                              print "$ffz \n";
     while ($ffz=~/ATG/g)
        {
           $atgpos=pos($ffz)+$ff[$d] - 3;
             push(@aa,$atgpos);
              print "ATG at $atgpos\n";
        }
              $faz = $seq -> subseq ($fa[$i]-25, $fa[$i]);
              print "the sequence is $faz \n";
                while ($faz =~ /GT/g)
                  {
                    $gtpos=pos($faz)+$fa[$d]-28;
                       print "matched GT at position ", $gtpos , "\n" ;
                        push (@gt, $gtpos);
                    }
                               foreach $atgpos (@aa)  {
                                      foreach $gtpos (@gt) {
                                            if ($atgpos < $gtpos) {
                  $firstexon = $seq -> subseq($atgpos,$gtpos) ;
                  push (@firstexon,$firstexon) ;   }
                  elsif  ($gtpos<$atgpos) {
                   push (@junk,$junk) ;
                                }
                                                                                }
                                                                           }

                  print "@firstexon \n";
###########################LAST EXON######################################
                                $y=$seq->subseq (@tt,@ta);
                                 print "subseq last exon @tt - @ta is \n";
                                 print "$y \n";

        $ty = $seq->subseq($tt[$i],$tt[$i]+10); # part of the sequence as a string
                                  print "the seq with AG is $ty \n";
                                  while ($ty =~/AG/g)
                                             {
                                             $agpos=pos($ty) + @tt[$e] ;
                                               print "matched AG at position ",$agpos, "\n";
                                                push (@ag,$agpos);
                                                    }

                        $tay = $seq -> subseq ($ta[$i]-25, $ta[$i]);
                        print "the sequence with stop codon is $tay \n";
                                             while ($tay=~/TAG|TGA|TAA/g) {
                                                          $scpos=pos ($tay)+($ta[$i])-26;
                                                            push (@ss,$scpos);
                              print "matched STOP Codon at position",  $scpos ,"\n";
                                                        }
 foreach $agpos (@ag)  {
       foreach $scpos (@ss) {
              if ($agpos < $scpos) {
             $lastexon = $seq -> subseq ($agpos,$scpos) ;
             push (@lastexon,$lastexon) ;
                                                }
                              elsif ($scpos<$agpos) {
                         push (@junk1,$junk1) ;
                                            }
                                        }
                            }
             print "@lastexon \n";
#############################MIDDLE EXONS####################################

    for ($i=0;$i<=$#xx;$i++) {
    $z = $seq->subseq ($xx[$i] ,$yy[$i]);
     print "subseq middle exons $xx[$i] - $yy[$i] is \n";
      print "$z \n";
      print length($z)."length";
      $count=0;
      $count1=0;
              $zz = $seq->subseq($xx[$i],$xx[$i]+20); # part of the sequence as a string
               print "$zz \n";
           while ($zz =~/AG/g)
              {
                 $agmpos=pos($zz) +$xx[$i] ;
                   print "matched AG at position ",$agmpos, "\n";
                                            $agm[$i][$count]=$agmpos;
                                            $count++;
                                          }
                                          $lastag[$i]=$count--;
                                    print "$agmpos \n";
              # print the values for each sequence
                   $yz = $seq -> subseq ($yy[$i]-20, $yy[$i]);
                   print "the sequence is $yz \n";
              while ($yz =~ /GT/g)
                                        {
                                          $gtmpos=pos($yz)+$yy[$i]-23;
                                           print "matched GT at position ", $gtmpos , "\n" ;
                                            $gtm[$i][$count1]=$gtmpos;
                                            $count1++;
                                          }
                                          $lastgt[$i]=$count1--;
              }                        print "$gtmpos \n";
              #print the values for each sequence

               for ($i=0;$i<=$#xx;$i++)
                {      #printing ag positions

                        for ($q=0;$q<=$lastag[$i];$q++)            #
                                {
                                     push (@agm,$agm[$i][$q]) ;
                                       print "$agm[$i][$q] \t";
                                }
                                print "\n";
             }
              for ($i=0;$i<=$#xx;$i++)
                {   #printing gt positions

                        for ($y=0;$y<=$lastgt[$i];$y++)                  #
                                {
                                push (@gtm,$gtm[$i][$y]);
                                        print "$gtm[$i][$y] \t";
                                }
                            print "\n";
                }
           $num=0;
           for($i=0;$i<=$#xx;$i++) {
                for ($j=0;$j<$lastag[$i];$j++){ print " ag pos $agm[$i][$j]  gt pos $gtm[$i][$k] \n";
                    for ($k=0;$k<$lastgt[$i];$k++) {
                      if ($agm[$i][$j] < $gtm[$i][$k]) {   print "ag $agm[$i][$j] , gt $gtm[$i][$k] \n";
                             $exon[$i][$num]=$seq->subseq ($agm[$i][$j],$gtm[$i][$k]);
                            print  "exon[$i][$num] =$exon[$i][$num] \n";
                            $num++; #print "exon =$#exon";
                            }

                    }
                  }
                        #
                        print "$i num\n";  $lastpair[$i]=$num-- ; print "$lastpair[$i] lp\n";  $num=0;  }


                      #print "exon =$#exon";
                 #       }
                        $total= 1;
                   #print "las$#lastpair\n";
                       foreach  $count (@lastpair) {
                       #print "count $count";
                       $total = $total*$count;
                     print " co $count total =$total\n";
                         }
                       $final[0]="a"; $seq="";
                       print "seq10 =$exon[1][0]";
                     while ($#final < $total){
                       for ($i=0 ; $i<=$#xx ; $i++) {
                       $last=$lastpair[$i];
                       #print "last[$i]=$last\n";
                        $el=int(rand($last)) + 0;
                        print "rand[$i]= $el\t";
                        #print "exon0= $exon[0][0]\n";
                        $seq=$seq.$exon[$i][$el];

                        }#print $seq;
                       foreach $str(@final){
                       if ($str eq $seq) { $dec=1;last;}
                       else {$dec=2;}
                       }
                       if ($dec==2) {push (@final,$seq);
                       #open (o,">exonout")|| die;
                      print  "seq=$seq\n";
                       }
                       $seq="";
                       }
                       shift (@final) ;
                       print "total number =$#final \n";
#########################making compelete gene###########################

foreach $firstexon (@firstexon) {
      foreach $lastexon (@lastexon) {
                        foreach $seq (@final) {
                                                 if ($#final eq "") {
                 $gene = $firstexon.$lastexon ;
                 push (@gene,$gene);
           print "the gene has two exons & gene is @gene \n";
                   }
                else {
                         $gene = $firstexon.$seq.$lastexon;
                           push (@gene,$gene);
                    print "the gene is @gene  \n";
      $truncseq    = Bio::Seq->new( -seq => $gene,);
                                         $translation  = $truncseq->translate;
                                         $genea = $translation->seq();
                   #     print "new string ATG - $atgpos - d - $gtpos - a - $agpos - end - $length \n";
                        print "$genea \n";
                                                 }
                                           }
                                        }
                                }
      #        $length = $gene ;
      #        push (@glen,$length);
      #        print "$#glen";
       #       for($co=0;$co<=$#glen;$co++){
       #      if  ($glen[$co] % 3 eq 0) {
      #         push (@acg,$gene[$co]) ;
      #     print "the actual gene is @acg \n";
       #                          $length1=length@acg[1];
        #                         print "$length1 \n";
# }
    #         else {
   #         push (@jx,$gene);
   #        }         }

#  $truncseq    = Bio::Seq->new( -seq => $gene,);
     #                                    $translation  = $truncseq->translate;
     #                                    $genea = $translation->seq();
                   #     print "new string ATG - $atgpos - d - $gtpos - a - $agpos - end - $length \n";
     #                   print "$genea \n";




                          #   print "the actual gene is @acg \n";
                         #        $length1=length@acg[1];
                           #      print "$length1 \n";























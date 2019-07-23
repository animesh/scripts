my %twoBit = ('T' => 0b00,'C' => 0b01,'G' => 0b10,'A' => 0b11, 0b00 => 'T',0b01 => 'C',0b10 => 'G',0b11 => 'A');
my $fasta='TATAA';
print $fasta. length( $fasta ) . "\n";

sub compress2bit{
  my $fasta=shift;
  my @bases = split //, $fasta;
  my $bits = '';
  for my $i ( 0 .. $#bases ) {vec( $bits, $i, 2 ) = $twoBit{ $bases[$i] };}
  return $bits;
}

sub expand2bit{
  my $bits=shift;
  print unpack("b*",$bits), "\n";
  my $strings = '';
  for my $i (0 .. oct("0b" . unpack("%0b2",$bits))-1){$strings.=$twoBit{vec($bits,$i,2)};}
  #print $bits. length($bits) . "\n";
  return $strings;
}

my $strs=compress2bit($fasta);
#print $strs. length($strs) . "\n";

my $exstrs=expand2bit($strs);
print $exstrs. length($exstrs) . "\n";

__END__
use strict;
use warnings;
use Math::BigFloat lib => 'GMP';

#Accuracy upto 100th number

my $levelacc=100;
my $x1=Math::BigFloat->new(-1);
my $x2=Math::BigFloat->new(-1.57);
my $x3=Math::BigFloat->new(-113.1);
my $L1=$x1->bexp($levelacc);
my $L2=$x2->bexp($levelacc);
my $L3=$x3->bexp($levelacc);
my $sum1=($L1);
my $sum2=($L1+$L2);
my $sum3=($L1+$L2+$L3);
print "$L1,$L2,$L3\t$sum1\t$sum2\t$sum3\n";

#Normal Way
$L1=exp(-1);
$L2=exp(-1.57);
$L3=exp(-113.1);
$sum1=($L1);
$sum2=($L1+$L2);
$sum3=($L1+$L2+$L3);
print "$L1,$L2,$L3\t$sum1\t$sum2\t$sum3\n";


chomp($var=shift @ARGV);
 open(PS_F, "ps -fa|");
 while (<PS_F>) {
 ($uid,$pid,$ppid,$c,$stime,$tty,$time,$cmd,$restOfLine) = split;
 #print "$uid,$pid,$ppid,$c,$stime,$tty,$time,$cmd\n$var";
 if ($cmd eq $var){system("kill -9 $pid");}
 }
 close(PS_F);

#!/usr/bin/perl
$testseq="atatatattt";
$k="atatat";
print "$testseq\n$k\n";
#if($testseq =~ /$k/g)
#{
	while($testseq =~ /$k/g)
		{
        $position=pos($testseq);
        #print "$position \n";
        #pos($testseq)=0;
        }
		#}
@test2=qw/w e r t/;
$t=\@test2;
#print "@$t\n";
for($c=0;$c<10;$c++)
{	@test1=qw/r t y u/;
	$test{$c}=@$t[0..(-2)];
}
foreach $w (keys %test) {
	print "$test{$w}\n";
}
#$len=length($testseq);
#$subs=substr($testseq,0,6);
#print "$subs\n$len\n";

while(<>){
	chomp;split(/\s+/);
	#print "@_[0]\n";
	push(@posi,@_[0]);
}
for($c=0;$c<=$#posi;$c++){
	if(@posi[$c+1]-@posi[$c]!=1){
		$start=@posi[$c]-$cnt;
		print "$start\t$cnt\t@posi[$c]\n";
		#print "     COD	     $start..@posi[$c]\n";
		$cnt=0;
	}
	elsif(@posi[$c+1]-@posi[$c]==1){
		$cnt++;
	}
}



#!/usr/bin/perl
system "ls -1>tempfile.perl";
open F,"tempfile.perl";
while ($l=<F>)
{
chomp $l;
push(@NAMES,$l);
}
print "pw,\<matrixname\>,\<matrix name\>,1,pwmatrix,S\n";
foreach $n (@NAMES)
{
$nn=$n;
print " ,$nn,$nn, , , \n";

}
unlink "tempfile.perl";


if( @ARGV ne 1){die "\nUSAGE\t\"ProgName SeqFile\t\n\n\n";}
$file1 = shift @ARGV;
open (F, $file1) || die "can't open \"$file1\": $!";
$seq="";
while ($line = <F>) {
	if ($line =~ /^>/){
		$c++;
		chomp $line;
		push(@seqname1,$line);
		if ($seq ne ""){
			push(@seq1,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@seq1,$seq);
close F;
$per=10;
@base=qw/A T G C/;
#open(FT,">$file1.errinj");
for($c1=0;$c1<=$#seq1;$c1++){
	$len=length($seq1[$c1]);
	$toterr=int($len*$per/100);
	$errornum=int(rand($toterr));
	while($errornum>0){
		$errornum--;
                $pcl = int(rand($len));
                #$pcl = int(gaussian_rand()*$len);
		substr($seq1[$c1], $pcl, 1) = "$base[int(rand(4))]";
	}
	print "$errornum-$pcl-$c1-$per-$toterr-$len-$seqname1[$c1]\n";
	#print FT"$seqname1[$c1]\n$seq1[$c1]\n";

}
#close FT;

sub gaussian_rand {
    my ($u1, $u2);  # uniformly distributed random numbers
    my $w;          # variance, then a weight
    my ($g1, $g2);  # gaussian-distributed numbers

    do {
        $u1 = 2 * rand() - 1;
        $u2 = 2 * rand() - 1;
        $w = $u1*$u1 + $u2*$u2;
    } while ( $w >= 1 );

    $w = sqrt( (-2 * log($w))  / $w );
    $g2 = $u1 * $w;
    $g1 = $u2 * $w;
         return wantarray ? ($g1, $g2) : $g1;
}

#!/usr/bin/perl
print "\n---The Answer Lies In The Genome---\n";
system("fortune");

while(<>){
chomp;
$c++;
$_=~s/\s+||\"//g;
if($c%3==0){print "$_\n";}
else{print "$_,";}
}

#!/usr/bin/perl
open(F,"cnall.txt");
$out="cnallformatted.txt";
while ($line = <F>) {
        #chomp ($line);
	$line=~s/\s+/ /g;
	@t1=split(/ /,$line);
	$t2=@t1[2];
	push(@list,$t2);
}
	%seen=();
	@combos = grep{ !$seen{$_} ++} @list;
foreach $t3 (@combos)
	{
	print "$t3\n"
	}
close F;

#$c=shift @ARGV;

print rec(10);

sub rec {
    $c=shift;
    chomp $c;
	while($c>=0){
	    $t=recur($c);
	    print "Term $c => $t\n";
	    $c--;}
    sub recur{
	my $n=shift;
	if($n==1){return 1;}
	elsif($n<1){return 0;}
	else{return(recur($n-1)+recur($n-2))};
    }
}

sub ite{
    $c=shift;
    chomp $c;
    iter($c);
    sub iter{
	$x1=0;
	$x2=1;
	for($i=0;$i<$c;$i++){
	    print "$x1\n";
	    ($x1,$x2)=($x1+$x2,$x1);
	}
    }
}

sub factorial {
    my $number = shift @_;
    return undef if $number < 0; # illegal value
    return 1 if $number == 0;

    my $factorial = 1;
    for (my $i = $number; $i > 1; $i--) {
	$factorial = $factorial * $i;
    }
    return $factorial;
}
Code base of Animesh Sharma [ sharma.animesh@gmail.com ]

sub factorial {
    my $number = shift @_;
    return undef if $number < 0; # illegal value
    return 1 if $number == 0;

    return( $number * factorial($number -1) );
}
#!/usr/bin/perl
$x=1;
$f=1;
$lim=shift @ARGV;
while($c<$lim){
	$c++;
	print "$c\t$x\t";
#	$x1=-1*$x2;
	$x1=$x2;
	$x2=$x;
	$x=$x1+$x2;
	$f*=$c;
	$fr=$f/($x/$x2);
	print $x/$x2,"\t$f\t$fr\n";
}


#!/usr/local/bin/perl -w
use strict;

use Bio::SeqIO;
use Bio::Root::IO;
use Algorithm::Diff qw(diff LCS);
use IO::ScalarArray;
use IO::String;

my %files = ( 
#'test.embl'      => 'embl',
#	      'test.ace'       => 'ace',
	      'test.fasta'     => 'fasta',
#	      'test.game'      => 'game',
	      'test.gcg'       => 'gcg',
#	      'test.genbank'   => 'genbank',
	      'test.raw'       => 'raw',
#	      'test_badlf.gcg' => 'gcg'
	      );

while( my ($file, $type) = each %files ) {
    my $filename = Bio::Root::IO->catfile('t','data',$file);
    print "processing file $filename\n";
    open(FILE, "< $filename") or die("cannot open $filename");
    my @datain = <FILE>;
    my $in = new IO::String(join('', @datain));
    my $seqin = new Bio::SeqIO( -fh => $in,
				-format => $type);
    my $out = new IO::String;
    my $seqout = new Bio::SeqIO( -fh => $out,
				 -format => $type);
    my $seq;
    while( defined($seq = $seqin->next_seq) ) {	
	$seqout->write_seq($seq);
    }
    $seqout->close();
    $seqin->close();
    my $strref = $out->string_ref;
    my @dataout = map { $_."\n"} split(/\n/, $$strref );
    my @diffs = &diff( \@datain, \@dataout);
    foreach my $d ( @diffs ) {
	foreach my $diff ( @$d ) {
	    chomp($diff->[2]);
	    print $diff->[0], $diff->[1], "\n>", $diff->[2], "\n";
	}
    }
    if( @diffs ) {
	print "in is \n", join('', @datain), "\n";
	print "out is \n", join('',@dataout), "\n";	
    }
}
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






















use lib '/usit/titan/u1/ash022/IPC-Run-0.90/lib';;
use lib '/usit/titan/u1/ash022/GraphViz-2.04/lib'; 
      use GraphViz;

      my $g = GraphViz->new();

      $g->add_node('London');
      $g->add_node('Paris', label => 'City of\nlurve');
      $g->add_node('New York');

      $g->add_edge('London' => 'Paris');
      $g->add_edge('London' => 'New York', label => 'Far');
      $g->add_edge('Paris' => 'London');

      print $g->as_png;

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

open(F,@ARGV[0]);
open(FO,">@ARGV[0].csv");
$ftr=3;
$otp=2;

print FO"F1,F2,F3,Output\n";

while($l=<F>){
	@t=split(/\s+/,$l);
	for($c=0;$c<$ftr;$c++){
		$out=@t[$c]+0;
		#if($c!=25){
			print FO"$out,";
		#}
	}
	for($c=$ftr;$c<$ftr+$otp;$c++){
		$out=@t[$c]+0;
		if($out==1){
			$fout=$c-$ftr;
			print FO"O$fout\n";
			#print FO"$fout\n";
		}
	}
}

system("java weka.core.converters.CSVLoader @ARGV[0].csv > @ARGV[0].arff");
#system("java weka.classifiers.functions.LinearRegression -t @ARGV[0].arff -x 5");
system("java weka.classifiers.meta.ClassificationViaRegression -t @ARGV[0].arff -W weka.classifiers.trees.M5P -- -M 4.0");
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
# test_source_gbk.pl     sharma.animesh@gmail.com     2006/09/10 12:14:03

use warnings;
use strict;
$|=1;
use Data::Dumper;
use Bio::SeqIO;
my $file=$ARGV[0];
my $number=1;
get_other_source($file,$number);

my $n_other_source;
my %other_source_sequence_name;
my %other_source_sequence;

sub get_other_source{
    my $foofile=shift;
    my $foofileno=shift;
    my $seqio_object = Bio::SeqIO->new(-file => $foofile, '-format' => 'GenBank');
    my $seq_object = $seqio_object->next_seq;
    print "$foofile\t$foofileno\n";
    for my $feat_object ($seq_object->get_SeqFeatures) {
	if ($feat_object->primary_tag eq "source") { 
			my $start = $feat_object->location->start;       
			my $end = $feat_object->location->end;
			my $sequence = $feat_object->entire_seq->seq;
			my $length_sequence=length($sequence);
			my $seq_name;
			    for my $tag ($feat_object->get_all_tags) {
				    for my $value ($feat_object->get_tag_values($tag)){
					$seq_name.="$value ";
				}
			    }       
			$n_other_source++;
			$seq_name.="$start-$end($length_sequence)";
			$seq_name="$foofile ($n_other_source)".$seq_name;
			$other_source_sequence_name{$n_other_source}=$seq_name;
			$other_source_sequence{$n_other_source}=$sequence;
		    }
    }
}

foreach (keys %other_source_sequence_name){
    print "$other_source_sequence_name{$_}\n$other_source_sequence{$_}\n";
}
__END__

=head1 NAME

test_source_gbk.pl

=head1 SYNOPSIS



=head1 DESCRIPTION

Stub documentation for test_source_gbk.pl, 
created by template.el.

It looks like the author of this script was negligent 
enough to leave the stub unedited.

=head1 AUTHOR

Animesh Sharma, E<lt>krishna_bhakt@BHAKTI-YOGAE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Animesh Sharma

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

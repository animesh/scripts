#!usr/bin/perl
print "Enter the filename containing the first sequence: ";
$afile=<>;
open (FILENAME, "$afile") ||
die "can't open the file: $!";
while ($aname=<FILENAME>)
{
chomp $aname;
$an=$an.$aname;
}
close (FILENAME, "$afile");
@aa=split(//,$an);
$alen=@aa;
print "Enter the filname containing the second sequence: ";
$bfile=<>;
open (FILENAME, "$bfile") ||
die "can't open the file: $!";
while ($bname=<FILENAME>)
{
chomp $bname;
$bn=$bn.$bname;
}
@bb=split(//,$bn);
$blen=@bb;

#reading the substitution matrix as an 2-D array.
print "Enter the filename containing substitution matrix: ";
$sfile=<>;
open (FILENAME, "$sfile")||
die "can't open the file: $!";
while ($name=<FILENAME>)
{
$sname=$sname.$name
}
$i=0;
for ($row=1;$row<=21;$row++)
{
$col=0;
while($col!=$row+1)
{
@line=split (/\s+/,$sname);
$mat[$col][$row]=$mat[$row][$col]=@line[$i];
$i++;
$col++;
}
}

print "Enter the gap penulty: ";
$g=<>;
chomp $g;
print "Enter the algorithm of choice: Needleman-Wunsch(A) or Overhang(B) or Smith-Waterman(C): ";
$algo=<>;
chomp $algo;

open (FILEOUT,'>out.txt');
#building up the hash to store the values of amino acid pairs
for ($row=1;$row<21;$row++)
{
for ($col=1;$col<21;$col++)
{
$amino=$mat[$row][0].$mat[0][$col];
push (@amino,$amino);
$value=$mat[$row][$col];
push (@value,$value);
}
}
$len=@value;
for ($i=0;$i<$len;$i++)
{
$hash{@amino[$i]}=@value[$i];
}

#for Needleman-Wunsch
if ($algo eq 'A')
{
#building the first row & first column of scoring matrix
for ($j=0;$j<=$blen;$j++)
{
for ($i=0;$i<=$alen;$i++)
{
if (($i==0) && ($j==0))
{
$sc[0][0]=0;
}
elsif (($i==0) && ($j!=0))
{
$sc[0][$j]=$j*$g;
}
elsif (($i!=0) && ($j==0))
{
$sc[$i][0]=$i*$g;
}
}
}
#actual construction of scoring matrix
for ($j=1;$j<=$blen;$j++)
{
for ($i=1;$i<=$alen;$i++)
{
$s=$hash{@aa[$i-1].@bb[$j-1]};
$x=$sc[$i-1][$j-1]+$s;
$y=$sc[$i-1][$j]+$g;
$z=$sc[$i][$j-1]+$g;
if ($x>=$y && $x>=$z)
{
$smax=$x;
$tm[$i-1][$j-1]='X';
}
elsif ($y>$x && $y>=$z)
{
$smax=$y;
$tm[$i-1][$j-1]='Y';
}
else
{
$smax=$z;
$tm[$i-1][$j-1]='Z';
}
$sc[$i][$j]=$smax;
}
}
$sm=$sc[$alen][$blen];
#Traceback
$i--;
$j--;
while (($i!=0) && ($j!=0))
{
        if ($tm[$i-1][$j-1] eq 'X')
        {
                $opa=$opa.@aa[$i-1];
                $opb=$opb.@bb[$j-1];
                $i--,$j--;
        }
                else
                {
                        if ($tm[$i-1][$j-1] eq 'Y')
                        {
                                $opa=$opa.@aa[$i-1];
                                $opb=$opb."-";
                                $i--;
                        }
                                else
                                {
                                $opa=$opa."-";
                                $opb=$opb.@bb[$j-1];
                                $j--;
                                }
                }
}
}

#for overhang
elsif ($algo eq 'B')
{
#building first row & first column of scoring matrix
for ($j=0;$j<=$blen;$j++)
{
for ($i=0;$i<=$alen;$i++)
{
if (($i==0) && ($j==0))
{
$sc[0][0]=0;
}
elsif (($i==0) && ($j!=0))
{
$sc[0][$j]=0;
}
elsif (($i!=0) && ($j==0))
{
$sc[$i][0]=0;
}
}
}
#actual construction of scoring matrix
for ($j=1;$j<=$blen;$j++)
{
for ($i=1;$i<=$alen;$i++)
{
$s=$hash{@aa[$i-1].@bb[$j-1]};
$x=$sc[$i-1][$j-1]+$s;
$y=$sc[$i-1][$j]+$g;
$z=$sc[$i][$j-1]+$g;
if ($x>=$y && $x>=$z)
{
$smax=$x;
$tm[$i-1][$j-1]='X';
}
elsif ($y>$x && $y>=$z)
{
$smax=$y;
$tm[$i-1][$j-1]='Y';
}
else
{
$smax=$z;
$tm[$i-1][$j-1]='Z';
}
$sc[$i][$j]=$smax;
}
}
        for ($j=0;$j<=$blen;$j++)
        {
        for ($i=0;$i<$alen;$i++)
        {
        if ($sm<=$sc[$i][$j])
        {
        $sm=$sc[$i][$j];
        $k=$i;
        $l=$j;
        }
        }
        }

        while (($k!=0 && $l!=0) && $sc[$k][$l]!=0 )
        {
        if ($tm[$k-1][$l-1] eq 'X')
        {
        $opa=$opa.@aa[$k-1];
        $opb=$opb.@bb[$l-1];
        $k--,$l--;
        }
                else
                {
                        if ($tm[$k-1][$l-1] eq 'Y')
                        {
                        $opa=$opa.@aa[$k-1];
                        $opb=$opb."-";
                        $k--;
                        }
                                else
                                {
                                $opa=$opa."-";
                                $opb=$opb.@bb[$l-1];
                                $l--;
                                }
                }
        }
}

#for Smith-Waterman
elsif ($algo eq 'C')
{
#building first row & first column of matrix
for ($j=0;$j<=$blen;$j++)
        {
        for ($i=0;$i<=$alen;$i++)
        {
        if (($i==0) && ($j==0))
        {
        $sc[0][0]=0;
        }
        elsif (($i==0) && ($j!=0))
        {
        $sc[0][$j]=0;
        }
        elsif (($i!=0) && ($j==0))
        {
        $sc[$i][0]=0;
        }
        }
        }
 #actual construction of scoring matrix
        for ($j=1;$j<=$blen;$j++)
        {
        for ($i=1;$i<=$alen;$i++)
        {
        $s=$hash{@aa[$i].@bb[$j]};
        $x=$sc[$i-1][$j-1]+$s;
        $y=$sc[$i-1][$j]+$g;
        $z=$sc[$i][$j-1]+$g;
        if ($x>=$y && $x>=$z)
        {
        $smax=$x;
        $tm[$i-1][$j-1]='X';
        }
        elsif ($y>$x && $y>=$z)
        {
        $smax=$y;
        $tm[$i-1][$j-1]='Y';
        }
        else
        {
        $smax=$z;
        $tm[$i-1][$j-1]='Z';
        }
        if ($smax<0)
        {
        $smax=0;
        $tm[$i-1][$j-1]='O';
        }
        $sc[$i][$j]=$smax;
        }
        }


        for ($j=0;$j<=$blen;$j++)
        {
        for ($i=0;$i<$alen;$i++)
        {
        if ($sm<=$sc[$i][$j])
        {
        $sm=$sc[$i][$j];
        $k=$i;
        $l=$j;
        }
        }
        }

        while (($k!=0 && $l!=0) && $sc[$k][$l]!=0 )
        {
        if ($tm[$k-1][$l-1] eq 'X')
        {
        $opa=$opa.@aa[$k-1];
        $opb=$opb.@bb[$l-1];
        $k--,$l--;
        }
                else
                {
                        if ($tm[$k-1][$l-1] eq 'Y')
                        {
                        $opa=$opa.@aa[$k-1];
                        $opb=$opb."-";
                        $k--;
                        }
                                else
                                {
                                $opa=$opa."-";
                                $opb=$opb.@bb[$l-1];
                                $l--;
                                }
                }
        }
}
print "The Scoring matrix: \n";
print FILEOUT "The Scoring matrix: \n";
for ($j=0;$j<=$blen;$j++)
{
for ($i=0;$i<=$alen;$i++)
{
print "$sc[$i][$j]\t";
print FILEOUT "$sc[$i][$j]\t";
}
print FILEOUT "\n";
print "\n";
}
$fopa=reverse($opa);
$fopb=reverse($opb);
@fa=split(//,$fopa);
@fb=split(//,$fopb);
$a1=@fa;
for ($i=0;$i<$a1;$i++)
{
if (@fa[$i] eq @fb[$i])
{
$fc=$fc."|";
}
else
{
$fc=$fc." ";
}
}
@fc=split(//,$fc);
print "The max. score is $sm\n$fopa\n$fc\n$fopb\n";
print FILEOUT "The max. score is $sm\n$fopa\n$fc\n$fopb\n";


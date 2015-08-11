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
print "Enter the name of the file: ";
$filename=<>;
open (FILENAME,$filename) ||
       die "can't open $name: $!";
while ($line = <FILENAME>) {
	chomp ($line);
             $line =~ s/\///;
             if($line =~ /CDS/){
                if($line =~ /join/)
                        {unless($line =~ /\)/)
                                {
                                        do{
                                        $linenew=<FILENAME>;
                                        chomp ($linenew);
                                        $line = $line.$linenew;
                                                }until ($line =~ /\)/)
                                }
                        }
             $line =~ s/\(//;
	     $line =~ s/\)//;
	     $line =~ s/join//;
	     $line =~ s/CDS//;
	     push(@cds,$line);
             }
}
foreach $w (@cds)
{
@done=split(/,/,$w);
foreach $ww (@done)
{
@no=split(/\.\./,$ww);
$ans=(@no[1]+1)-@no[0];
push(@a,$ans);
}
}
$counter=1;
foreach $t (@a)
{
$r=$t%3;
if($r==1)
{
push(@rem,$r)
}
if($r==0)
{
push(@rem,$r);
}
if($r==2)
{
push(@rem,$r);
}
}
print "The phase of Exon $counter is @rem[0]\n";
$chek=@rem;
foreach $rema (@rem)
{
if($rema=~/1/)
{
push (@newr,2);
}
if($rema=~/2/)
{
push (@newr,1);
}
if($rema=~/0/)
{
push (@newr,0);
}
}
$cc=0;
for($c=0;$c<$chek;$c++)
{
$cc=$cc+@newr[$c];
push(@cumulr,$cc);
}
$er=2;
for($ccc=1;$ccc<$chek;$ccc++)
{
$temp=@a[$ccc]+@cumulr[$ccc-1];
if($temp%3==1)
{print "The Phase of Exon $er is 1\n";}
if($temp%3==0)
{print "The Phase of Exon $er is 0\n";}
if($temp%3==2)
{print "The Phase of Exon $er is 2\n";}
$er++;
}

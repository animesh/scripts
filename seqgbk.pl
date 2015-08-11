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

#!usr/bin/perl
$f1 = "ecol_K12_MG1655genome.gbk";
$f2="ecolk12.fas";
open(E,">$f2")||die "can't open $f2";

open(F2,"ecol_K12_MG1655genome.gbk")||die "can't open F";

while ($l=<F2>){	
	if($l=~/^ORIGIN/){
		while($ll=<F2>)
                {
                $ll=~s/[0-9]//g;$ll=~s/\s+//g;$ll=~s/\/\///g;$ll=~s/\\\\//g;chomp $ll;$line.=$ll;
                }
        }
}
$le=length($line);
close F2;
print E">$f1: 1-$le\n$line\n";

#while($lin=<F>)
#{
# @t1=split(/\s+/,$lin);
# #foreach  (@t1) {print "$c\t $_ \n";$c++;}#print "@t1[5]\n";
# $pos=@t1[3];
# if($pos=~/^complement/){
#	 $pos=~s/complement|\(|\)//g;
#	 @t2=split(/\.\./,$pos);$st=@t2[1];$sp=$st+1000;
#	 $str = uc(substr($line,($st),(1000)));
#	 $str = reverse ($str);
#	 $str =~ tr/ATCG/TAGC/d;
#	 $len=length($str);
#	 print "comp @t2[0] @t2[1]\n";
#	 print E">Reverse\t[$st-$sp] for gene [@t2[0]-@t2[1]]\tlen-$len\n$str\n";
# }
# else {
#	 @t2=split(/\.\./,$pos);$st=@t2[0];$sp=$st-1001;
#	 $str = uc(substr($line,($sp),(1000)));
#	 $len=length($str);
#	 print E">Forward\t[$st-$sp] for gene [@t2[0]-@t2[1]]\tlen-$len\n$str\n";
#	 print "main @t2[0] @t2[1]\n";
# }
#}
#
#close F;close E;
#

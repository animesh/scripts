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
#final NCDS extractor based on the chi stat
$file=shift @ARGV;
$file2=shift @ARGV;
$pk=shift @ARGV;
$choose= shift @ARGV;
open(F,$file)||die "can't open";
open(F2,$file2)||die "can't open";
while ($line = <F>) {
        chomp ($line);
        @n=split(/\t/,$line);@n[4]=~s/\s+//g;
#	foreach $w (@n){print "$c=>$w\n";$c++}$c=0;
	if($choose eq "l" and @n[4] <= $pk){
	$lto{@n[2]}=@n[4];}	
	elsif($choose eq "m" and @n[4] >= $pk){
	$lto{@n[2]}=@n[4];}
	
}
close F;
while ($l=<F2>){	
	if($l=~/^ORIGIN/){
		while($ll=<F2>)
                {
                $ll=~s/[0-9]//g;$ll=~s/\s+//g;chomp $ll;$line.=$ll;
                }
        }
}
close F2;
$line=($line);$line=~s/\///g;1/1;$seql=length($line);
foreach $w (keys %lto){
#print "$w\t$lto{$w}\n";
$seqname=$w;
@t1=split(/\s+|\[|\]|\_|\-|\,|\:|\n|\t/,$seqname);
#$t1[0]=~s/\>|\s+//g;
$c2=0;#foreach $w (@t1){print "$c2 \t $w\n";$c2++;}
$st=@t1[1]+0;$sp=@t1[2]+0;$length=$sp-$st+1;
$str = uc(substr($line,($st-1),($length)));
$t11=@t1[0];$t11=~s/\>|\s+//g;
if($t11 eq "cIntergenic"){
#$st=@t1[2]-@t1[9]+1-3;$sp=@t1[2]-@t1[6]+1;$length=$sp-$st+1;$str = uc(substr($line,($st-1),($length)));
$str = reverse ($str);
$str =~ tr/ATCG/TAGC/d;
if(($length >= 30) and ($length <= 153)){
print "$seqname\t[$st-$sp]\t$length\t$lto{$w}\t$file\n$str\n";
}
}
elsif($t11 eq "Intergenic" and ($length >= 30) and ($length <= 153)){
print "$seqname\t[$st-$sp]\t$length\t$lto{$w}\t$file\n$str\n";
}
}

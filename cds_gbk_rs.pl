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

$f=shift@ARGV;$ff=shift@ARGV;
open F,$f;open FF,$ff;
$f1=$ff."fsf.ffn";
open F1,">$f1";
while($l=<F>){
if($l=~/^ORIGIN/)
        {        while($ll=<F>)
                {

                $ll=~s/[0-9]//g;$ll=~s/\s+//g;chomp $ll;$ll=~s/\/\///g;$line.=$ll;
                }
        }
}
close F;
$line=uc($line);$rline=reverse($line);
$rline =~ tr/ATCG/TAGC/d;$lgo=length($rline);
while($ll=<FF>){
	chomp $ll;
	@t=split(/\s+/,$ll);
	$min=$lgo-@t[2]+1;$tmax=$lgo-@t[5]+1;
	$seq = substr($rline,($min-1),($tmax-$min+1));$len=length($seq);
	print F1"$ll\t$len\n$seq\n";
}
 
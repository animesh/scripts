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

$f=shift@ARGV;
open F,$f;$f1=$f."fs.ffn";$f2=$f."rs.ffn";
open F1,">$f1";
open F2,">$f2";
while($l=<F>){
if($l=~/^ORIGIN/)
        {        while($ll=<F>)
                {

                $ll=~s/[0-9]//g;$ll=~s/\s+//g;chomp $ll;$ll=~s/\/\///g;$line.=$ll;
                }
        }
}
close F;
$line=uc($line);
$len=length($line);
print F1">Complete Gen Seq of $f\tLength-$len\tFS\n$line\n";
print F2">Complete Gen Seq of $f\tLength-$len\tRS\n$line\n";

 
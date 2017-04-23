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
open(F,"UASorfsyeast.txt")||die "can't open";
open(FF,"237f.txt")||die "can't open";
open(FO,">237UASorfsyeast.txt");
    #    print FO"\>$line";
$seq = "";
while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             @seqn=split(/\t/,$line);
             push(@seqname,@seqn[0]);
             $cc++;
            if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {
                  $seq=$seq.$line;
      }
}
push(@seq,$seq);
while ($l = <FF>) {
        chomp ($l);
        push(@li,$l);
}
# print "@li,\t@seqname\n";
foreach $like (@li)
{foreach $likess (@seqname)
{       if($like=~$likess)
                {print "$like\t$likess\n";}
}
}
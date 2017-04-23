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
$file=shift @ARGV;undef @seqname;undef @seq;
$seq="";
open(F,$file)||die "can't open";
while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             @seqn=split(/\t/,$line);
		#$snames=@seqn[0];
		$snames=$line;
		chomp $snames;
             push(@seqname,$snames);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}push(@seq,$seq);close F;
$fileld=$file.".ld";
$fileprop=$file.".prop";
open(FLD,">$fileld");
open(FLPROP,">$fileprop");

for($fot=0;$fot<=$#seq;$fot++){
$seqcon=uc(@seq[$fot]);
$seqcon=~s///g;
$seqn=@seqname[$fot];chomp $seqn;
$seqn=~s/\s+/\_/g;
$seqgc=uc(@seq[$fot]);
$gc=$seqgc=~s/G|C//g;
$l=length($seqcon);
print FLPROP"$seqn\t$l\t$gc\n";
$m{$l}+=1;
}

foreach $w (sort {$a<=>$b} keys %m){print FLD"$w\t$m{$w}\n";$t+=$m{$w};}


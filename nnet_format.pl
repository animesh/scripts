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
#open(F,"promoter_ecoli_301_nregion.fas");
open(F,"t1.fas");
open(W,">nnet_663_formatted.fas");

@og=qw/0 0 0 1 0 0 1 0 0 1 0 0 1 0 0 0 1 1 1 1/;
@bs=qw/A C G T X/;

$lenbs=@bs;

while($l=<F>){
	chop $l;
	@t=split(//,$l);
	if(@t[0] eq ">"){
		next;
	}
	else{
		$lent=@t;
		for($st=0; $st<($lent-81); $st++){
			print "$lent\t$lenbs\n";
			for($c=$st;$c<($st+81);$c++){
				for($cc=0;$cc<$lenbs;$cc++){
					if(@bs[$cc] eq  @t[$c]){
						for($ccc=(4*$cc);$ccc<(4*$cc+4);$ccc++){
							print W "@og[$ccc] ";
						}
					}
				}
			}
			if($st < 30){
				$out = 0;
			}
			elsif($st<111){
				$out = ($st-30)/80;
			}
			elsif($st<191){
				$out = (190-$st)/80;
			}
			else{
				$out = 0;
			}
			print W "\t$out";
			print W "\n";
		}
	}
}
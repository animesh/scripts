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
$f=shift @ARGV;
open(F,$f);
while($l=<F>){
		chomp $l;
		$l=uc($l);
		$l=~s/\r/\n/g;
		$l=~s/\s+$//g;
		if($l eq ""){next;}
		@t=split(/,/,$l);
#		for($c=0;$c<$#t;$c++){
#			print "@t[$c],";
#		}
#		@t=split(//,@t[$c]);
		print "@t[0],POS,";
		@t=split(//,@t[2]);
		for($c=0;$c<$#t;$c++){
			print "@t[$c],";
		}
		print "@t[$c]\n";

		@st=split(/,/,$l);
#		for($c=0;$c<$#st;$c++){
#			print "@st[$c]-M,";
#		}
#		@st=split(//,@st[$c]);
		print "@st[0]-M,NEG,";
		@st=split(//,@st[2]);
		shuffle(\@st);
		for($c=0;$c<$#st;$c++){
			print "@st[$c],";
		}
		print "@st[$c]\n";

}

		for($c=0;$c<$#t;$c++){
			print "C-$c,";
		}
			print "C-$c\n";


    sub shuffle {
        my $deck = shift;
        my $i = @$deck;
        while ($i--) {
            my $j = int rand ($i+1);
            @$deck[$i,$j] = @$deck[$j,$i];
        }
    }



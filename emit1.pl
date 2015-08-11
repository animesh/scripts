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
$f="sam1.txt";
$fileformat=$f.".lc.txt";
open(FO,">$fileformat");
open(F,$f);

while($line=<F>){
	chomp $line;
	$l=$line;
	$linf=lc($l);
	$linf=~s/<a>|<b>|<r>|<\/a>|<\/b>|<\/r>|\./ /g;
	$linf=~s/^\s+//g;
	$linf=~s/\s+$//g;
	$linf=~s/\s+/ /g;
	print FO"$linf\n";
	if($line=~m/<a>(.*)<\/a>/i){
		push(@a,lc($1));
		$line=~s/<a>(.*)<\/a>//g;
	}
	if($line=~m/<r>(.*)<\/r>/i){
		push(@r,lc($1));
		$line=~s/<r>(.*)<\/r>//g;
	}
	if($line=~m/<b>(.*)<\/b>/i){
		push(@a,lc($1));
		$line=~s/<b>(.*)<\/b>//g;
	}
	$line=~s/\.|;|\'|\"|,|:|`|\(|\)|\<|\>|\?|\!//g;
	@t=split(/\s+/,$line);
	for($i=0;$i<=$#t;$i++){
		push(@c,@t[$i]);
	}
}
undef %saw;
@au = grep(!$saw{$_}++, @a);
undef %saw;
@bu = grep(!$saw{$_}++, @b);
undef %saw;
@cu = grep(!$saw{$_}++, @c);
undef %saw;
@ru = grep(!$saw{$_}++, @r);
foreach (@cu){
	print "$_\n";
}

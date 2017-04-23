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
		$line=~s/<a>(.*)<\/a>/ /g;
	}
	if($line=~m/<r>(.*)<\/r>/i){
		push(@r,lc($1));
		$line=~s/<r>(.*)<\/r>/ /g;
	}
	if($line=~m/<b>(.*)<\/b>/i){
		push(@b,lc($1));
		$line=~s/<b>(.*)<\/b>/ /g;
	}
	$line=~s/\.|;|\'|\"|,|:|`|\(|\)|\<|\>|\?|\!//g;
	@t=split(/\s+/,$line);
	for($i=0;$i<=$#t;$i++){
		@t[$i]=~s/ //g;
		if(@t[$i] ne ""){
			push(@c,@t[$i]);
		}
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

close F;
close FO;

$fo=$f;
$fo=~s/^\.txt//g;
$filetrans=$fo.".trans";
open(FT,">$filetrans");
$fileemit=$fo.".emit";
open(FE,">$fileemit");

$la=@au;$lap=1/$la;$lapval=sprintf("%.3f", $lap);
foreach (@au){
	print FE"a\t$_\t$lapval\n";
}
$la=@bu;$lap=1/$la;$lapval=sprintf("%.3f", $lap);
foreach (@bu){
	print FE"b\t$_\t$lapval\n";
}
$la=@cu;$lap=1/$la;$lapval=sprintf("%.3f", $lap);
foreach (@cu){
	print FE"c\t$_\t$lapval\n";
}
$la=@ru;$lap=1/$la;$lapval=sprintf("%.3f", $lap);
foreach (@ru){
	print FE"r\t$_\t$lapval\n";
}


print FT"INIT\n";
print FT"INIT	a	0.25\n";
print FT"INIT	b	0.25\n";
print FT"INIT	c	0.25\n";
print FT"INIT	r	0.25\n";
print FT"a	b	0.25\n";
print FT"a	c	0.25\n";
print FT"a	r	0.25\n";
print FT"a	FINAL	0.25\n";
print FT"b	a	0.25\n";
print FT"b	c	0.25\n";
print FT"b	r	0.25\n";
print FT"b	FINAL	0.25\n";
print FT"c	a	0.25\n";
print FT"c	b	0.25\n";
print FT"c	r	0.25\n";
print FT"c	FINAL	0.25\n";
print FT"r	a	0.25\n";
print FT"r	b	0.25\n";
print FT"r	c	0.25\n";
print FT"r	FINAL	0.25\n";

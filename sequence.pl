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

if(@ARGV==1){
	$file=shift @ARGV;
}

else{
	die"Program Usage:perl prog_file_name fasta_file_name\n";
}

open F, "$file" or die "Can't open $file : $!";
my $l="";
while($line=<F>){
	chomp $line;
	if($line!~/^>/){
		$l.=$line;
	}
}

isRNA($l);
isDNA($l);
isProtein($l);

sub isDNA{
	my $s=shift;
	my $a=$s=~s/A/A/g;
	my $t=$s=~s/T/T/g;
	my $g=$s=~s/G/G/g;
	my $c=$s=~s/C/C/g;
	my $tot=length($s);
	if($tot==($a+$t+$c+$g)){
		print "The fasta file $file contains a DNA sequence\n";
	}
}

sub isRNA{
	
	my $s=shift;
	my $tot=length($s);
	my $a=$s=~s/A/A/g;
	my $t=$s=~s/U/U/g;
	my $g=$s=~s/G/G/g;
	my $c=$s=~s/C/C/g;
	if($tot==($a+$t+$g+$c)){
		print "The fasta file $file contains a RNA sequence\n";
	}
}

sub isProtein{
	my $s=shift;
	my $a=$s=~s/A/A/g;
	my $c=$s=~s/C/C/g;
	my $d=$s=~s/D/D/g;
	my $e=$s=~s/E/E/g;
	my $f=$s=~s/F/F/g;
	my $g=$s=~s/G/G/g;
	my $h=$s=~s/H/H/g;
	my $i=$s=~s/I/I/g;
	my $k=$s=~s/K/K/g;
	my $b=$s=~s/L/L/g;
	my $m=$s=~s/M/M/g;
	my $n=$s=~s/N/N/g;
	my $p=$s=~s/P/P/g;
	my $q=$s=~s/Q/Q/g;
	my $r=$s=~s/R/R/g;
	my $z=$s=~s/S/S/g;
	my $t=$s=~s/T/T/g;
	my $v=$s=~s/V/V/g;
	my $w=$s=~s/W/W/g;
	my $y=$s=~s/Y/Y/g;
	my $tot=length($s);
	if($tot==($a+$c+$d+$e+$f+$g+$h+$i+$k+$b+$m+$n+$p+$q+$r+$z+$t+$v+$w+$y)){
		print "The fasta file $file contains a Protein sequence\n";
	}
}


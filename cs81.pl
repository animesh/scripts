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
$foo=shift @ARGV;
$f1=$foo.".dna.out";
$f2=$foo.".error.out";
$f3=$foo.".tath.out";
$f4=$foo.".tghi.out";

system("backtranseq -sequence $foo $f1 -cfile EMt.cut");
system("backtranseq -sequence $foo $f3 -cfile Table.ghi.txt");
system("backtranseq -sequence $foo $f4 -cfile Table.ath.txt");

open(FO,">$f2");

openfile($f1);
openfile($f3);
openfile($f4);

sub openfile{
	$foobar=shift;
	open(F,$foobar);
	while($l=<F>){
		chomp $l;
		if($l=~/^>/){
			$seqname=$l;
		}
		else{
			$seq.=uc($l);
		}
	}
	$seq=~s/\*//g;

	($riscnt,$rpolIItcnt,$pascnt,$atcnt)=checkrule($seq);
	#($riscnt,$rpolIItcnt,$pascnt,$atcnt)=checkrule("GCTACCGCTCACCACTGCAAGTCCCTCCAATTGCTATACGCTACCGCTCACCACTGCAAGTCC");
	print FO"FILE: $foobar\nRNA instability sequences-\t$riscnt\nRNA Pol II Termination signals-\t$rpolIItcnt\nPolyadenylation signal-\t$pascnt\nMore then 4 A or T-\t$atcnt\n"; 
}

sub checkrule {
	my $str=shift;
	my $riscnt = checkris($str);
	my $rpolIItcnt = checkrpolII($str);
	my $pascnt = checkpas($str);
	my $atcnt = checkat($str);
	return($riscnt,$rpolIItcnt,$pascnt,$atcnt);
}

sub checkris{
	my $str = shift;
	my $riscnt=$str=~s/ATTTA|AATAAA|TTCTT//g;
	return $riscnt;
}

sub checkrpolII{
	my $str = shift;
	my $rpolIItcnt=$str=~s/CA.{7-9}AGT..A//g;
	return $rpolIItcnt;
}

sub checkpas{
	my $str = shift;
	my $pascnt=$str=~s/ATAAAA|ATATAA|ATACAT|ATACTA|ATTAAA|ATTAAT|ATTCTC|AAGCAT|AACCAA|AATAAA|AATAAT|AATACA|AATCAA|AATTAA|AGTAAA|CATAAA|AAAATA//g;
	return $pascnt;
}

sub checkat{
	my $str = shift;
	my $atcnt=$str=~s/[A|T][A|T][A|T][A|T][A|T]//g;
	return $atcnt;
}
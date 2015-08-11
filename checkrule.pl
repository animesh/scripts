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
$f2=$foo.".status.out";
open(FO,">$f2");

openfile($foo);

sub openfile{
	$foobar=shift;
	$foobart=shift;
	open(F,$foobar);
	opentable($foobart);
	while($l=<F>){
		chomp $l;
		if($l=~/^>/){
			$seqname=$l;
		}
		else{
			$seq.=uc($l);
		}
	}
	($riscnt,$rpolIItcnt,$pascnt,$atcnt)=checkrule($seq, $seqname);
	
	$lengthseq=length($seq);
	$totall=$riscnt+$rpolIItcnt+$pascnt+$atcnt;
	print FO"\n\nFILE: $foobar-\t\t$lengthseq\nRNA instability sequences-\t$riscnt\nRNA Pol II Termination signals-\t$rpolIItcnt\nPolyadenylation signal-\t\t$pascnt\nMore then 4 A or T-\t\t$atcnt\n\nTotal Locations - \t\t$totall"; 
	$seq="";
}

sub opentable {
	my $file=shift;
	open(FT,$file);
	my $l;
	my $line;
	while($l=<FT>){
		$line++;
		chomp $l;
		@t=split(/\s+/,$l);
		@t[0]=~s/U/T/g;
		if(@t[0]!~/^[A|T|G|C]{3}/){next;}
		$aacoded{@t[0]}=@t[1];
		$codonprob{@t[0]}=@t[2];
	}
}

sub checkrule {
	my $str=shift;
	my $name=shift;
	my $atcnt = checkat($str);
	my $pascnt = checkpas($str);
	my $riscnt = checkris($str);
	my $rpolIItcnt = checkrpolII($str);
	return($riscnt,$rpolIItcnt,$pascnt,$atcnt);
}

sub checkris{
	my $str = shift;
	my $str2=$str;
	my $riscnt=$str=~s/ATTTA|AATAAA|TTCTT//g;
	$riscnt+=0;
	$str=$str2;
	#while($atcnt!=0){
		  while ($str =~ /ATTTA|AATAAA|TTCTT/g) {
			my $position = (pos $str) - length($&) +1;
			print FO"Found $id at position $position\n";
			print FO"   match:   $&\n";
			print FO"   pattern: RIS\n";
		  }
 	#}
	return $riscnt;
}

sub checkrpolII{
	my $str = shift;
	my $str2=$str;
	my $rpolIItcnt=$str=~s/CA.{7-9}AGT..A//g;
	$rpolIItcnt+=0;
	$str=$str2;
	#while($atcnt!=0){
		  while ($str =~ /CA.{7-9}AGT..A/g) {
			my $position = (pos $str) - length($&) +1;
			print FO"Found $id at position $position\n";
			print FO"   match:   $&\n";
			print FO"   pattern: RPolII\n";
		  }
 	#}
	return $rpolIItcnt;
}

sub checkpas{
	my $str = shift;
	my $pascnt=1;
	#while($pascnt!=0){
		my $str2=$str;
		$pascnt=$str=~s/ATAAAA|ATATAA|ATACAT|ATACTA|ATTAAA|ATTAAT|ATTCTC|AAGCAT|AACCAA|AATAAA|AATAAT|AATACA|AATCAA|AATTAA|AGTAAA|CATAAA|AAAATA//g;
		$pascnt+=0;
		$str=$str2;
		while ($str =~ /ATAAAA|ATATAA|ATACAT|ATACTA|ATTAAA|ATTAAT|ATTCTC|AAGCAT|AACCAA|AATAAA|AATAAT|AATACA|AATCAA|AATTAA|AGTAAA|CATAAA|AAAATA/g) {
			my $position = (pos $str) - length($&) +1;
			print FO"Found $id at position $position\n";
			print FO"   match:   $&\n";
			print FO"   pattern: PAS\n";
		}
	#}
	return $pascnt;
}

sub checkat{
	my $str = shift;
	my $atcnt=$str=~s/[A|T]{5}//g;
	my $str2=$str;
	$atcnt+=0;
	$str=$str2;
	#while($atcnt!=0){
		  while ($str =~ /[A|T]{5}/g) {
			my $position = (pos $str) - length($&) +1;
			print FO"Found $id at position $position\n";
			print FO"   match:   $&\n";
			print FO"   pattern: AT\n";
		  }
 	#}
	return $atcnt;
}
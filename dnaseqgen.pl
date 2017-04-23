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
$foodna="dna_seq.txt";
$f1=$foo.".mdna.out";
$f2=$foo.".error.out";
$f3=$foo.".tghi.out";
$f4=$foo.".tath.out";

$f1table="EMt.cut";
$f3table="Table.ghi.txt";
$f4table="Table.ath.txt";

system("backtranseq -sequence $foo $f1 -cfile $f1table");
system("backtranseq -sequence $foo $f3 -cfile $f3table");
system("backtranseq -sequence $foo $f4 -cfile $f4table");

open(FO,">$f2");

openfile($foo);
openfile($foodna);
openfile($f1,$f1table);
openfile($f3,$f3table);
openfile($f4,$f4table);

sub openfile{
	$foobar=shift;
	$foobart=shift;
	$foobarout=$foobar."form.out";
	open(F,$foobar);
	open(FOTP,">$foobarout");
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
	my ($str,$strform, $riscnt,$rpolIItcnt,$pascnt,$atcnt)=checkrule($seq, $seqname);
	#($riscnt,$rpolIItcnt,$pascnt,$atcnt)=checkrule("GCTACCGCTCACCACTGCAAGTCCCTCCAATTGCTATACGCTACCGCTCACCACTGCAAGTCC");
	
	$lengthseq=length($seq);
	print FO"FILE: $foobar-\t\t$lengthseq\nRNA instability sequences-\t$riscnt\nRNA Pol II Termination signals-\t$rpolIItcnt\nPolyadenylation signal-\t\t$pascnt\nMore then 4 A or T-\t\t$atcnt\n$seq\n$str\n$strform\n"; 
	print FOTP">$seqname\n$strform\n";
	$seq="";
}

sub opentable {
	my $file=shift;
	open(FT,$file);
	my $l;
	my $line;
	undef %aacoded;
	undef %codonprob;
	foreach $aaic (@aai) {
		undef @$aaic;
	}
	while($l=<FT>){
		$line++;
		chomp $l;
		@t=split(/\s+/,$l);
		@t[0]=~s/U/T/g;
		if(@t[0]!~/^[A|T|G|C]{3}/){next;}
		$aacoded{@t[0]}=@t[1];
		$codonprob{@t[0]}=@t[2];
		$aa=@t[1];
		push(@aai,$aa);
		push(@$aa,@t[0]);
	}
	close FT;
}

sub checkrule {
	my $str=shift;
	my $name=shift;
	my $strform=$str;
	my $riscnt;
	my $rpolIItcnt;
	my $atcnt;
	my $pascnt;
	($strform,$riscnt) = checkris($strform);
	($strform,$rpolIItcnt) = checkrpolII($strform);
	($strform,$atcnt) = checkat($strform);
	($strform,$pascnt) = checkpas($strform);
	return($str,$strform,$riscnt,$rpolIItcnt,$pascnt,$atcnt);
}

sub checkris{
	my $str = shift;
	my $riscnt=1;
	while($riscnt!=0){
		my $str2=$str;
		$riscnt=$str=~s/ATTTA|AATAAA|TTCTT//g;
		$riscnt+=0;
		$str=$str2;
		while ($str =~ /ATTTA|AATAAA|TTCTT/g) {
			my $position = (pos $str) - length($&) +1;
			print "Found $id at position $position\n";
			print "   match:   $&\n";
			print "   pattern: RIS\n";
			my $rem=$position%3;
			my $substrrem;
			$substrrem=substr($str,$position+3*$poschg{$position}-$rem,3);
			my $aa=$aacoded{$substrrem};
			my @temp=@$aa;
			print "Rem: $rem\t$substrrem\t$aa\t$codonprob{$substrrem}\n";
			my $max=0;my $aaamax;my $c;
			for($c=0;$c<=$#temp;$c++){
				if(@temp[$c] ne $substrrem){
					if($codonprob{@temp[$c]}>$max){
						$max=$codonprob{@temp[$c]};
						$aaamax=@temp[$c];
					}
				}
			}
			print "$aaamax\t$codonprob{$aaamax}\t$aacoded{$aaamax}\t$poschg{$position} \t$c\n";
			substr($str,$position+3*$poschg{$position}-$rem,3)=$aaamax;
			$poschg{$position}++;
			if($poschg{$position}>$c){$poscnt=0;last;}
		}
	}
	return ($str,$riscnt);
}

sub checkrpolII{
	my $str = shift;
	my $rpolIItcnt=1;
	while($rpolIItcnt!=0){
		my $str2=$str;
		$rpolIItcnt=$str=~s/CA.{7-9}AGT..A//g;
		$rpolIItcnt+=0;
		$str=$str2;
		while ($str =~ /CA.{7-9}AGT..A/g) {
			my $position = (pos $str) - length($&) +1;
			print "Found $id at position $position\n";
			print "   match:   $&\n";
			print "   pattern: CRPOL\n";
			my $rem=$position%3;
			my $substrrem;
			$substrrem=substr($str,$position+3*$poschg{$position}-$rem,3);
			my $aa=$aacoded{$substrrem};
			my @temp=@$aa;
			print "Rem: $rem\t$substrrem\t$aa\t$codonprob{$substrrem}\n";
			my $max=0;my $aaamax;my $c;
			for($c=0;$c<=$#temp;$c++){
				if(@temp[$c] ne $substrrem){
					if($codonprob{@temp[$c]}>$max){
						$max=$codonprob{@temp[$c]};
						$aaamax=@temp[$c];
					}
				}
			}
			print "$aaamax\t$codonprob{$aaamax}\t$aacoded{$aaamax}\t$poschg{$position} \t$c\n";
			substr($str,$position+3*$poschg{$position}-$rem,3)=$aaamax;
			$poschg{$position}++;
			if($poschg{$position}>$c){$poscnt=0;last;}
		}
	}
	return ($str,$rpolIItcnt);
}

sub checkpas{
	my $str = shift;
	my $pascnt=1;
	undef %poschg;
	while($pascnt!=0){
		my $str2=$str;
		$pascnt=$str=~s/ATAAAA|ATATAA|ATACAT|ATACTA|ATTAAA|ATTAAT|ATTCTC|AAGCAT|AACCAA|AATAAA|AATAAT|AATACA|AATCAA|AATTAA|AGTAAA|CATAAA|AAAATA//g;
		$pascnt+=0;
		$str=$str2;
		while ($str =~ /ATAAAA|ATATAA|ATACAT|ATACTA|ATTAAA|ATTAAT|ATTCTC|AAGCAT|AACCAA|AATAAA|AATAAT|AATACA|AATCAA|AATTAA|AGTAAA|CATAAA|AAAATA/g) {
			my $position = (pos $str) - length($&) +1;
			print "Found $id at position $position\n";
			print "   match:   $&\n";
			print "   pattern: PAS\n";
			my $rem=$position%3;
			my $substrrem;
			$substrrem=substr($str,$position+3*$poschg{$position}-$rem,3);
			my $aa=$aacoded{$substrrem};
			my @temp=@$aa;
			print "Rem: $rem\t$substrrem\t$aa\t$codonprob{$substrrem}\n";
			my $max=0;my $aaamax;my $c;
			for($c=0;$c<=$#temp;$c++){
				if(@temp[$c] ne $substrrem){
					if($codonprob{@temp[$c]}>$max){
						$max=$codonprob{@temp[$c]};
						$aaamax=@temp[$c];
					}
				}
			}
			print "$aaamax\t$codonprob{$aaamax}\t$aacoded{$aaamax}\t$poschg{$position} \t$c\n";
			substr($str,$position+3*$poschg{$position}-$rem,3)=$aaamax;
			$poschg{$position}++;
			if($poschg{$position}>$c){$poscnt=0;last;}
		}
	}
	return ($str,$pascnt);
}

sub checkat{
	my $str = shift;
	my $atcnt=1;
	while($atcnt!=0){
		my $str2=$str;
		$atcnt=$str=~s/[A|T]{5}//g;
		$atcnt+=0;
		$str=$str2;
		while ($str =~ /[A|T]{5}/g) {
			my $position = (pos $str) - length($&) +1;
			print "Found $id at position $position\n";
			print "   match:   $&\n";
			print "   pattern: AT\n";
			my $rem=$position%3;
			my $substrrem;
			$substrrem=substr($str,$position+3*$poschg{$position}-$rem,3);
			my $aa=$aacoded{$substrrem};
			my @temp=@$aa;
			print "Rem: $rem\t$substrrem\t$aa\t$codonprob{$substrrem}\n";
			my $max=0;my $aaamax;my $c;
			for($c=0;$c<=$#temp;$c++){
				if(@temp[$c] ne $substrrem){
					if($codonprob{@temp[$c]}>$max){
						$max=$codonprob{@temp[$c]};
						$aaamax=@temp[$c];
					}
				}
			}
			print "$aaamax\t$codonprob{$aaamax}\t$aacoded{$aaamax}\t$poschg{$position} \t$c\n";
			substr($str,$position+3*$poschg{$position}-$rem,3)=$aaamax;
			$poschg{$position}++;
			if($poschg{$position}>$c){$atcnt=0;last;}
		}
	}
	return ($str,$atcnt);
}
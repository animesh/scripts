#!/usr/bin/perl
$f1=shift;
open(F1,$f1);
while(<F1>)
{
  if($_=~/^F/){
	chomp;
	@tmp=split(/\t/);
	push(@name1,@tmp[0]);
	$n1{@tmp[0]}=$_;
  }
}
$f2=shift;
open(F2,$f2);
while(<F2>)
{
  if($_=~/^F/){
        chomp;
        @tmp=split(/\t/);
        push(@name1,@tmp[0]);
        $n2{@tmp[0]}=$_;
  }
}
open(F1O,">$f1.$f2.trimstats");
@uniquelistn1 = keys %{{map {$_=>1} @name1}};
foreach (@uniquelistn1){
	if($n1{$_} and $n2{$_}){
		$c1++;
		print F1O"$c1\t$_\t$n1{$_} and $n2{$_}\n";
	}
}
__END__
Accno   Trimpoints Used Used Trimmed Length     Orig Trimpoints Orig Trimmed Length     Raw Length
FL61AHU01A1MIK  5-130   126     5-130   126     168
==> ot <==
FL61AHU01CF0M4  5-58    54      5-58    54      203
FL61AHU01DCK2Y  5-208   204     5-208   204     304
==>t<==
4       xy=1044_1613    length=318 and length=407
5       xy=0518_4019    length=304 and length=256



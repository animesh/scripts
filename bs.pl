#!/usr/bin/perl
%t2o = (
      'ALA' => 'A',
      'VAL' => 'V',
      'LEU' => 'L',
      'ILE' => 'I',
      'PRO' => 'P',
      'TRP' => 'W',
      'PHE' => 'F',
      'MET' => 'M',
      'GLY' => 'G',
      'SER' => 'S',
      'THR' => 'T',
      'TYR' => 'Y',
      'CYS' => 'C',
      'ASN' => 'N',
      'GLN' => 'Q',
      'LYS' => 'K',
      'ARG' => 'R',
      'HIS' => 'H',
      'ASP' => 'D',
      'GLU' => 'E',
    );
$fileopen=shift @ARGV;
FileOpen($fileopen);	
#print "File\tArea\tPerimeter\tHD.dist\tDS.dist\tHS.dist		\n";	

foreach $f (keys %his){
#	abs((x1-x2)*(y1-y3)-(y1-y2)*(x1-x3))
	@th=split(/\t/,$his{$f});
	@ta=split(/\t/,$asp{$f});
	@ts=split(/\t/,$ser{$f});
	$a=sqrt((@th[0]-@ta[0])**2 + (@th[1]-@ta[1])**2 + (@th[2]-@ta[2])**2);
	$b=sqrt((@ts[0]-@ta[0])**2 + (@ts[1]-@ta[1])**2 + (@ts[2]-@ta[2])**2);
	$c=sqrt((@th[0]-@ts[0])**2 + (@th[1]-@ts[1])**2 + (@th[2]-@ts[2])**2);
	$s=(1/2)*($a+$b+$c);
	$peri=($a+$b+$c);
	$avgperi=$peri/3;
	$max=0;
	if($a>$max){$max=$a}
	if($b>$max){$max=$b}
	if($c>$max){$max=$c}
	$area=sqrt($s*($s-$a)*($s-$b)*($s-$c));
#	print "$f\t$area\t$s\t$a\t$b\t$c\tavg-$avgperi\tmax-$max\n";	
#	print "$f\t@th[0]\t@ta[0]\t@ts[0]\t\n";
#	print "$f\t@th[1]\t@ta[1]\t@ts[1]\t\n";
#	print "$f\t@th[2]\t@ta[2]\t@ts[2]\t\n";
}

sub FileOpen {
$file = shift;
#$file = "1AU8.pdb";
open(F,$file)||die "no such file";
while($l=<F>){
	if($l=~/^ATOM/){
		@t=split(//,$l);
		$nm=@t[0].@t[1].@t[2].@t[3];$rn=@t[12].@t[13].@t[14].@t[15];
		if($nm=~/ATOM/ and $rn=~/CA/){$c9++;
			$pos=@t[22].@t[23].@t[24].@t[25]+0;
			$s1=$t2o{@t[17].@t[18].@t[19]}."-".@t[21]."-".$pos;
			$x=@t[30].@t[31].@t[32].@t[33].@t[34].@t[35].@t[36].@t[37]+0;
			$y=@t[38].@t[39].@t[40].@t[41].@t[42].@t[43].@t[44].@t[45]+0;
			$z=@t[46].@t[47].@t[48].@t[49].@t[50].@t[51].@t[52].@t[53]+0;
			$s2=$x."\t".$y."\t".$z;
			$aac{$s1}=$s2;
			$name=@t[17].@t[18].@t[19];
			#print "$pos\t$name\t$s2\t$s1\n";
			if($pos==57 and $name eq "HIS"){
				$his{$file}=$s2;
				#print "$pos\t$name\t$s2\t$s1\n";
				$his{$file}=$s2;
			}
			if($pos==102 and $name eq "ASP"){
				$asp{$file}=$s2;
				#print "$pos\t$name\t$s2\t$s1\n";
			}
			if($pos==195 and $name eq "SER"){
				$ser{$file}=$s2;
				#print "$pos\t$name\t$s2\t$s1\n";
			}
#			else{
				#print "ELSE $pos\t$name\t$s2\t$s1\n";
				$aaz{$s2}=$name;
				$paz{$s2}=$pos;
#			}
		}
	}
}
close F;
}


foreach $cord (keys %aaz){
	@th=split(/\t/,$his{$fileopen});
	@ta=split(/\t/,$asp{$fileopen});
	@ts=split(/\t/,$ser{$fileopen});
	@t=split(/\t/,$cord);
	$a=int(sqrt((@th[0]-@t[0])**2 + (@th[1]-@t[1])**2 + (@th[2]-@t[2])**2));
	$b=int(sqrt((@ts[0]-@t[0])**2 + (@ts[1]-@t[1])**2 + (@ts[2]-@t[2])**2));
	$c=int(sqrt((@th[0]-@t[0])**2 + (@th[1]-@t[1])**2 + (@th[2]-@t[2])**2));
	#if($paz{$cord} eq 195){
	if($a<=$max && $b<=$max && $c<=$max){
	#print "$cord\t$his{$fileopen}\t$asp{$fileopen}\t$ser{$fileopen}\t$aaz{$cord}\t$paz{$cord}\t$max\n";
	print "$aaz{$cord}\t$paz{$cord}\n";
	}
		
}


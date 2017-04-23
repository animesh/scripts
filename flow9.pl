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
#read gbk file and the Markov Model level
if( @ARGV ne 2){die "\nUSAGE\t\"ProgName GBK-SeqFile(file name) Markov Order(number)\t\n\n\n";}

$file = shift @ARGV;
$mmh=shift @ARGV;

#partition of the genome to spread out the picked up cds
$part=400;

#open GBK file
opengbk($file,$part);
#initialize and fill the sequence arrays
$seqr=\@ncdsseq;@seqr=@$seqr;$srname=\@ncdsseqname;@srname=@$srname;
#$cdsseq=\@cdsseq;@cdsseq=@$cdsseq;$cdsseqname=\@seqname;@cdsseqname=@$seqname;foreach $w(@cdsseqname) {print "$w\n";}
undef @ncdseq;undef @ncdseqname;

#perform Fourier Transform and pick up coding and non coding sequence in different arrays
FFT(\@seqr,\@srname);
$rfftcds=\@fftcds;$rfftcdsn=\@fftcdsn;$rfftncds=\@fftncds;$rfftncdsn=\@fftncdsn;
@rfftcds=@$rfftcds;@rfftcdsn=@$rfftcdsn;@rfftncds=@$rfftncds;@rfftncdsn=@$rfftncdsn;
FFT(\@cdsseq,\@cdsseqname);

#perform markov model
MM(\@fftcds,\@rfftncds,\@rfftcds,$mmh,\@rfftcdsn,$file);


sub opengbk{
	$file=shift;
	open(F,$file)||die "can't open \"$file\": $!";
	$part=shift;
	print "Reading file $file";
	while($l=<F>)
	{	
		$cnt1++;
		if(($cnt1%1000) eq 0){print ".";}
		if($l =~ /CDS/){
			if($l =~ /join/)
				{unless($l =~ /\)/)
					{
						do{
						$linenew=<F>;
						chomp ($linenew);
						$l = $l.$linenew;
							}until ($l =~ /\)/)
					}
				}
		$l =~ s/\(/ /g;$l =~ s/\)/ /g;$l =~ s/join//;$l =~ s/CDS//;
		if($l=~/complement/){$l=~s/[A-Za-z]/ /g;$l=~s/\/\=\"\"//g;
			@temp=split(/,/,$l);foreach $tr (@temp){$tr=~s/\s+//g;
			chomp $tr;
			if($tr ne ""){push(@comcds,$tr);push(@t,$tr);}}}
		else
			{$l=~s/[A-Za-z]/ /g;$l=~s/\/\=\"\"//g;
			@temp=split(/,/,$l);
			foreach $tr (@temp){$tr=~s/\s+//g;
				chomp $tr;
				if(($tr ne "")){push(@cds,$tr);push(@t,$tr);}
				}
			}}
		if($l=~/^ORIGIN/)
		{		while($ll=<F>)
				{
	
				$ll=~s/[0-9]//g;$ll=~s/\s+//g;chomp $ll;$line.=$ll;
				}
		}
	}
	$line=($line);$line=~s/\///g;1/1;$seql=length($line);
	$div=int ($seql/$part);
	foreach $cds1 (@cds){
		$cds1=~s/\s+//g;$cds1=~s/\>//g;$cds1=~s/\<//g;
		@no1=split(/\.\./,$cds1);$lll=@no1;
		if(($lll eq 2) and (@no1[0]=~/[0-9]/) and (@no1[1]=~/[0-9]/)){
			$length=@no1[1]-@no1[0]+1;
			$st=@no1[0];$sp=@no1[1];$cds{$sp}=$st;
			$str = uc(substr($line,(@no1[0]-1),$length));
			$sname="CDS[@no1[0]-@no1[1]]";
			push(@cdsseq,$str);push(@cdsseqname,$sname);			
		}
	}
	foreach $cds2 (@comcds){
		$cds2=~s/\s+//g;$cds2=~s/\>//g;$cds2=~s/\<//g;
		@no1=split(/\.\./,$cds2);$lll=@no1;
		if(($lll eq 2) and (@no1[0]=~/[0-9]/) and (@no1[1]=~/[0-9]/)){
			$length=@no1[1]-@no1[0]+1;
			$str = substr($line,(@no1[0]-1),$length);
			$str=~tr/atgc/tacg/d;1/1;
			$str = uc(reverse($str));
			$st=@no1[0];$sp=@no1[1];$cds{$st}=$sp;
			$sname="cCDS[@no1[0]-@no1[1]]";
			push(@cdsseq,$str);push(@cdsseqname,$sname);
		}
	}
	$lcds=(@cdsseq);
	print "\nExtracted $lcds coding sequence from $file";
	for($cc1=0;$cc1<=$#t;$cc1++){
		$cds1=@t[$cc1];
		$cds1=~s/\s+//g;$cds1=~s/\>//g;$cds1=~s/\<//g;
		@no1=split(/\.\./,$cds1);$lll=@no1;
		if(($lll eq 2) and (@no1[0]=~/[0-9]/) and (@no1[1]=~/[0-9]/)){
			push(@to,@no1[0]);push(@to,@no1[1]);
		}
	}
	for($cc1=0;$cc1<($#to-1);$cc1=$cc1+2){
		$cds1=@to[$cc1];$sp=(@to[($cc1+2)]-1);$st=(@to[($cc1+1)]+1);
		$length=@to[($cc1+2)]-@to[($cc1+1)]-1;
		if($length le 0){
			$sp=$sp+1;$st=$st-1;
			$length=$st-$sp+1;
			$str = uc(substr($line,$sp-1,$length));
			$intgen{$sp}={$st};
		}
		elsif($length >= 90){
		#else{
			$str = uc(substr($line,(@to[($cc1+1)]),$length));
			$intgen{$sp}={$st};
			$ncdssname="Intergenic[$st-$sp]";
			push(@ncdsseq,$str);push(@ncdsseqname,$ncdssname);
			$ncdssname="cIntergenic[$st-$sp]";
			$str=~tr/atgc/tacg/d;1/1;
			$str = uc(reverse($str));
			push(@ncdsseq,$str);push(@ncdsseqname,$ncdssname);
		}
	}
	$lcds=(@ncdsseq);
	print "\nExtracted $lcds intergenic sequence from $file\n";
	close F;

}

sub FFT{
	undef @fftcds;undef @fftcdsn;undef @fftncds;undef @fftncdsn;
	$fftseq3=shift;
	$fftseq4=shift;
	@fftseq=@$fftseq3;
	@fftfftseqname=@$fftseq4;
	use Math::Complex;
	$pi=pi;
	$i=sqrt(-1);
	@base=qw/G T A C/;
	for($c1=0;$c1<=$#fftseq;$c1++)
	{
		$fooo=$c1+1;	$sname=@fftfftseqname[$c1];$fftseq=uc(@fftseq[$c1]);chomp $fftseq;$fftseq=~s/\s+//g;$N=length($fftseq);
		print "Analysing\tfftseq no.$fooo\t$sname\t";
		until ($fftseq !~ /^G/){$fftseq =~s/^G//;}
		$N=length($fftseq);
		if($N < 3){
		print "$N is less then 3 (Length)\n";
		next;
		}
		$R=$N%3;
		if($R ne 0){
		$N=$N-$R;
		}
	FT(1,$N);
		sub FT {
		$st=shift;
		$sp=shift;
		$le=$sp-$st+1;
		$subs=substr($fftseq,($st-1),$le);$ws=$sp;$subfftseq=$subs;
		$c=$subfftseq=~s/C/C/g;$a=$subfftseq=~s/A/A/g;$g=$subfftseq=~s/G/G/g;$t=$subfftseq=~s/T/T/g;
		@subssplit=split(//,$subs);
			for($k=1;$k<=($sp/2);$k++)
			{
				if ($le/$k == 3){
					for($c6=0;$c6<=$#base;$c6++){
					$bvar=@base[$c6];
						for($c7=0;$c7<=$#subssplit;$c7++){
						$wsvar=@subssplit[$c7];
							if ($bvar eq $wsvar){
								$subsum+=exp(2*$pi*$i*($k/$le)*($c7+1));
							}
							else{
								$subsum+=0;
							}
						}
					$subsumtotal+=(((1/$le)**2)*(abs($subsum)**2));
					$subsum=0;
					}
					$atgcsq=((1/($ws**2))*($c**2+$a**2+$g**2+$t**2));
					$sbar=(1/$ws)*(1+(1/$ws)-$atgcsq);$atgcsq=0;
					$substss=$sbar;
					$subptnr1=$subsumtotal/$substss;
					$subsumtotal=0;
					$subptnr2=$subptnr1/($sp*$substss);
					$subptnr3=$subptnr2*2;
					$pp=($k)/$le;
					$sp3=$subptnr3;$sp3=sprintf (1,$subptnr3,2);$sp3=substr($subptnr3,0,3);
					$sname=$sname."-PtNR\t$sp3";
					if($subptnr3 >= 4){
						push(@fftcds,@fftseq[$c1]);
						push(@fftcdsn,$sname);
						print "Coding\t$sp3\tLength\t$N\n";
					}
					else{
						push(@fftncds,@fftseq[$c1]);
						push(@fftncdsn,$sname);
						print "Non Coding\t$sp3\tLength\t$N\n";
					}			
				}
		}
		}
	}
}

sub MM{
	
	$sq1=shift;@sq1=@$sq1;
	$sq2=shift;@sq2=@$sq2;
	$sq3=shift;@sq3=@$sq3;
	
	@base=qw/A T G C/;$bc=@base;
	$co=shift;$colo=$co+1;$jump=1;
	
	$sq3n=shift;@sq3n=@$sq3n;
	$file=shift;
	$fommp=$file.".".$co."thO-mmP.out";
	$fommn=$file.".".$co."thO-mmN.out";
	$fommi=$file.".".$co."thO-mmI.out";
	open (FOP,">$fommp");
	open (FON,">$fommn");
	open (FOI,">$fommi");
	
	%mash1=createhash(@sq1);
	undef @sq1;undef %mash;
	%mash2=createhash(@sq2);
	undef @sq2;undef %mash;
	
	foreach $k (keys %mash1) {
		for($b2=0;$b2<=$#base;$b2++){
		$su2=substr($k,0,$co);
		$su22=@base[$b2];
		$su222=$su2.$su22;
			if($mash1{$su222} eq ""){
			$mash1{$su222}=1;
			}
		}
	}
	foreach $k (values %mash1) {$cash1+=$k;}
	foreach $k (keys %mash1) {$mash1{$k}=$mash1{$k}/$cash1;1/1;}
	
	foreach $k (keys %mash2) {
		for($b2=0;$b2<=$#base;$b2++){
		$su2=substr($k,0,$co);
		$su22=@base[$b2];
		$su222=$su2.$su22;
			if($mash2{$su222} eq ""){
			$mash2{$su222}=1;
			}
		}
	}
	foreach $k (values %mash2) {$cash2+=$k;}
	foreach $k (keys %mash2) {$mash2{$k}=$mash2{$k}/$cash2;1/1;}
	for($fot=0;$fot<=$#sq3;$fot++){
		$seq=uc(@sq3[$fot]);$seqname=@sq3n[$fot];$seq=~s/\s+//g;chomp $seq;$len=length($seq);
		for($cot=0;$cot<=($len-$colo);$cot++){
		$subs=substr($seq,$cot,$colo);
			if(($mash2{$subs} ne "") and ($mash1{$subs} ne "")){
				$p=$mash1{$subs}/$mash2{$subs};1/1;
				$prob+=log($p);
			}
			elsif(($mash2{$subs} eq "") and ($mash1{$subs} eq "")){
				$p=$cash2/$cash1;1/1;
				$prob+=log($p);
			}
			elsif($mash2{$subs} eq ""){
				$p=$mash1{$subs}/(1/$cash2);
				$prob+=log($p);
			}
			elsif($mash1{$subs} eq ""){
				$p=(1/$cash1)/$mash2{$subs};
				$prob+=log($p);
			}
		}
		$seq=uc(@sq3[$fot]);
		$prob=$prob/$len;
		if($prob gt 0){
			print "coding\t$sq3n[$fot]\t$prob\t$len\n";
			print FOP">$sq3n[$fot]\t$co-thMMProb\t$prob\tSLength\t$len\n$seq\n";
		}
		elsif($prob eq 0){
			print "intermediate\t$sq3n[$fot]\t$prob\t$len\n";
			print FOI">$sq3n[$fot]\t$co-thMMProb\t$prob\tSLength\t$len\n$seq\n";
		}
		else{
			print "non-coding\t$sq3n[$fot]\t$prob\t$len\n";
			print FON">$sq3n[$fot]\t$co-thMMProb\t$prob\tSLength\t$len\n$seq\n";
		}
		$prob=0;
	}
	
	sub createhash{
		@seqch=@_;
		for($x11=0;$x11<=$#seqch;$x11++){
			$seqch=uc(@seqch[$x11]);chomp $seqch;$seqch=~s/\s+//g;
			$len=length($seqch);
			for($co2=0;$co2<=($len-$colo);$co2++){
				$subs=substr($seqch,$co2,$colo);
				$mash{$subs}+=1;
			}
		}
		return %mash;undef %mash;
	}
	close FOP;close FON;close FOI;
}

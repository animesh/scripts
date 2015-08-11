#!/usr/local/bin/perl
use lib '/Home/siv11/ash022/home/ysr/exp/ref/MIDI-Perl-0.81/lib/';
use Math::Complex;
use MIDI::Simple;
$pi=pi;
$i=sqrt(-1);

$file=shift @ARGV;
chomp $file;

@base=qw/G T A C/;
set_tempo 5000000;  
patch_change 1, 8; 
$thresh=450;



OPENFAS($file);
#new_score;
CRTDNAMUS();
#write_score("$wfile");
#exit;


sub OPENFAS{
	$file = shift;
	open (F, $file) || die "can't open \"$file\": $!";
	$seq="";
	while ($line = <F>) {chomp $line;
		if ($line =~ /^>/){
			push(@seqname,$line);	
			if ($seq ne ""){
				push(@seq,$seq);
						$seq = "";
					}
			}
		 else {$seq=$seq.$line;
			}
	}
	push(@seq,$seq);
	close F;
}




sub CRTDNAMUS{

	for ($c1=0;$c1<=$#seq;$c1++) {
		$wfile=$file.".$c1".".midi";
		new_score;
		$sn=@seqname[$c1];
		$se=@seq[$c1];
		$len=length($se);
			$dnastr=$se;
			undef @ptnr; undef $mash;
			print "$sn: $c1\t$len\n";
			$valptnr=FTT($dnastr,$c1);
			for($c3=0;$c3<=$#ptnr;$c3++){
				@t1=split(/\./,@ptnr[$c3]);				
				@t2=split(//,@t1[1]);
				#$chann1=@t1[2]+1;$chann1="c".$chann1;
				#$note1=(@t1[0])+(@t2[1]*10);$note1="n".$note1;
				#$octave1=(@t2[0]+1);$octave1="o".$octave1;
				$chann1=@t2[2]+0;$chann1="c".$chann1;
				$note1=@t2[0].@t2[1]+0;$note1="n".$note1;
				$octave1=@t1[0]+0;
				if($octave1>10){$octave1=10;}
				$octave1="o".$octave1;
				print "PTNR-@ptnr[$c3]\tC-$chann1\t0-$octave1\tN-$note1\n";
				noop $chann1, f, $octave1;
				n sn, $note1;
				#n(c9, ff, n41, qn);
		}
		write_score("$wfile");
	}

}

sub FTT {
	$dnastr=shift;$dnastr=uc($dnastr);
	$fftfilen=shift;
	$fftfile=$file.".$fftfilen.fft";
	$dleng=length($dnastr);
	open(FFTF,">$fftfile")||die "unable to open $fftfile";
	if($dnastr =~ /^G/){until ($dnastr !~ /^G/){$dnastr =~s/^G//;}}
	if((length($dnastr)%3)!=0){
		$dleng=length($dnastr);
		$dleng=$dleng-(length($dnastr)%3);
		}
	#if($dleng>=$thresh){$dleng=450;}
	$dnastr=substr($dnastr,0,$dleng);
	$ws=length($dnastr);
	$subfftseq=$dnastr;
	$subs=$subfftseq;
	$c=$subfftseq=~s/C/C/g;$a=$subfftseq=~s/A/A/g;$g=$subfftseq=~s/G/G/g;$t=$subfftseq=~s/T/T/g;
	@subssplit=split(//,$subs);
	$sp=$dleng;$le=$dleng;
		for($k=1;$k<=($sp/2);$k++){	
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
				push(@ptnr,$subptnr3);$mash{$subptnr3}=$pp;
				$valx=$le/$k;
				print "$valx\t$subptnr3\n";
				print FFTF"$valx\t$subptnr3\n";
				if(($valx)==3){$ptnr3=$subptnr3;}
		}
		close FFTF;
		return($ptnr3);
}

sub check{
	new_score;

	@subs = ( \&measure_counter, \&psycho, \&boom, \&tboom, \&clap );
	foreach (1 .. 24) { synch(@subs) }
	write_score("base.midi");
	exit;

	# Subs
	sub measure_counter {
	  my $it = shift;
	  $it->r(wn); # a whole rest
	  ++$measure;
	}

	sub boom {
	  my $it = shift;
	  return if $measure % 4 < 2;
	  $it->n(c9, ff, n41, qn);  $it->r;
	  $it->n(f);  r;
	}

	sub tboom {
	  my $it = shift;
	  return if $measure % 4 < 2;
	  # 42 = 'Closed Hi-Hat' ; 43 = 'High Floor Tom'
	  # In quick succession...
	  $it->n( c9, ff, n43, sn); $it->n( n42 ); $it->r(dqn);
	  # dqn = dotted quarter note/rest
	  $it->r( c9, ff, n43, sn); $it->n( n42 ); $it->r(dqn);
	}

	sub clap {
	  my $it = shift;
	  return if  $measure < 4;
	  $it->n(c9, ff, n39, sn); $it->n;
	  $it->r(dqn);
	  $it->r(hn);
	}

	sub psycho {
	  my $it = shift;
	  my $pattern =
	    "  !.!.!.   !!!!!!   !.!.  " ;
	  $pattern =~ tr<\cm\cj\t ><>d; # kill whitespace
	  warn "<$pattern> doesn't add up to a whole measure\n"
	    unless length($pattern) == 16;
	  $it->noop(c9, mf, n37, sn);
	  # setup: n37 on c9 = side stick
	  foreach (split('', $pattern)) {
	    if($_ eq '!') { $it->n }
	    else { $it->r }
	  }
	}
}

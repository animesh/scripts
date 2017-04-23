while(<>){
        chomp;
	$_=~s///g;
        if($_=~/^>/){next}
        else{$seq.=uc($_);}
}

sub rc {
  my $dna = shift; # or   my $dna = shift @_;
  my $revcomp = reverse($dna);
  $revcomp =~ tr/ACGTacgt][/TGCAtgca[]/;
  return $revcomp;
}

sub fstr{
	my $num_matches;
	my $name=shift;
	my $pep = shift;
	my $pepcomp = rc($pep);
	my $cut=shift;
	my $lenmot=length($pep);
	while( $seq =~ m/$pep|$pepcomp/gi ){
        	pos( $seq ) = $-[0] + 1;
		$startmat=$-[0]+1;
		$endmat=$+[0];		
		$lenmat=$endmat-$startmat+1;		
        	$num_matches++;
		my $cutpos=$startmat+$cut;
		my $matstr=substr($seq,$startmat-1,$lenmat);
		print "$num_matches,$name,$matstr,$cutpos,$startmat,$endmat,$lenmat\n";
	}
}

print "num_matches,name,match_string,cut_position,start,end,lenmat\n";
fstr("DpnI","GATC",$cut=2);
fstr("ChiS","GCTGGTGG",$cut=4);
fstr("DnaA","TT[A|T]T.CACA",$cut=4);
fstr("FisB","G.T[C|T]A[A|T][A|T][A|T][A|T][A|T]T[G|A]A.C",$cut=7);
fstr("FnrP","TTGAT....ATCAA",$cut=6);
fstr("IhfB","[A|T]ATCAA...TT[G|A]",$cut=6);
fstr("ArcA","[A|T]GTTAATTA[A|T]",$cut=5);
#fstr("ATr",$pep = "AT",$cut=1);

__END__

0. DpnI GATC 

1. Chi Sequences:- 5' GCTGGTGG 3'

2. DnaA binding sites:- 5' TT (A/T)TNCACA 3'

3. Fis Binding site:- 5' GNTYAWWWWWTRANC 3'  (W= A/T, R= G/C)

4. Fnr promoter sequences:- 5' TTGATNNNNATCAA 3'

5. IHF binding site:- 5' WATCAANNNTTR 3'

6. ArcA Bindings site:- 5' (A/T)GTTAATTA(A/T) 3'

7. If possible to get a AT content histogram for the genome, as I can get
GC content for the genome I can get.



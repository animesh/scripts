for($c=0;$c<7;$c++){
	$titanium="Titanium";
	$seabass="seabass.fasta";
	if($c==0){
		$nt=($c+1)*30000;
	}
	else{
		$nt=($c)*150000;
	}	

	print "$c\t$nt\tNV\t800\n";
	system("time ./flowsim-0.2.4  -G Titanium --model=nv.txt     --degrad=\"Normal 0 0\"  -n $nt $seabass -o $seabass.$c.$nt.$titanium.nv.800.sff");
	print "Assembly\n";
	system("time /space/animesh/site/454apps/bin/runAssembly -o $seabass.$c.$nt.$titanium.800.nv.RA -g $seabass.$c.$nt.$titanium.nv.800.sff");
	print "Mapping\n";
	system("time /space/animesh/site/454apps/bin/runMapping  -o $seabass.$c.$nt.$titanium.800.nv.RM $seabass $seabass.$c.$nt.$titanium.nv.800.sff");
	print "\n";


}

__END__

  932  ./flowsim-0.2.4 -G tiem -n 1000 Ecoli-K12-MG1655.fasta -o test.sff
  933  ./flowsim-0.2.4 -G tiem --flowlenght=1600 -n 1000 Ecoli-K12-MG1655.fasta -o test2.sff
  934  ./flowsim-0.2.4 -G tiem --flowlenght 1600 -n 1000 Ecoli-K12-MG1655.fasta -o test2.sff
  935  ./flowsim-0.2.4 -G tiem --flowlength=1600 -n 1000 Ecoli-K12-MG1655.fasta -o test2.sff



  760  ./flowsim-0.2c Ecoli-K12-MG1655.fasta -n 20 -o E.SF
  761  less E.SF
  762  /space/animesh/site/454apps/bin/sffinfo E.SF | less
  763  ./flowsim-0.2c Ecoli-K12-MG1655.fasta -n 20 -G Ti -o E.SF
  764  /space/animesh/site/454apps/bin/sffinfo E.SF | less
  765  ./flowsim-0.2c --help
  766  ./flowsim-0.2c Ecoli-K12-MG1655.fasta -n 20 -G FLX -o E.SF
  767  ./flowsim-0.2c Ecoli-K12-MG1655.fasta -n 20 -G Titanium -o E.SF
  768  ./flowsim-0.2c Ecoli-K12-MG1655.fasta -n 20 -G GS20 -o E.SF
  769  /space/animesh/site/454apps/bin/sffinfo -s E.SF | less
  770  /space/animesh/site/454apps/bin/sffinfo -s E.SF | wc
  771  /space/animesh/site/454apps/bin/runAssembly -g E.SF
  772  ls'
  773  less
  774  ls
  775  ls P_2010_03_24_10_53_49_runAssembly/
  776  ls P_2010_03_24_10_53_49_runAssembly/454NewblerMetrics.txt
  777  less P_2010_03_24_10_53_49_runAssembly/454NewblerMetrics.txt
  778  /space/animesh/site/454apps/bin/runMapping Ecoli-K12-MG1655.fasta E.SF
  779  less P_2010_03_24_10_55_40_runMapping/454NewblerMetrics.txt
  780  history
  781  less SeaBass_LG1_BOTTOM_final_scaffold.fasta
  782  grep "^>" SeaBass_LG1_BOTTOM_final_scaffold.fasta
  783  history


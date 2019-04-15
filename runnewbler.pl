for($c=0;$c<7;$c++){
	$titanium="Titanium";
	$gs20="GS20";
	$ecoli="Ecoli-K12-MG1655.fasta";
	$seabass="SeaBass_LG1_BOTTOM_final_scaffold.fasta";
	if($c==0){
		$ng=($c+1)*40000;
		$nt=($c+1)*10000;
	}
	else{
		$ng=($c)*200000;
		$nt=($c)*50000;
	}	
	print "$c\t$gs20\t$ecoli\t";
	system("time /space/animesh/flowsim/flowsim-0.2c $ecoli -n $ng -G $gs20 -o $ecoli.$c.$ng.$gs20.sff");
	system("time /space/animesh/site/454apps/bin/runAssembly -o $ecoli.$c.$ng.$gs20.RA -g $ecoli.$c.$ng.$gs20.sff");
	system("time /space/animesh/site/454apps/bin/runMapping -o $ecoli.$c.$ng.$gs20.RM $ecoli $ecoli.$c.$ng.$gs20.sff");
	print "\n";

	print "$c\t$titanium\t$ecoli\t";
	system("time /space/animesh/flowsim/flowsim-0.2c $ecoli -n $nt -G $titanium -o $ecoli.$c.$nt.$titanium.sff");
	system("time /space/animesh/site/454apps/bin/runAssembly -o $ecoli.$c.$nt.$titanium.RA -g $ecoli.$c.$nt.$titanium.sff");
	system("time /space/animesh/site/454apps/bin/runMapping  -o $ecoli.$c.$nt.$titanium.RM $ecoli $ecoli.$c.$nt.$titanium.sff");
	print "\n";

}

__END__




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


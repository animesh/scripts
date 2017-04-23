for($c=50;$c<=400;$c+=50){
	print "Length $c\n";
	system("/usit/titan/u1/ash022/mapasm454_source_11172009/applicationsBin/runAssembly -fe list.$c -o ecoli.assembly.$c *.sff");
}

__END__
-bash-3.2$ /usit/titan/u1/ash022/mapasm454_source_11172009/applicationsBin/runAssembly -fe list *.sff
Created assembly project directory P_2010_01_07_22_20_33_runAssembly
Error in runAssembly:  Unable to launch addRun, or error running addRun.
Usage:  runAssembly [-o projdir] [-nrm] [-p (sfffile | [regionlist:]analysisDir)]... (sfffile | [regionlist:]analysisDir)...
-bash-3.2$ /usit/titan/u1/ash022/mapasm454_source_11172009/applicationsBin/runAssembly -fe list *.sff -o list
Created assembly project directory P_2010_01_07_22_20_40_runAssembly
Error:  Not an SFF or FASTA file:  /xanadu/project/codgenome/titanium/list
Error:  Read file/run not found:  -o
Error in runAssembly:  Unable to launch addRun, or error running addRun.
Usage:  runAssembly [-o projdir] [-nrm] [-p (sfffile | [regionlist:]analysisDir)]... (sfffile | [regionlist:]analysisDir)...
-bash-3.2$ /usit/titan/u1/ash022/mapasm454_source_11172009/applicationsBin/runAssembly -fe list -o listy *.sff        
Created assembly project directory listy
10 read files successfully added.

assembly/454TrimStatus.txt

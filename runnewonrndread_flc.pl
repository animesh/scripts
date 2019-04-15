#for($c=1;$c<=10;$c++){
$tempvar=time;
print "File $c selected reads are being written to t1$tempvar\n";

system("head -n 150000 Ecoli.avgqual.sort > t15$tempvar");
system("/home/animesh/export/newblerv2/sfffile  -i t15$tempvar -o ecol.rand757660.sel.sff Ecoli.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecst15$tempvar ecol.rand757660.sel.sff");

system("head -n 250000 Ecoli.avgqual.sort > t25$tempvar");
system("/home/animesh/export/newblerv2/sfffile  -i t25$tempvar -o ecol.rand757660.sel.sff Ecoli.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecst25$tempvar ecol.rand757660.sel.sff");

__END__
system("head -n 750000 Ecoli.avgqual.sort > t75$tempvar");
system("/home/animesh/export/newblerv2/sfffile  -i t75$tempvar -o ecol.rand757660.sel.sff Ecoli.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecst75$tempvar ecol.rand757660.sel.sff");

__END__
system("head -n 50000 Ecoli.avgqual.sort > t5$tempvar");
system("/home/animesh/export/newblerv2/sfffile  -i t5$tempvar -o ecol.rand757660.sel.sff Ecoli.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecst5$tempvar ecol.rand757660.sel.sff");

system("head -n 100000 Ecoli.avgqual.sort > t10$tempvar");
system("/home/animesh/export/newblerv2/sfffile  -i t10$tempvar -o ecol.rand757660.sel.sff Ecoli.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecst10$tempvar ecol.rand757660.sel.sff");

system("head -n 200000 Ecoli.avgqual.sort > t20$tempvar");
system("/home/animesh/export/newblerv2/sfffile  -i t20$tempvar -o ecol.rand757660.sel.sff Ecoli.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecst20$tempvar ecol.rand757660.sel.sff");

system("head -n 300000 Ecoli.avgqual.sort > t30$tempvar");
system("/home/animesh/export/newblerv2/sfffile  -i t30$tempvar -o ecol.rand757660.sel.sff Ecoli.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecst30$tempvar ecol.rand757660.sel.sff");

system("head -n 350000 Ecoli.avgqual.sort > t35$tempvar");
system("/home/animesh/export/newblerv2/sfffile  -i t35$tempvar -o ecol.rand757660.sel.sff Ecoli.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecst35$tempvar ecol.rand757660.sel.sff");

system("head -n 750000 Ecoli.avgqual.sort > t75$tempvar");
system("/home/animesh/export/newblerv2/sfffile  -i t75$tempvar -o ecol.rand757660.sel.sff Ecoli.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecst75$tempvar ecol.rand757660.sel.sff");


#}

__END__
system("split t1$tempvar");
system("split t1$tempvar");
system("split t1$tempvar");


__END__
  872  /home/animesh/bin/sfffile -i t1 -o ecol.rand757660.sff Ecoli.sff 
  873  newb ecol.rand757660.sff 
  874  ls -i t1 -o ecol.rand757660.sff Ecoli.sff 
  876  newblerv2/bin/sfffile  -i t1 -o ecol.rand757660.sff Ecoli.sff 
  877  newblerv2/bin/sfffile  -i t1 -o ecol.rand757660.sff Ecoli.sff 
  878  newblerv2/bin/runAssembly ecol.rand757660.sff 
  885  newblerv2/bin/sfffile  -i xaa -o ecol.rand757660.1.sff Ecoli.sff 
  886  newblerv2/bin/sfffile  -i xab -o ecol.rand757660.2.sff Ecoli.sff 
  891  ../newblerv2/bin/addRun ../ecol.rand757660.2.sff 
 1021  history | grep ecoli
 1022  history | grep ecol



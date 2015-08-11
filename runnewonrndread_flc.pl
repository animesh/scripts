#for($c=1;$c<=10;$c++){
$tempvar=time;
$c=1;
print "File $c selected reads are being written to ecflcxlr$tempvar\n";
system("/home/animesh/export/newblerv23/bin/sfffile  -xlr -o Ecoli.xlr.sff Ecoli.sff");
system("/home/animesh/export/newblerv23/bin/sffinfo -a Ecoli.xlr.sff > ecflcxlr$tempvar");
system("split -l 400000 ecflcxlr$tempvar");
system("/home/animesh/export/newblerv23/bin/sfffile -i xaa  -o Ecoli.xlr.1.sff Ecoli.xlr.sff");
system("/home/animesh/export/newblerv23/bin/sfffile -i xab  -o Ecoli.xlr.2.sff Ecoli.xlr.sff");
system("/home/animesh/export/newblerv23/bin/sfffile -i xac  -o Ecoli.xlr.3.sff Ecoli.xlr.sff");
system("/home/animesh/export/newblerv23/bin/sfffile -i xad  -o Ecoli.xlr.4.sff Ecoli.xlr.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecflcxlr Ecoli.xlr.1.sff");
system("/home/animesh/export/newblerv2/addRun  ecflcxlr/ Ecoli.xlr.2.sff");
system("/home/animesh/export/newblerv2/runProject  ecflcxlr/");
system("/home/animesh/export/newblerv2/addRun  ecflcxlr/ Ecoli.xlr.3.sff");
system("/home/animesh/export/newblerv2/runProject  ecflcxlr/");
system("/home/animesh/export/newblerv2/addRun  ecflcxlr/ Ecoli.xlr.4.sff");
system("/home/animesh/export/newblerv2/runProject  ecflcxlr/");
print "File $c selected reads are being written to ecflcflx$tempvar\n";
system("/home/animesh/export/newblerv23/bin/sfffile  -flx -o Ecoli.flx.sff Ecoli.sff");
system("/home/animesh/export/newblerv23/bin/sffinfo -a Ecoli.flx.sff > ecflcflx$tempvar");
system("split -l 400000 ecflcflx$tempvar");
system("/home/animesh/export/newblerv23/bin/sfffile -i xaa  -o Ecoli.flx.1.sff Ecoli.flx.sff");
system("/home/animesh/export/newblerv23/bin/sfffile -i xab  -o Ecoli.flx.2.sff Ecoli.flx.sff");
system("/home/animesh/export/newblerv23/bin/sfffile -i xac  -o Ecoli.flx.3.sff Ecoli.flx.sff");
system("/home/animesh/export/newblerv23/bin/sfffile -i xad  -o Ecoli.flx.4.sff Ecoli.flx.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecflcflx Ecoli.flx.1.sff");
system("/home/animesh/export/newblerv2/addRun  ecflcflx/ Ecoli.flx.2.sff");
system("/home/animesh/export/newblerv2/runProject  ecflcflx/");
system("/home/animesh/export/newblerv2/addRun  ecflcflx/ Ecoli.flx.3.sff");
system("/home/animesh/export/newblerv2/runProject  ecflcflx/");
system("/home/animesh/export/newblerv2/addRun  ecflcflx/ Ecoli.flx.4.sff");
system("/home/animesh/export/newblerv2/runProject  ecflcflx/");
print "File $c selected reads are being written to ecflc20$tempvar\n";
system("/home/animesh/export/newblerv23/bin/sfffile  -20 -o Ecoli.20.sff Ecoli.sff");
system("/home/animesh/export/newblerv23/bin/sffinfo -a Ecoli.20.sff > ecflc20$tempvar");
system("split -l 400000 ecflc20$tempvar");
system("/home/animesh/export/newblerv23/bin/sfffile -i xaa  -o Ecoli.20.1.sff Ecoli.20.sff");
system("/home/animesh/export/newblerv23/bin/sfffile -i xab  -o Ecoli.20.2.sff Ecoli.20.sff");
system("/home/animesh/export/newblerv23/bin/sfffile -i xac  -o Ecoli.20.3.sff Ecoli.20.sff");
system("/home/animesh/export/newblerv23/bin/sfffile -i xad  -o Ecoli.20.4.sff Ecoli.20.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecflc20 Ecoli.20.1.sff");
system("/home/animesh/export/newblerv2/addRun  ecflc20/ Ecoli.20.2.sff");
system("/home/animesh/export/newblerv2/runProject  ecflc20/");
system("/home/animesh/export/newblerv2/addRun  ecflc20/ Ecoli.20.3.sff");
system("/home/animesh/export/newblerv2/runProject  ecflc20/");
system("/home/animesh/export/newblerv2/addRun  ecflc20/ Ecoli.20.4.sff");
system("/home/animesh/export/newblerv2/runProject  ecflc20/");



__END__
print "File $c selected reads are being written to ecflc400$tempvar\n";
system("/home/animesh/export/newblerv23/bin/sfffile  -c 400 -o Ecoli.400.sff Ecoli.sff");
system("/home/animesh/export/newblerv23/bin/sffinfo -a Ecoli.400.sff > ecflc400$tempvar");
system("split -l 400000 ecflc400$tempvar");
system("/home/animesh/export/newblerv23/bin/sfffile -i xaa  -o Ecoli.400.1.sff Ecoli.400.sff");
system("/home/animesh/export/newblerv23/bin/sfffile -i xab  -o Ecoli.400.2.sff Ecoli.400.sff");
system("/home/animesh/export/newblerv23/bin/sfffile -i xac  -o Ecoli.400.3.sff Ecoli.400.sff");
system("/home/animesh/export/newblerv23/bin/sfffile -i xad  -o Ecoli.400.4.sff Ecoli.400.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecflc400 Ecoli.400.1.sff");
system("/home/animesh/export/newblerv2/addRun  ecflc400/ Ecoli.400.2.sff");
system("/home/animesh/export/newblerv2/runProject  ecflc400/");
system("/home/animesh/export/newblerv2/addRun  ecflc400/ Ecoli.400.3.sff");
system("/home/animesh/export/newblerv2/runProject  ecflc400/");
system("/home/animesh/export/newblerv2/addRun  ecflc400/ Ecoli.400.4.sff");
system("/home/animesh/export/newblerv2/runProject  ecflc400/");

__END__
$c++;
print "File $c selected reads are being written to ecxlr$tempvar\n";
system("/home/animesh/export/newblerv2/sfffile  -xlr -o Ecoli.xlr.sff Ecoli.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecxlr$tempvar Ecoli.xlr.sff");
$c++;
print "File $c selected reads are being written to ecflx$tempvar\n";
system("/home/animesh/export/newblerv2/sfffile  -flx -o Ecoli.flx.sff Ecoli.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ecflx$tempvar Ecoli.flx.sff");
$c++;
print "File $c selected reads are being written to ec20$tempvar\n";
system("/home/animesh/export/newblerv2/sfffile  -20 -o Ecoli.20.sff Ecoli.sff");
system("/home/animesh/export/newblerv2/runAssembly -nrm -g -finish  -o ec20$tempvar Ecoli.20.sff");


#}

__END__
 1012  split -l 400000 t751302124005 
 1019  nohup /home/animesh/export/newblerv2/sfffile -i xaa  -o ecol.rand757660.sel.1.sff ecol.rand757660.sel.sff &
 1020  nohup /home/animesh/export/newblerv2/sfffile -i xab  -o ecol.rand757660.sel.2.sff ecol.rand757660.sel.sff &
 1023  nohup /home/animesh/export/newblerv2/runAssembly -nrm -g -finish -o e75 ecol.rand757660.sel.1.sff &

       -xlr | -gsxlr    Convert all flowgrams to GS XLR cycles (200)
       -flx | -gsflx    Convert all flowgrams to GS FLX cycles (100)
       -20 | -gs20      Convert all flowgrams to GS 20 cycles (42)
       -t filename      File containing accno/trim line information
       -tr filename     Same as '-t', but resets trim using this file
       -mcf filename    Use this MID configuration file for multiplex info
       -nmft            Do not write a manifest into the SFF file

   The sfffile program constructs a single SFF file containing the reads from
   a list of SFF files and/or 454 runs.  The reads written to the new SFF
   file can be filtered using inclusion and exclusion lists of accessions.

[animesh@astrakan flower]$ /home/animesh/export/newblerv2/sfffile -c 400 Ecoli.sff -o Ecoli.400.sff
Error:  File/Directory not found:  -o
Error:  File/Directory not found:  Ecoli.400.sff
[animesh@astrakan flower]$ /home/animesh/export/newblerv2/sfffile -c 400 -o Ecoli.400.sff Ecoli.sff 
Reading the input SFF file(s)...

[animesh@astrakan flower]$ /home/animesh/export/newblerv2/sfffile -c 400 -o Ecoli.400.sff Ecoli.sff 
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



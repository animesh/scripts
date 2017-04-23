#!/usr/bin/perl
#!/usr/local/bin/perl -w
open (GP, 'C:\devel\gnuplot\binaries\wgnuplot.exe') or die "no gnuplot";
# force buffer to flush after each write
use FileHandle;
GP->autoflush(1);
print GP "set term windows;plot \"jj.dat\" with lines\n";
#
close GP


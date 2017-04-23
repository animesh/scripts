#!/usr/bin/perl
use Chart::Graph::Gnuplot qw(gnuplot);
print "\nenter the name of file to plot\t::";
$file=<>;
chomp $file;
gnuplot(\%plot,[{"title" => $file,"style" => "lines","type" => "file"},$file],);
system "display untitled-gnuplot.png";
 

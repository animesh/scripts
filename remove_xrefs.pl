#!/usr/bin/perl -w
$_="";
read(STDIN, $_, 9999999);
s/\s*\(\@pxref{[^}]*}\)//g;
s/\s*\@xref{[^}]*}.//g;
s/,\././g;
print;


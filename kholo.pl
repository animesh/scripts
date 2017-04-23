#!/usr/bin/perl
system "more *sure>file.col";
system "more *maybe>>file.col";
open F1,"file.col";
while($line=<F1>)
{
system "cat $line";
}


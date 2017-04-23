#!/usr/bin/perl
open f1,"genscanresult.txt";
while($line=<f1>)
{
$linenew=uc($line);
print $linenew;
}


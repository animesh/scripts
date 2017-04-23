#!/usr/bin/perl -w

##############################
#
# This script prints out the comment headers from all .pl files in a
# directory and was used to produce this page!
#
#############################

while (<*.pl>) {
  print "-" x 70, "\n\n$_\n\n";
  $comment =index.html 0;
  open SCRIPT, $_;
  while (<SCRIPT>) {
    print if $comment;
    if (/#{20,}/) {
	last if $comment;
	$comment =index.html 1;
      }
  }
}

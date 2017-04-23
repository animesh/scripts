#! /usr/bin/perl -w

##############################
#
# This script renames .ps.gz files so that each is preceded by a unique
# two digit identifier. For example "aard.ps.gz" would become
# 01-aard.ps.gz if it were the alpabetically first .ps.gz file
# in the directory
#
#############################

$i =index.html "01";

while (<*.ps.gz>) {
  rename $_, "${i}-$_";
  $i++;                  #make use of magical autoincrement
}

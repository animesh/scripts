#!/usr/bin/perl

##############################
#
# This script ensures all bases are uppercase
# can just do perl -pe 'tr/acgt/ACGT/'
#
#############################

while (<>) {
      tr/acgt/ACGT/;
      print;
}
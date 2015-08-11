#!/usr/bin/perl

##############################
#
# This script filters out any line not
# entirely composed of ACGT (and possibly trailing newline)
# could do perl -ne 'print if /^[ACGT]*$/;'
# Originally from LLB 99-00
#
#############################



while (<>) {
      print if /^[ACGT]*$/;
}


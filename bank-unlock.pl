#!/usr/bin/perl

use strict;
use File::Basename;

if ( scalar (@ARGV) == 0 ) {
    die "USAGE: $0  <bankdir>\n";
}

foreach (@ARGV)
{
  my $dir = $_;

  if ( !defined ($dir) || !(-d $dir) ) {
      print STDERR "ERROR: Cannot find bank dir '$dir'\n";
      next;
  }

  if ( !(-w $dir) || !(-x $dir) ) {
      print STDERR "ERROR: Invalid permissions for bank dir '$dir'\n";
      next;
  }

  my $banks = 0;
  my $flcks = 0;
  my $blcks = 0;

  print STDERR "Entering '$dir'\n";
  while ( glob "$dir/*.ifo" ) {
      my @lines;
      my @locks;
      my $file = $_;
      my $base = basename ($file);

      #-- Read the IFO file
      open (IFO, "<$file")
          or die "ERROR: Could not open file '$base' for reading, $!\n";

      $_ = <IFO>;
      push @lines, $_;
      if ( /([\w]{3}) BANK INFORMATION/ ) {
          $banks ++;
          print STDERR "Found $1 bank\n";
          my $lock = "$1.lck";
          if ( -e "$dir/$lock" ) {
              $flcks ++;
              unlink ("$dir/$lock")
                  or die "ERROR: Could not unlink '$lock', $!\n";
              print STDERR "  unlinking '$lock'\n";
          }
      } else {
          print STDERR "WARNING: Unrecognized file '$base' skipped\n";
          next;
      }

      while ( <IFO> ) {
          push @lines, $_;
          if ( /^locks =/ ) {
              while ( <IFO> ) {
                  $blcks ++;
                  push @locks, $_;
                  chomp;
                  print STDERR "  unlocking '$_'\n";
              }
              last;
          }
      }

      close (IFO)
          or die "ERROR: Could not close '$base', $!\n";


      #-- Rewrite the IFO file without the locks
      if ( scalar (@locks) ) {
          open (IFO, ">$file")
              or die "ERROR: Could not open '$file' for writing, $!\n";
          
          foreach (@lines) {
              print IFO;
          }
          
          close (IFO)
              or die "ERROR: Could not close '$file', $!\n";
      }
  }

  print "\n";
  print "IFOs found: $banks\n";
  print "File locks: $flcks\n";
  print "Bank locks: $blcks\n";

  print "\n";
  print "\n";
}

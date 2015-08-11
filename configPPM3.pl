#!/usr/bin/perl

my $p_ppm3 = $ARGV[0];
my $p_cdpkgs = $ARGV[1];
my $p_pdpkgs = "http://ActivePerlEE.ActiveState.com/packages/5.8.4";

Win32::SetChildShowWindow(0) if defined &Win32::SetChildShowWindow;

#system("$p_ppm3 repo add \"ActivePerl Enterprise Edition Package Repository\" $p_pdpkgs");
system("$p_ppm3 repo add \"LocalCD\" $p_cdpkgs");
system("$p_ppm3 repo del \"ActiveState Package Repository\"");
system("$p_ppm3 repo del \"ActiveState PPM2 Repository\"");

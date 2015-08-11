# !/usr/bin/perl

use strict;
	
	my $sTest = "G283";

	my ( $sSym, $iDig ) = ($sTest =~ m/(\D+)(\d+)/);
	printf( "sSym='$sSym', iDig='$iDig'\n" );

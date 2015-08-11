#!/usr/bin/perl
# gcd.pl     sharma.animesh@gmail.com     2006/09/13 09:10:40

use warnings;
use strict;
$|=1;
use Data::Dumper;
my $thresh;
if($ARGV[0]){$thresh=$ARGV[0];}
else{$thresh=10000;}

my $vop=abs(sqrt(6/(est_pi($thresh))));
print $vop;

sub est_pi{
    my $trial=0;
    my $threshold=shift;
    my $veto;
    my $vneto;
    while($trial<$threshold){
	$trial++;
	my $val=gcd(int(rand($threshold)),int(rand($threshold)),$trial);
	if($val==1){$veto++;}
	else{$vneto++;}
    }
    print "$veto\t$vneto\t$trial\n";
    return ($veto/$trial);
}
sub gcd{
    my $x1=shift;
    my $x2=shift;
    my $t=shift;
    if($x1==0 or $x2==0){return 0;}
    if($x2>$x1){
	print "$x1 and $x2 are being switched to\t";
	$x1=$x1^$x2;
	$x2=$x2^$x1;
	$x1=$x1^$x2;
	print "$x1 - $x2 [$t] \n";
    }
    if($x1>=$x2){
	while($x1%$x2!=0){
	    my $temp=$x2;
	    $x2=$x1%$x2;
	    $x1=$temp;
	}
    }

    return $x2;
}



__END__

=head1 NAME

gcd.pl

=head1 SYNOPSIS



=head1 DESCRIPTION

Stub documentation for gcd.pl, 
created by template.el.

It looks like the author of this script was negligent 
enough to leave the stub unedited.

=head1 AUTHOR

Animesh Sharma, E<lt>krishna_bhakt@BHAKTI-YOGAE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Animesh Sharma

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

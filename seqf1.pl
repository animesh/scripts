#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Code base of Animesh Sharma [ sharma.animesh@gmail.com ]

#!/usr/bin/perl
# seqf1.pl     krishn_bhakt@Bhakti-Yoga     2007/08/18 16:11:34

use warnings;
use strict;
$|=1;
use Data::Dumper;
my $f= shift @ARGV;
my $fo = $f.".out";
open(F,$f);
open(FO,">$fo");
my $l;
my $c;
while($l=<F>){
    $l=~s/\s+//g;
    if($l eq ""){next;}
    if($l=~/^\>/){
	$c++;
	$l=~s/\>//;
	print FO">S$c $l\n";
    }
    else{
	print FO"$l\n";
    }
}




__END__

=head1 NAME

seqf1.pl

=head1 SYNOPSIS



=head1 DESCRIPTION

Stub documentation for seqf1.pl, 
created by template.el.

It looks like the author of this script was negligent 
enough to leave the stub unedited.

=head1 AUTHOR

, E<lt>krishn_bhakt@Bhakti-YogaE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by 

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

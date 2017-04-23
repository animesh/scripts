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
# match_string.pl     krishna_bhakt@BHAKTI-YOGA     2006/09/04 10:45:58

use warnings;
use strict;
$|=1;
use Data::Dumper;
my $seq_i=shift @ARGV;
my $seq_o=shift @ARGV;
my $start_motif=4;
my $length_motif=4;
	    while ($seq_o =~ /$seq_i/g) {
		my $posi= ((pos $seq_o) - length($&) +1);
		my $start_posi=$posi-$start_motif-1;
		my $moti = substr($seq_o,$start_posi,$length_motif);
		my $len=length($moti);
		(pos $seq_o)=(pos $seq_o)-length($&) +1;
		print ">Pos in Seq $seq_o- $posi - $start_posi ($length_motif)\t$moti\n$seq_o\n$seq_i\n";
	    }




__END__

=head1 NAME

match_string.pl

=head1 SYNOPSIS



=head1 DESCRIPTION

Stub documentation for match_string.pl, 
created by template.el.

It looks like the author of this script was negligent 
enough to leave the stub unedited.

=head1 AUTHOR

, E<lt>krishna_bhakt@BHAKTI-YOGAE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by 

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

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
# seq_form.pl     sharma.animesh@gmail.com     2006/09/10 13:54:46

use warnings;
use strict;
$|=1;
use Data::Dumper;
my $seq;
open(F,"s1.txt");
while(my $l=<F>){
    $l=~s/[0-9]|\s+//g;
    chomp $l;
    $seq.=$l;
}
$seq=uc($seq);
$seq=reverse($seq);
$seq=~tr/ATGC/TACG/d;

print "$seq\n";


__END__

=head1 NAME

seq_form.pl

=head1 SYNOPSIS



=head1 DESCRIPTION

Stub documentation for seq_form.pl, 
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

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
# analyotp1.pl     krishn_bhakt@Bhakti-Yoga     2007/08/18 18:47:06

use warnings;
use strict;
$|=1;
use Data::Dumper;

use Bio::AlignIO;

my $fin=shift @ARGV;
my $str = Bio::AlignIO->new(-file=> $fin);
my $aln = $str->next_aln();
#print $str;
#print $aln->length, "\n";
#print $aln->no_residues, "\n";
#print $aln->is_flush, "\n";
#print $aln->no_sequences, "\n";
#print $aln->percentage_identity, "\n";
#print $aln->consensus_string(50), "\n";
my $seq;
my %seqn;
my %seqs;
my @seqm;
my $cont=0;
my $c2;
#for(my $c1=0;$c1<=($aln->length);$c1++){my $seqcol="seqc".$c1;}
foreach $seq ( $aln->each_seq() ) {

    $seqs{$cont}=$seq->seq();
    $seqn{$cont}=$seq->display_id();
    my @t=split(//,$seqs{$cont});
    for($c2=0;$c2<=$#t;$c2++){
	$seqm[$cont][$c2]=$t[$c2];
    }
    $cont++;
    #print $seq->display_id(),"\n",$seq->seq(),"\n";
}
#print "$c2\t$cont\n";
for(my $c3=0;$c3<$c2;$c3++){
    my @sequ;
    for(my $c4=0;$c4<$cont;$c4++){
	push(@sequ,$seqm[$c4][$c3]);
    }
    my $uv=uniqelem(\@sequ);
    print $c3+1,"\t$uv\n";
}

sub uniqelem {
    my $lref=shift;
    my @list=@$lref;
    my %seen = ();
    my @uniqu = grep { ! $seen{$_} ++ } @list;
    my $returnuniqelem=(@uniqu);
    return($returnuniqelem);
}
__END__

=head1 NAME

analyotp1.pl

=head1 SYNOPSIS



=head1 DESCRIPTION

Stub documentation for analyotp1.pl, 
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

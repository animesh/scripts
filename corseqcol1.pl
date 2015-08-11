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
# corseqcol1.pl     krishn_bhakt@Bhakti-Yoga     2007/08/19 08:47:06

use warnings;
use strict;
$|=1;
use Data::Dumper;

use Bio::AlignIO;

my $fin=shift @ARGV;
my $fout=$fin.".out";
my $str = Bio::AlignIO->new(-file=> $fin);
my $aln = $str->next_aln();
my $seq;
my %seqn;
my %seqs;
my @seqm;
my $cont=0;
my $c2;
open(FO,">$fout");


my %h2a = (
    '-' => 0,
	'I'		 => 		4.5,
	'V'		 => 		4.2,
	'L'		 => 		3.8,
	'F'		 => 		2.8,
	'C'		 => 		2.5,
	'M'		 => 		1.9,
	'A'		 => 		1.8,
	'G'		 => 		-0.4,
	'T'		 => 		-0.7,
	'W'		 => 		-0.9,
	'S'		 => 		-0.8,
	'Y'		 => 		-1.3,
	'P'		 => 		-1.6,
	'H'		 => 		-3.2,
	'E'		 => 		-3.5,
	'Q'		 => 		-3.5,
	'D'		 => 		-3.5,
	'N'		 => 		-3.5,
	'K'		 => 		-3.9,
	'R'		 => 		-4.5,
	'B'		 => 		-3.5,
	'Z'		 => 		-3.5,
	'X'		 => 		0,
	'*'		 => 		-4.5,
);

foreach $seq ( $aln->each_seq() ) {

    $seqs{$cont}=$seq->seq();
    $seqn{$cont}=$seq->display_id();
    my @t=split(//,$seqs{$cont});
    for($c2=0;$c2<=$#t;$c2++){
	$seqm[$cont][$c2]=$t[$c2];
    }
    $cont++;
    print $seq->display_id(),"\n",$seq->seq(),"\n";
}

for(my $c4=0;$c4<$cont-1;$c4++){
    my @sequ;
    for(my $c3=0;$c3<$c2;$c3++){
	push(@sequ,($h2a{$seqm[$c4+1][$c3]}-$h2a{$seqm[$c4][$c3]}));
	print "$c3-$c4\t$seqm[$c4][$c3] $c3-$c4 $seqm[$c4+1][$c3]\n";
    }
    my ($uv)=printelem(\@sequ);
    print $c4,"\-",$c4+1,"\t$uv\n";
}

sub printelem {
    my $lref=shift;
    my $strcrt;
    my @list=@$lref;
    for(my $c5=0;$c5<=$#list;$c5++){
	print FO"$list[$c5]\t";
	$strcrt.=$list[$c5];
    }
    print FO"\n";    
    return($strcrt);
}



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

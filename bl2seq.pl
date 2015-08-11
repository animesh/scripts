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
# bl2seq.pl     krishna_bhakt@BHAKTI-YOGA     2006/09/05 06:14:58

use warnings;
use strict;
use Bio::Tools::BPbl2seq;
use Bio::Root::IO;
my $report = new Bio::Tools::BPbl2seq(-file => "filer", -report_type => 'blastn');
while( my $hsp = $report->next_feature ) {
#while( my $hit = $report->next_feature ) {    
# print "\thit name: ", $hit->name(),"\n";    
#  while( my $hsp = $hit->next_hsp()) { 	
    #print "E: ", $hsp->evalue(), "  frac_identical: ",	$hsp->frac_identical(), "\n";   # }}
   		   my $strand=$hsp->strand;
    #foreach (keys %stran){print "$_=>stran{$_}";}
    if($hsp->score>0){
	print join("\t",
				"Score", $hsp->score,
				"Bits", $hsp->bits,
				"Percent", int $hsp->percent,
				"P-Value", $hsp->P,
				"Match", $hsp->match,
				"Positive", $hsp->positive,
				"Start", $hsp->start,
				"End", $hsp->end,
				"Length", $hsp->length,
				"QuerySeq", $hsp->querySeq,
				"SubSeq", $hsp->sbjctSeq,
				"Homology", $hsp->homologySeq,
				"Query start" , $hsp->query->start, 
				"Query end",$hsp->query->end,
				"Query Strand", $hsp->query->strand,
				"Query ID", $hsp->query->seq_id,
				"Hit start", $hsp->hit->start,
				"Hit end", $hsp->hit->end,
				"Hit Strand", $hsp->hit->strand,
				"Hit ID", $hsp->hit->seq_id,
				"Sub start", $hsp->sbjct->start,
				"Sub end", $hsp->sbjct->end,
				"Sub Strand", $hsp->sbjct->strand,
				"Sub ID", $hsp->sbjct->seq_id,
				"Direction", $hsp->strand,
				"Gaps", $hsp->gaps,
				"SubjectName", $report->sbjctName,
		   "Dir", $hsp->hit->strand), "\n";
}}




__END__

=head1 NAME

bl2seq.pl

=head1 SYNOPSIS



=head1 DESCRIPTION

Stub documentation for bl2seq.pl, 
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

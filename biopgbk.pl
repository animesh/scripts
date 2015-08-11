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
use Bio::SeqIO;
$gb_file="CP258.gb";
#$gb_file="D:\\animesh\\projects\\research\\ram_cd\\h37rv.gbk";
       my $seqio_object = Bio::SeqIO->new(-file => $gb_file);
       my $seq_object = $seqio_object->next_seq;

       for my $feat_object ($seq_object->get_SeqFeatures) {
         if ($feat_object->primary_tag eq "CDS") {
           print $feat_object->spliced_seq->seq,"\n";
           # e.g. 'ATTATTTTCGCTCGCTTCTCGCGCTTTTTGAGATAAGGTCGCGT...'
           if ($feat_object->has_tag('gene')) {
             for my $val ($feat_object->get_tag_values('gene')){
               #print "gene: ",$val,"\n";
               # e.g. 'NDP', from a line like '/gene="NDP"'
             }
           }
         }
       }

#my @cds_features = grep { $_->primary_tag eq 'CDS' } Bio::SeqIO->new(-file => $gb_file)->next_seq->get_SeqFeatures;

#my %gene_sequences = map {$_->get_tag_values('gene'), $_->spliced_seq->seq } @cds_features;

#$run_struct = sub {
#  use Bio::Root::IO;
#  eval { require Bio::Structure::Entry;
#         require Bio::Structure::IO;
#       };
#  if ( $@ ){
#    print STDERR "Cannot find Bio::Structure modules\n";
#    print STDERR "Cannot run run_struct:\n";
#    return 0;
#  } else {
#    print $outputfh "\nBeginning Structure object example... \n";
#    # testing PDB format
#    my $pdb_file = Bio::Root::IO->catfile("t","data","pdb1bpt.ent"); 
#    my $structio = Bio::Structure::IO->new(-file  => $pdb_file,
#                                           -format=> 'PDB');
#    my $struc = $structio->next_structure;
#    my ($chain) = $struc->chain;
#    print $outputfh " The current chain is ",  $chain->id ," \n";
#    my $pseq = $struc->seqres;
#    print $outputfh " The first 20 residues of the sequence corresponding " .
#    "to this structure are " . $pseq->subseq(1,20) . " \n";
#    return 1;
#  }
#} ;

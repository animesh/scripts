#!/usr/bin/perl
 use Bio::SeqIO;
    $in  = Bio::SeqIO->new(-file => "inputfilename" , '-format' => 'Fasta');
    $out = Bio::SeqIO->new(-file => ">outputfilename" , '-format' => 'EMBL');
    # note: we quote -format to keep older perl's from complaining.
    while ( my $seq = $in->next_seq() )
     {
        $out->write_seq($seq);
     }
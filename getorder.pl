#!/usr/bin/perl
# getorder.pl     sharma.animesh@gmail.com     2009/03/09 10:01:28

use warnings;
use strict;
$|=1;
use Data::Dumper;
my $file=shift @ARGV;
open(F,$file);

my $pia;
my $ala;
my $eva;
my $bsa;
my $cnt;
my %us;
my $pit=0;
my $alt=0;
my $evt=0.0000000001;
my $bst=0;
my %hitpos;
my %hitname;

while(<F>){
    my @tmp=split(/\s+/,$_);
    my $Query_id=$tmp[0];        
    my $Subj_id=$tmp[1];        
    my $per_iden=$tmp[2];        
    my $aln_length=$tmp[3];      
    my $mismatches=$tmp[4];      
    my $gap_open=$tmp[5];        
    my $q_start=$tmp[6];
    my $q_end=$tmp[7];   
    my $s_start=$tmp[8];
    my $s_end=$tmp[9];   
    my $e_value=$tmp[10];
    my $bit_score=$tmp[11];
    my $namestr=substr($Query_id,7,8);    
    my $namesubstr=substr($Query_id,7,6);
    
    if($per_iden >= $pit and $aln_length >= $alt and $e_value <= $evt and $bit_score >= $bst){
        $pia+=($per_iden);
        $ala+=($aln_length);
        $eva+=($e_value);
        $bsa+=($bit_score);
	$cnt++;
        $us{$Query_id}++;
	$hitname{$namesubstr}++;	
	$hitpos{$namestr}="$s_start-$s_end";
        print "$hitname{$namesubstr}\t$hitpos{$namestr}\t$Query_id\tThere are $cnt\tmatches with threshold $per_iden (Per Id), $aln_length (Aln Len), $e_value (e-val), $bit_score (bit score)\n";

  }
}
        $pia/=$cnt;
        $ala/=$cnt;
        $eva/=$cnt;
        $bsa/=$cnt;
 
print "$cnt\tmatches with threshold $pit( Avg Per Id - $pia ), $alt (Avg Aln Len - $ala ), $evt (Avg e-val - $eva ), $bst (Avg bit score - $bsa )\n";
my $cseq;
my $tseq;
foreach (keys %us) {$cseq++;$tseq+=$us{$_};}
print "Total - $tseq\tUniq - $cseq\n";

#parseres.pl (END) 




__END__

=head1 NAME

getorder.pl

=head1 SYNOPSIS



=head1 DESCRIPTION

Stub documentation for getorder.pl, 
created by template.el.

It looks like the author of this script was negligent 
enough to leave the stub unedited.

=head1 AUTHOR

Animesh Sharma, E<lt>ash022@uib.noE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Animesh Sharma

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

#!/usr/bin/perl
# match_string.pl     krishna_bhakt@BHAKTI-YOGA     2006/09/04 10:45:58

use warnings;
use strict;
$|=1;
use Data::Dumper;
my $sim_thresh=90;

my $file1=shift @ARGV;my @seqname;my @seq;my $seq="";my $line;
open(F1,$file1)||die "can't open";
while ($line = <F1>) {
        chomp ($line);
             push(@seqname,$line);
}
close F1;

my $file2=shift @ARGV;my @seqnamen;my @seqn;my $seqn="";my $linen;

open(F2,$file2)||die "can't open";
while ($linen = <F2>) {
        chomp ($linen);
        if ($linen =~ /^>/){
             push(@seqnamen,$linen);
                if ($seqn ne ""){
              push(@seqn,$seqn);
              $seqn = "";
            }
      } else {$seqn=$seqn.$linen;
      }
}
push(@seqn,$seqn);close F2;



my $c1;my $c2;
for($c1=0;$c1<=$#seqname;$c1++){
	for($c2=0;$c2<=$#seqn;$c2++){
		my @ty=split(/\t/,$seqname[$c1]);
                @ty=split(/\//,$ty[3]);
		my @se=split(/\-/,$ty[1]);
		my $ust=$se[0];
		my $dst=$se[1];
		smatch($ty[0],$seqnamen[$c2],$ust,$dst);
		#my ($per_sim,$length)=nw_string_match($seq[$c1],$seqn[$c2]);
		#if($per_sim>$sim_thresh){print "$per_sim\t$length\n";last;}
		# print "$c1-C1-@seq[$c1]\n$c2-C2-@seqn[$c2]\n";
	}
}


#foreach $w (sort {$a<=>$b} keys %m){print "$w\t$m{$w}\n";$t+=$m{$w};}

sub smatch {
	my $seq_i=shift;
	my $seq_o=shift;
                my $ust=shift;
                my $dst=shift;
 
#         print "$c1-$seq_i\t$c2-$seq_o\n";
	my $length_motif=22;
	
		    if ($seq_o =~ /$seq_i/ and $ust>$length_motif) {
			
		    #while ($seq_o =~ /$seq_i/g) {
			my $moti1 = substr($seqn[$c2],$ust-$length_motif-1,$length_motif);
			my $moti2 = substr($seqn[$c2],$dst+1,$length_motif);
			my $len1=length($moti1);
			my $len2=length($moti2);
			#print "UST-$ust\tDST-$dst\t$seq_i\t$seq_o - $start_posi - $end_posi\n";
			print ">Pos in Seq $seq_o\t- Pos - $ust\n>Upstream UF - $ust (Length-$len1) \n$moti1\n>Downstream DF - $dst (Length-$len2)\n$moti2\nFor Seqlist $seqname[$c1]\n";
		    }
}

sub nw_string_match{
	my $seq_i=shift;
	my $seq_o=shift;
#        print "$c1-$seq_i\n$c2-$seq_o ...\n";
        print "$c1 - $seqname[$c1]\t$c2 - $seqnamen[$c2] ...\t";
	my $length_motif=22;
   
	    open(F1,">file1");
	    open(F2,">file2");
	    print F1">$seqnamen[$c2]\n$seqn[$c2]\n";
	    print F2">$seqname[$c1]\n$seq[$c1]\n";
	    system("water file1 file2 -gapopen=10 -gapext=0.5 -outfile=file3");
	    #system("needle file1 file2 -gapopen=10 -gapext=0.5 -outfile=file3");
	    open(FN,"file3");
	    my $length;
            while(my $line=<FN>){
		if($line=~/^# Length: /){chomp $line;my @t=split(/\:/,$line);$length=$t[1];}
		if($line=~/^# Identity:     /){
		   my @t=split(/\(|\)/,$line);
		   $t[1]=~s/\%|\s+//g;
		   my $per_sim=$t[1]+0;
		   return($per_sim,$length);
		}
   }
	    close FN;
	    close F1;
	    close F2;

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

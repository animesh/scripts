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
use strict;
my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;
my $other_file_pattern=shift @ARGV;chomp $other_file_pattern;

my $l_utr=500;
my $l_dutr=500;
my $sim_thresh=90;
my $n_gene_threshold=1;
my $n_other_source_threshold=1;

my $n_gene;
my $select_utr_no;
my $select_rutr_no;
my $total_seq_cnt;
my $other_total_seq_cnt;
my $n_other_source;
my $tfl1;
my $tfl2;
my %h_seq;
my %h_seq_utr;
my %h_seq_dutr;
my %h_seq_name;
my %total_seq;
my %total_seq_utr;
my %total_seq_dutr;
my %total_seq_name;
my %other_source_sequence;
my %other_source_sequence_name;
my @other_file;

my $total_file_name="total.fas";
my $total_file_name_utr="total.utr.fas";
my $total_file_name_dutr="total.dutr.fas";
my $other_total_file_name="other_total.fas";
my $other_total_file_name_utr="other_total.utr.fas";
my $other_total_file_name_dutr="other_total.dutr.fas";
open(FT,">temp.txt");
open(FTTL,">$total_file_name");
open(FTTLUTR,">$total_file_name_utr");
open(FTTLDUTR,">$total_file_name_dutr");
open(OFTTL,">$other_total_file_name");
open(OFTTLUTR,">$other_total_file_name_utr");
open(OFTTLDUTR,">$other_total_file_name_dutr");

system("ls -1 $main_file_pattern*.gb > tempfile1");
system("ls -1 $main_file_pattern*.gbk >> tempfile1");
open(FT1,"tempfile1");
while($tfl1=<FT1>){
	if($n_gene >= $n_gene_threshold){
		last;
	}
    chomp $tfl1;
	my $file=get_main_source($tfl1);
	print "$tfl1: Total Gene, $n_gene out of $n_gene_threshold $file\n";
	print FT"$tfl1: Total Gene, $n_gene out of $n_gene_threshold $file\n";
}
close FT1;

open(FT2,"tempfile1");
system("ls -1 $other_file_pattern*.gb > tempfile1");
system("ls -1 $other_file_pattern*.gbk >> tempfile1");
while($tfl2=<FT2>){
	if($n_other_source >= $n_other_source_threshold){
		last;
	}
    chomp $tfl2;
	my $file=get_other_source($tfl2);
	print "$tfl2: Other total Gene, $n_other_source out of $n_other_source_threshold $file\n";
	print FT"$tfl2: Other total Gene, $n_other_source out of $n_other_source_threshold $file\n";
}
close FT2;

my $total_seq_select=select_sim_seq();
print "\n\nTotal selected sequences are\t$total_seq_select\n";
print FT"\n\nTotal selected sequences are\t$total_seq_select\n";

close(FT);
close(FTTL);
close(FTTLUTR);
close(FTTLDUTR);
close(OFTTL);
close(OFTTLUTR);
close(OFTTLDUTR);

sub select_sim_seq{
	my $seqat;
	for(my $o=1;$o<=$n_gene_threshold;$o++){
		for(my $i=1;$i<=$n_other_source_threshold;$i++){
			my  ( $per_sim,$length,$other_start,$other_end,$strand ) = seqcomp($h_seq{$o},$other_source_sequence{$i},$h_seq_name{$o},$other_source_sequence_name{$i});
			my $ol_seq_complete=length($other_source_sequence{$i});
			print "O-$ol_seq_complete\t",length($other_source_sequence{$i}),"\tM-",length($h_seq{$o}),"\tL-$length\n $per_sim,$length,$other_start,$other_end,$strand\n",$other_end," ",$l_utr,"\t",$other_start," ",$l_dutr,"\n";
			if($per_sim>=$sim_thresh and length($h_seq{$o})==$length){
#			if($per_sim>$sim_thresh){
				$seqat++;
				if(($strand eq "reversed") && (($other_end+$l_utr)<length($other_source_sequence{$i})) && (($other_start-$l_dutr)>0)){
					my $oseq = substr($other_source_sequence{$i},($other_start-1),($other_end-$other_start+1));
					$oseq=reverse($oseq);
					$oseq=~tr/ATGC/TACG/d;
					my $oseq_utr = substr($other_source_sequence{$i},$other_end,$l_utr);
					$oseq_utr=reverse($oseq_utr);
					$oseq_utr=~tr/ATGC/TACG/d;
					my $oseq_dutr = substr($other_source_sequence{$i},($other_start-$l_dutr-1),$l_dutr);
					$oseq_dutr=reverse($oseq_dutr);
					$oseq_dutr=~tr/ATGC/TACG/d;
					my $oal_utr=length($oseq_utr);
					my $oal_dutr=length($oseq_dutr);
					my $oal=length($oseq);
					my $oseq_name_utr.="$other_source_sequence_name{$i} $other_start-$other_end UTR [$oal_utr]";
					my $oseq_name_dutr.="$other_source_sequence_name{$i} $other_start-$other_end DUTR [$oal_utr]";
					print "R->$seqat\t$other_start-$other_end-$ol_seq_complete-$l_utr-$l_dutr [$strand]\t";
					print OFTTL">$other_source_sequence_name{$i}\t$other_start-$other_end\t$ol_seq_complete [$oal]\n$oseq\n";
					print OFTTLUTR">$oseq_name_utr\n$oseq_utr\n";
					print OFTTLDUTR">$oseq_name_dutr\n$oseq_dutr\n";
					print FTTLUTR">$h_seq_name{$o}\tUTR [$l_utr]\n$h_seq_utr{$o}\n";
					print FTTLDUTR">$h_seq_name{$o}\tDUTR [$l_dutr]\n$h_seq_dutr{$o}\n";
					print FTTL">$h_seq_name{$o}\n$h_seq{$o}\n";
				}
				elsif(($strand eq "forward") && (($other_start-$l_utr)>0) && (($other_end+$l_dutr)<length($other_source_sequence{$i}))){
					my $oseq = substr($other_source_sequence{$i},($other_start-1),($other_end-$other_start+1));
					my $oseq_utr = substr($other_source_sequence{$i},($other_start-$l_utr-1),$l_utr);
					my $oseq_dutr = substr($other_source_sequence{$i},$other_end,$l_dutr);
					my $oal_utr=length($oseq_utr);
					my $oal_dutr=length($oseq_dutr);
					my $oal=length($oseq);
					my $oseq_name_utr.="$other_source_sequence_name{$i} $other_start-$other_end UTR [$oal_utr]";
					my $oseq_name_dutr.="$other_source_sequence_name{$i} $other_start-$other_end DUTR [$oal_dutr]";
					print "F->$seqat\t$other_start-$other_end-$ol_seq_complete-$l_utr-$l_dutr [$strand]\t";
					print OFTTL">$other_source_sequence_name{$i}\t$other_start-$other_end\t$ol_seq_complete [$oal]\n$oseq\n";
					print OFTTLUTR">$oseq_name_utr\n$oseq_utr\n";
					print OFTTLDUTR">$oseq_name_dutr\n$oseq_dutr\n";
					print FTTLUTR">$h_seq_name{$o}\tUTR [$l_utr]\n$h_seq_utr{$o}\n";
					print FTTLDUTR">$h_seq_name{$o}\tDUTR [$l_dutr]\n$h_seq_dutr{$o}\n";
					print FTTL">$h_seq_name{$o}\n$h_seq{$o}\n";
				}
				print "$o\t$i\t$per_sim\t$seqat\n";
				print FT"$o\t$i\t$per_sim\t$seqat\n";
				last;
			}
			print "$o\t$i\t$per_sim\t$seqat\n";
		}
	}
	return($seqat);
}

sub seqcomp{
    my $o=shift;
    my $i=shift;
    my $o_n=shift;
    my $i_n=shift;
	my $length;
	my $lnoeg;
	my @tnote;
	my @t;
	my $length;
	my $per_sim;
	my $other_start;
	my $other_end;
	open(F1,">file1");
	open(F2,">file2");
	print F1">$o_n\n$o\n";
	print F2">$i_n\n$i\n";
	print "Aligning seq $o_n and seq $i_n with ";
	system("est2genome file1 file2 -outfile=file3");
	open(FN,"file3");
	while(my $line=<FN>){
		chomp $line;
		$lnoeg++;
		if(($lnoeg==1) and ($line=~/^Note/)){
			@tnote=split(/\s+/,$line);
		}
		if($line=~/^Span/){
			@t=split(/\s+/,$line);
			$length=@t[7]-@t[6]+1;
			$per_sim=@t[2]+0;
			$other_start=@t[3]+0;
			$other_end=@t[4]+0;
		}
	}
	close FN;
	close F1;
	close F2;
	return($per_sim,$length,$other_start,$other_end,@tnote[5]);
}


sub get_main_source{
    my $gb_file=shift;
    my $seqio_object = Bio::SeqIO->new(-file => $gb_file, '-format' => 'GenBank');
    my $seq_object = $seqio_object->next_seq;
    for my $feat_object ($seq_object->get_SeqFeatures) {
		if ($feat_object->primary_tag eq "CDS") { 
		#if ($feat_object->primary_tag eq "gene") { 
			my $start = $feat_object->location->start;       
			my $end = $feat_object->location->end;
			my $strand = $feat_object->location->strand;$strand+=0;
			my $seq = $feat_object->spliced_seq->seq;
			my $sequence_string = $feat_object->entire_seq->seq;
			my $seq_utr;my $seq_tag;my $seq_dutr;
			my $l_seq_complete=length($sequence_string);
			my $l_seq=length($seq);
			my $seq_name;
			my $al_utr;
			my $al_dutr;
			my @product_name=$feat_object->get_tag_values('product');
			if(@product_name[0]=~/hypothetical/){
			    next;
			}
			    for my $tag ($feat_object->get_all_tags) {
					if(($tag eq "translation") or ($tag eq "codon_start")){
						next;
					}
					else{
						for my $value ($feat_object->get_tag_values($tag)){
						$seq_name.="$value ";
						}
					}
			    }       
			if(($strand == -1) && (($end+$l_utr)<$l_seq_complete) && (($start-$l_dutr)>0)){
				$n_gene++;
				$select_rutr_no++;
			    print "R->$n_gene\t$start-$end-$l_seq_complete-$l_utr-$l_dutr [$strand]\t";
			    $seq_utr = substr($sequence_string,$end,$l_utr);
			    $seq_utr=reverse($seq_utr);
			    $seq_utr=~tr/ATGC/TACG/d;
			    $seq_dutr = substr($sequence_string,($start-$l_dutr-1),$l_dutr);
			    $seq_dutr=reverse($seq_dutr);
			    $seq_dutr=~tr/ATGC/TACG/d;
			    $al_utr=length($seq_utr);
			    $al_dutr=length($seq_dutr);
				$seq_name.="$start-$end($l_seq) $strand UTR ($al_dutr-$al_utr)";
				$seq_name="$gb_file ($select_utr_no-$n_gene)".$seq_name;
				$h_seq_name{$n_gene}=$seq_name;
				$h_seq{$n_gene}=$seq;
				$h_seq_utr{$n_gene}=$seq_utr;
				$h_seq_dutr{$n_gene}=$seq_dutr;
			}
			elsif(($strand == 1) && (($start-$l_utr)>0) && (($end+$l_dutr)<$l_seq_complete)){
				$n_gene++;
				$select_utr_no++;
			    print "F->$n_gene\t$start-$end-$l_seq_complete-$l_utr-$l_dutr [$strand]\t";
			    $seq_utr = substr($sequence_string,($start-$l_utr-1),$l_utr);
			    $al_utr=length($seq_utr);
			    $seq_dutr = substr($sequence_string,$end,$l_dutr);
			    $al_dutr=length($seq_dutr);
				$seq_name.="$start-$end($l_seq) $strand UTR ($al_utr-$al_dutr)";
				$seq_name="$gb_file ($select_utr_no-$n_gene)".$seq_name;
				$h_seq_name{$n_gene}=$seq_name;
				$h_seq{$n_gene}=$seq;
				$h_seq_utr{$n_gene}=$seq_utr;
				$h_seq_dutr{$n_gene}=$seq_dutr;
			}
			if($n_gene >= $n_gene_threshold){
			    print "\n";
				return($gb_file);
			}
		}
	}
    print "\n";
}

sub get_other_source{
    my $foofile=shift;
    my $foofileno=shift;
    my $seqio_object = Bio::SeqIO->new(-file => $foofile, '-format' => 'GenBank');
    my $seq_object = $seqio_object->next_seq;
    for my $feat_object ($seq_object->get_SeqFeatures) {
		if ($feat_object->primary_tag eq "source") { 
			my $start = $feat_object->location->start;       
			my $end = $feat_object->location->end;
			my $sequence = $feat_object->entire_seq->seq;
			my $length_sequence=length($sequence);
			my $seq_name;
			    for my $tag ($feat_object->get_all_tags) {
				    for my $value ($feat_object->get_tag_values($tag)){
					$seq_name.="$value ";
					}
			    }       
			$n_other_source++;
			$seq_name.="$start-$end($length_sequence)";
			$seq_name="$foofile ($n_other_source)".$seq_name;
			$other_source_sequence_name{$n_other_source}=$seq_name;
			$other_source_sequence{$n_other_source}=$sequence;
			if($n_other_source >= $n_other_source_threshold){
			    print "\n";
				return($foofile);
			}
		}
    }
    print "\n";
}



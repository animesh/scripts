#!/usr/bin/perl
#wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.gbff.gz
#gunzip GCF_000001405.40_GRCh38.p14_genomic.gbff.gz
#perl  gbkcds2fas.pl GCF_000001405.40_GRCh38.p14_genomic.gbff
#https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?tool=portal&save=file&log$=seqview&db=nuccore&report=gbwithparts&id=568815586&withparts=on
#https://www.ncbi.nlm.nih.gov/nuccore/NC_000012.12?report=gbwithparts
#https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_assembly_report.txt
#https://www.ncbi.nlm.nih.gov/nuccore/NT_187685.1?report=gbwithparts&log$=seqview&save=file
#https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?tool=portal&save=file&log$=seqview&db=nuccore&report=gbwithparts&id=568815556&withparts=on
#https://www.ncbi.nlm.nih.gov/books/NBK179288/
#sh -c "$(wget -q ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh -O -)"
#/home/ash022/edirect/efetch -db nuccore -id NC_000012.12 -format gbwithparts > ts12
#awk '{print $7}' GCF_000001405.40_GRCh38.p14_assembly_report.txt  | grep "^NC" > codon_list
#https://www.ncbi.nlm.nih.gov/account/settings/?smsg=create_apikey_success
#cat codon_list | "parallel -j 25 ncbi-acc-download --api-key fe9645dec {}
#ls NC*gbk | parallel -j 25 perl ../../Desktop/Scripts/gbkcds2fas.pl  {}
#cat NC*gbk*cds.utr.txt > NC.cds.comb.txt
#https://www.ensembl.org/Homo_sapiens/Transcript/Exons?db=core;g=ENSG00000188573;r=5:168529305-168530634;t=ENST00000338333  GCCATG
use Bio::SeqIO;
use strict;
my $main_file_pattern=shift @ARGV;
chomp $main_file_pattern;
my $l_utr=3;
my $l_dutr=3;
my $sim_thresh;
my $n_gene_threshold=1000000000000000;
my $n_other_source_threshold=1000000000000000;
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
my %h_seq_name
;
my %total_seq;
my %total_seq_utr;
my %total_seq_dutr;
my %total_seq_name;
my %other_source_sequence;
my %other_source_sequence_name;
my @other_file;
my $total_file_name="cds.fas";
my $total_file_name_utr="$main_file_pattern.cds.utr.txt";
my $total_file_name_dutr="cds.dutr.fas";
open(FT,">temp.txt");
open(FTTL,">$total_file_name");
open(FTTLUTR,">$total_file_name_utr");
open(FTTLDUTR,">$total_file_name_dutr");
print FTTLUTR"Number\tName\tPosition\tLength\tSequence\n";
my $file=get_main_source($main_file_pattern);
print "$file\n$main_file_pattern\nTotal Gene, $n_gene out of $n_gene_threshold $file\n";
close(FT);
close(FTTL);
close(FTTLUTR);
close(FTTLDUTR);
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
			$seq_name =~ s/\s+/\;/g;
			print "SN:$seq_name\n";
			#if(($strand == -1) && (($end+$l_utr)<$l_seq_complete) && (($start-$l_dutr)>0)){
			if($strand == -1){
				$n_gene++;
				$select_rutr_no++;
			    print FTTLUTR"R$n_gene\t$seq_name\t$start-$end-$l_seq_complete-$l_utr-$l_dutr [$strand]\t$l_seq\t";
			    $seq_utr = substr($sequence_string,$end-3,$l_utr+3);
			    $seq_utr=reverse($seq_utr);
			    $seq_utr=~tr/ATGC/TACG/d;
			    print FTTLUTR"$seq_utr\n";
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
			#elsif(($strand == 1) && (($start-$l_utr)>0) && (($end+$l_dutr)<$l_seq_complete)){
			else{
				$n_gene++;
				$select_utr_no++;
			    print FTTLUTR"F$n_gene\t$seq_name\t$start-$end-$l_seq_complete-$l_utr-$l_dutr [$strand]\t$l_seq\t";
			    $seq_utr = substr($sequence_string,($start-$l_utr-1),$l_utr+3);
			    print FTTLUTR"$seq_utr\n";
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
		}
	}
			    print "\n";
				return($gb_file);
}
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


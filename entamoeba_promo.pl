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

head	1.20;
access;
symbols;
locks
	krishna_bhakt:1.20; strict;
comment	@# @;


1.20
date	2006.09.10.14.07.27;	author krishna_bhakt;	state Exp;
branches;
next	1.19;

1.19
date	2006.09.10.14.01.04;	author krishna_bhakt;	state Exp;
branches;
next	1.18;

1.18
date	2006.09.06.11.06.43;	author krishna_bhakt;	state Exp;
branches;
next	1.17;

1.17
date	2006.09.06.10.57.50;	author krishna_bhakt;	state Exp;
branches;
next	1.16;

1.16
date	2006.09.06.10.30.49;	author krishna_bhakt;	state Exp;
branches;
next	1.15;

1.15
date	2006.09.05.12.03.22;	author krishna_bhakt;	state Exp;
branches;
next	1.14;

1.14
date	2006.09.05.09.07.03;	author krishna_bhakt;	state Exp;
branches;
next	1.13;

1.13
date	2006.09.05.08.05.58;	author krishna_bhakt;	state Exp;
branches;
next	1.12;

1.12
date	2006.09.04.13.09.57;	author krishna_bhakt;	state Exp;
branches;
next	1.11;

1.11
date	2006.09.04.11.22.37;	author krishna_bhakt;	state Exp;
branches;
next	1.10;

1.10
date	2006.09.04.08.58.53;	author krishna_bhakt;	state Exp;
branches;
next	1.9;

1.9
date	2006.09.03.11.25.37;	author krishna_bhakt;	state Exp;
branches;
next	1.8;

1.8
date	2006.09.03.10.25.12;	author krishna_bhakt;	state Exp;
branches;
next	1.7;

1.7
date	2006.09.03.10.24.04;	author krishna_bhakt;	state Exp;
branches;
next	1.6;

1.6
date	2006.09.03.10.20.15;	author krishna_bhakt;	state Exp;
branches;
next	1.5;

1.5
date	2006.09.03.06.30.28;	author krishna_bhakt;	state Exp;
branches;
next	1.4;

1.4
date	2006.09.01.17.41.32;	author krishna_bhakt;	state Exp;
branches;
next	1.3;

1.3
date	2006.09.01.16.32.14;	author krishna_bhakt;	state Exp;
branches;
next	1.2;

1.2
date	2006.09.01.15.03.01;	author krishna_bhakt;	state Exp;
branches;
next	1.1;

1.1
date	2006.08.31.14.55.48;	author krishna_bhakt;	state Exp;
branches;
next	;


desc
@@


1.20
log
@Correction for D UTR
@
text
@#!/usr/bin/perl
use Bio::SeqIO;
use strict;
my $l_utr=500;
my $l_dutr=500;
my $sim_thresh=90;
my $blast_thresh=90;
my $blast_len_thresh=0.50;
my $gb_file="AAFB01000002.1.gb";
my $l_utr=500;
my $l_dutr=500;
my $sim_thresh=2;
my $blast_thresh=2;
my $blast_len_thresh=0.01;


system("ls -1 > tempfile1");
open(FT1,"tempfile1");
open(FT,">temp.txt");

my $total_seq_cnt_threshold=1500;
my $n_gene_threshold=1200;

my $total_seq_cnt_threshold=2;
my $n_gene_threshold=2;

my $total_seq_cnt;
my $tfl1;
my $date_cnt=time;
#my $total_file_name="total.".$date_cnt.".fas";
#my $total_file_name_utr="total.".$date_cnt."utr.fas";

my $total_file_name="total.fas";
my $total_file_name_utr="total.utr.fas";
my $total_file_name_dutr="total.dutr.fas";
my $foobr="total_blastreport_utr.txt";

open(BLASTREP,">$foobr");

my $n_gene;
my %h_seq_name;
my %h_seq;
my %h_seq_utr;
my %h_seq_dutr;
my %total_seq_name;
my %total_seq;
my %total_seq_utr;
my %total_seq_dutr;




open(FTTL,">$total_file_name");
open(FTTLUTR,">$total_file_name_utr");
my %compfile_seq;
my %compfile_seq_name;
my %compfile_seq_utr;

my $other_file1="DIS.reads";
my $other_file2="INV.reads";
my $other_file3="MOSH.reads";
my $other_file4="TERRA.reads";
my $other_file5="TERRA.2.reads";

my @@other_file=($other_file1, $other_file2, $other_file3, $other_file4, $other_file5);

while($tfl1=<FT1>){
    chomp $tfl1;
    if($tfl1=~/asn1$/){
	my @@temp=split(/\./,$tfl1);
	my $foo=@@temp[0].".gb";
	system("asn2gb.Win32 -i $tfl1 -o $foo -f b");
	select_utr($foo);
	#print "$tfl1\n";
    }
}
close FT1;
close FTTL;
close FT;

system("rm -rf tempfile1");


#select_utr($gb_file);


#seq_pic_other($other_file1);


sub select_utr{

    my $gb_file=shift;
    my $seqio_object = Bio::SeqIO->new(-file => $gb_file, '-format' => 'GenBank');
    my $seq_object = $seqio_object->next_seq;
    my $select_utr_no;
    print "$gb_file\n";
#eval { my $seq_object = $seqio_object->next_seq; };       
      # if there's an error       
#print "Problem in $gb_file. Bad feature perhaps?\n" if $@@;
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
			my @@product_name=$feat_object->get_tag_values('product');
			if(@@product_name[0]=~/hypothetical/){
			    #print $feat_object->get_tag_values('product');
			    #print "\t";
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
			#print $feat_object->spliced_seq->seq,"\n";
#			$n_gene++;
#			$select_utr_no++;
			if(($strand == -1) && (($end+$l_utr)<$l_seq_complete) && (($start-$l_dutr)>0)){
			$n_gene++;
			$select_utr_no++;
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
			if($n_gene > $n_gene_threshold){
			    print "\nTotal Gene, $n_gene, is > then $n_gene_threshold\n";
			    select_utr_threshold($gb_file);
			    die;
			}
		    }
}
    print "\n";
}




sub select_utr_threshold{
my $gb_file=shift;
my @@t=split(/\./,$gb_file);
my $gb_file_out=@@t[0].".utr.txt";
#open(FW,">$gb_file_out");
  foreach my $o (sort {$a <=> $b} keys %h_seq_name) { my $per_sim; my $max;my $max_seq_name;
    foreach my $i (sort {$a <=> $b} keys %h_seq_name){
	if($i<$o){
	    open(F1,">file1");
	    open(F2,">file2");
	    print F1">$h_seq_name{$i}\n$h_seq{$i}\n";
	    print F2">$h_seq_name{$o}\n$h_seq{$o}\n";
	    print "Aligning seq $o and seq $i with ";
	    system("needle file1 file2 -gapopen=10 -gapext=0.5 -outfile=file3");
	    open(FN,"file3");
	    while(my $line=<FN>){
		if($line=~/^# Identity:     /){
		   @@t=split(/\(|\)/,$line);
		   @@t[1]=~s/\%|\s+//g;
		   $per_sim=@@t[1]+0;
		   if($max<$per_sim){
		       $max=$per_sim;
		       $max_seq_name=$i;
		   }
		   print FT"$i-$o\t$per_sim\n";
		}
	    }
	    close FN;
	    close F1;
	    close F2;
	}
	#print "\n";
	if($max>$sim_thresh){last;}
    }
    print FT"\n$o - $max_seq_name - $max - $per_sim - $sim_thresh\n";
    if(($total_seq_cnt >= $total_seq_cnt_threshold)){
	my $other_seq_no;
	foreach (@@other_file){
	    $other_seq_no++;
	    seq_pic_other($_,$other_seq_no);
	}
	die"Total UTR Seq Count, $total_seq_cnt, reached $total_seq_cnt_threshold\n"; 
    }
    if(($max<$sim_thresh)){
	print FT"\t$o-$max_seq_name-$max-$per_sim\n";
	$total_seq_cnt++;
	print FTTLUTR">$h_seq_name{$o}\n$h_seq_utr{$o}\n";
	print FTTL">$h_seq_name{$o}\n$h_seq{$o}\n";
	$total_seq_name{$total_seq_cnt}=$h_seq_name{$o};
	$total_seq_utr{$total_seq_cnt}=$h_seq_utr{$o};
	$total_seq{$total_seq_cnt}=$h_seq{$o};
	next;
    }
  }
    #close FW;
    #close FT;

}
#my @@cds_features = grep { $_->primary_tag eq 'CDS' } Bio::SeqIO->new(-file => $gb_file)->next_seq->get_SeqFeatures;
#my %gene_sequences = map {$_->get_tag_values('gene'), $_->spliced_seq->seq } @@cds_features;


sub seq_pic_other{
    undef %compfile_seq;
    undef %compfile_seq_name;
    undef %compfile_seq_utr;

    my $foofile=shift;
    my $foonumber=shift;
    print "$foofile File Number $foonumber\n";
    my $f2=$foofile.".seqpic.txt";
    my $seqno;
    open(E,">$f2")||die "can't open $f2";
    my $input_seqs = Bio::SeqIO->new ( '-format' => 'Fasta' , 
				       '-file'   => $foofile );
    
    while ( my $s = $input_seqs->next_seq() ) {
	$seqno++;
	my $comp_file_seqname=$s->display_id();
	$comp_file_seqname.=" ";
	$comp_file_seqname.=$s->desc();
	print E"$comp_file_seqname\n";
	my $comp_file_seq=$s->seq();
	$compfile_seq{$seqno}=$comp_file_seq;
	$compfile_seq_name{$seqno}=$comp_file_seqname;
   }
    other_seq_comp($foofile,$foonumber);
}

sub other_seq_comp{
    my $foofile=shift;
    my $foonumber=shift;
    print "$foofile File Number $foonumber\n";
    my $foonw=$foofile."_".$foonumber."_total_other_utr_nw.txt";
    my $foosw=$foofile."_".$foonumber."_total_other_utr_sw.txt";
    my $fooms=$foofile."_".$foonumber."_total_other_utr_ms.txt";
    my $foobs=$foofile."_".$foonumber."_total_other_utr_bs.txt";


open(FWOUTRN,">$foonw");
open(FWOUTRS,">$foosw");
open(FWOUTRM,">$fooms");
open(FWOUTRB,">$foobs");



foreach my $o (sort {$a <=> $b} keys %total_seq) {
   foreach my $i (sort {$a <=> $b} keys %compfile_seq){
       if($i==$o){
       #if($compfile_seq_name{$i} =~ /dispar102e08/){
       true_string_match($o,$i);
       water_string_match($o,$i);
       needle_string_match($o,$i);
       blast2seq($o,$i,$foofile);
       #}
       }
    }
}
close FWOUTRN;
close FWOUTRM;
close FWOUTRB;
close FWOUTRS;

}


sub true_string_match{
    my $o=shift;
    my $i=shift;
	    my $seq_o=$total_seq{$o};
	    my $seq_i=$compfile_seq{$i};
    $seq_i=~s/\-/N/g;
    $seq_o=~s/\-/N/g;

    my $seq_o_name=$total_seq_name{$o};
    my $seq_i_name=$compfile_seq_name{$i};
    my $seq_o_length=length($total_seq{$o});
    my $seq_i_length=length($compfile_seq{$i});

	    print "Aligning seq $o and seq $i with String Match\n";
	    #print FWOUTR"$total_seq_name{$o}\n$compfile_seq_name{$i}\n$seq_i\n$seq_o\n";
	    my $start_motif=$l_utr;
	    my $length_motif=$l_utr;
	    while ($seq_i =~ /$seq_o/g) {
            #while ($seq_i =~ /$seq_i/g) {
		my $posi= ((pos $seq_i) - length($&) +1);
		my $start_posi=$posi-$start_motif-1;
		my $moti = substr($seq_i,$start_posi,$length_motif);
		my $len=length($moti);
		(pos $seq_i)=(pos $seq_i)-length($&) +1;
		#if($start_posi>=0){
		    print FWOUTRM">$o-$i $seq_o_name\t$seq_i_name\t$posi$seq_o_length\t$seq_o_length\n";
		#}
	    }
	}

sub water_string_match{
    my $o=shift;
    my $i=shift;
    my $max_seq_name;
    my $max=90;
    my $seq_o=$total_seq{$o};
    my $seq_i=$compfile_seq{$i};
    $seq_i=~s/\-/N/g;
    $seq_o=~s/\-/N/g;
    my $seq_o_name=$total_seq_name{$o};
    my $seq_i_name=$compfile_seq_name{$i};
    my $seq_o_length=length($total_seq{$o});
    my $seq_i_length=length($compfile_seq{$i});
    
	    open(F1,">file1");
	    open(F2,">file2");
	    print F1">$seq_o_name\n$seq_o\n";
	    print F2">$seq_i_name\n$seq_i\n";
	    print "Aligning seq $o and seq $i with ";
	    system("water file1 file2 -gapopen=10 -gapext=0.5 -outfile=file3");
	    open(FN,"file3");
	    my $length;
            while(my $line=<FN>){
		if($line=~/^# Length: /){chomp $line;my @@t=split(/\:/,$line);$length=@@t[1];}
		if($line=~/^# Identity:     /){
		   my @@t=split(/\(|\)/,$line);
		   @@t[1]=~s/\%|\s+//g;
		   my $per_sim=@@t[1]+0;
		   #if($max<$per_sim){
		       $max=$per_sim;
		       $max_seq_name=$i;
		   print FWOUTRS"$o-$i $seq_o_name\t$seq_i_name\t$per_sim\t$seq_o_length\t$seq_i_length\t$length\n";
		   #}

		}
   }
	    close FN;
	    close F1;
	    close F2;

}

sub needle_string_match{
    my $o=shift;
    my $i=shift;
    my $max_seq_name;
    my $max=90;
    my $seq_o=$total_seq{$o};
    my $seq_i=$compfile_seq{$i};
    $seq_i=~s/\-/N/g;
    $seq_o=~s/\-/N/g;
    my $seq_o_name=$total_seq_name{$o};
    my $seq_i_name=$compfile_seq_name{$i};
    my $seq_o_length=length($total_seq{$o});
    my $seq_i_length=length($compfile_seq{$i});

	    open(F1,">file1");
	    open(F2,">file2");
	    print F1">$seq_o_name\n$seq_o\n";
	    print F2">$seq_i_name\n$seq_i\n";
	    print "Aligning seq $o and seq $i with ";
	    system("needle file1 file2 -gapopen=10 -gapext=0.5 -outfile=file3");
	    open(FN,"file3");
            my $length;
	    while(my $line=<FN>){
		if($line=~/^# Length: /){chomp $line;my @@t=split(/\:/,$line);$length=@@t[1];}
		if($line=~/^# Identity:     /){
		   my @@t=split(/\(|\)/,$line);
		   @@t[1]=~s/\%|\s+//g;
		   my $per_sim=@@t[1]+0;
		   #if($max<$per_sim){
		       $max=$per_sim;
		       $max_seq_name=$i;
		   print FWOUTRN"$o-$i $seq_o_name\t$seq_i_name\t$per_sim\t$seq_o_length\t$seq_i_length\t$length\n";
		   #}

		}
	    }
	    close FN;
	    close F1;
	    close F2;
    #return($max,$max_seq_name);

}



sub blast2seq{
use Bio::Tools::Run::StandAloneBlast;
my $factory = Bio::Tools::Run::StandAloneBlast->new(p => 'blastn',
                                                    e => '1');
    my $o=shift;
    my $i=shift;
    my $blast_file_name=shift;
    my $max_seq_name;
    my $max=0;
    my $seq_o=$total_seq{$o};
    my $seq_o_utr=$total_seq_utr{$o};
    my $seq_i=$compfile_seq{$i};
    $seq_i=~s/\-/N/g;
    $seq_o=~s/\-/N/g;
    my $seq_o_name=$total_seq_name{$o};
    my $seq_i_name=$compfile_seq_name{$i};
    my $seq_o_length=length($total_seq{$o});
    my $seq_i_length=length($compfile_seq{$i});
    
	    print "Aligning seq $o and seq $i with Blast2Seq\n";
	    open(F1,">file1");
	    open(F2,">file2");
	    print F1">$seq_o_name\n$seq_o\n";
	    print F2">$seq_i_name\n$seq_i\n";

my $report = $factory->bl2seq('file1','file2'); # get back a Bio::SearchIO report
my $result = $report->next_result;
print FWOUTRB"$o-$i $seq_o_name\t$seq_i_name\t";		       
while( my $hit = $result->next_hit()) {    
    print FWOUTRB"\thit name: ", $hit->name(), "\t\t";    
    while( my $hsp = $hit->next_hsp()) { 	
	print FWOUTRB"E: ", $hsp->evalue(), "  frac_identical: ",	$hsp->frac_identical(), "\t";
	print FWOUTRB join("\t",
           "Bits", $hsp->bits,
           "Length", $hsp->length,
           "Sub start", $hsp->sbjct->start,
           "Sub end", $hsp->sbjct->end,
	   "Query start" , $hsp->query->start(), 
	   "Query end",$hsp->query->end(),
	   "Score", $hsp->score), "\t";
	if((($hsp->length)>=($seq_i_length*($blast_len_thresh))) and (($hsp->score)>=$blast_thresh)){
	    print BLASTREP ">$seq_o_name\t\t$seq_o_name\t\tScore:",$hsp->score,"\t\tLength:",$hsp->length,"\t\t$blast_file_name\n$seq_o_utr\n$seq_i\n" ;
	}
    
    }
}
print FWOUTRB"$seq_o_length\t$seq_i_length\n";		       
	    close FN;
	    close F1;
	    close F2;


}
@


1.19
log
@Correcting Sequence numbering and adding D UTR
@
text
@d5 1
d9 6
a14 5
#my $gb_file="AAFB01000002.1.gb";
#my $l_utr=500;
#my $sim_thresh=2;
#my $blast_thresh=2;
#my $blast_len_thresh=0.01;
d24 2
a25 2
#my $total_seq_cnt_threshold=2;
#my $n_gene_threshold=2;
d32 1
d35 1
d37 1
d40 1
a40 1
my $n_gene=0;
d44 1
d48 1
a48 1

d288 1
a288 1
       #if($i==$o){
d295 1
a295 1
       #}
@


1.18
log
@*** empty log message ***
@
text
@d9 6
d21 4
d83 1
d102 1
a102 1
			my $seq_utr;my $seq_tag;
d107 1
d125 3
d130 1
a130 2
			if(($strand == -1) && (($end+$l_utr)<$l_seq_complete)){
			    print "R->$n_gene\t";
d134 3
d138 7
d146 4
a149 2
			elsif(($strand == 1) && (($start-$l_utr)>0) ){
			    print "F->$n_gene\t";
d152 3
a154 2
			}
			$seq_name.="$start-$end($l_seq) $strand UTR($al_utr)";
d159 2
d173 1
@


1.17
log
@Blast reporting
@
text
@d6 2
a7 1
my $blast_thresh=9;
d13 2
a14 1
my $total_seq_cnt_threshold=2;
d34 1
a34 1
my $n_gene_threshold=2;
d252 1
a252 1
       if($i==$o){
d259 1
a259 1
       }
d427 1
a427 1
	if((($hsp->length)>=($seq_i_length*(1/100))) and (($hsp->score)>=$blast_thresh)){
@


1.16
log
@Version 2
@
text
@d6 1
d20 3
d240 1
d246 2
d255 1
a255 1
       blast2seq($o,$i);
d391 1
d395 1
d425 3
@


1.15
log
@Blast format
@
text
@d322 1
a322 1
		   print FWOUTRN"$o-$i $seq_o_name\t$seq_i_name\t$per_sim\t$seq_o_length\t$seq_i_length\t$length\n";
@


1.14
log
@needle
@
text
@d35 2
d38 6
d174 5
a178 1
	seq_pic_other($other_file1,1);
d201 4
d224 1
a224 1
    other_seq_comp();
d228 13
a240 1
open(FWOUTR,">total_other_utr.txt");
d243 5
a247 4
	#if($i==$o){
       #true_string_match($o,$i);
       if($compfile_seq_name{$i} =~ /dispar102e08/){
       #water_string_match($o,$i);
d249 1
a250 1
	#}
d253 5
d266 9
a274 1
	    print "Aligning seq $o and seq $i\n";
d279 1
d285 3
a287 3
		if($start_posi>=0){
		    print FWOUTR">$total_seq_name{$o}\n$compfile_seq_name{$i}\tPos in Seq $seq_i- $posi - $start_posi ($length_motif)\t$moti\n";
		}
d302 2
a304 1
	    print "Aligning seq $o and seq $i\n";
d312 3
a314 1
	    while(my $line=<FN>){
d319 1
a319 1
		   if($max<$per_sim){
d322 2
a323 2
		   print FWOUTR"$o-$i $seq_o_name\t$seq_i_name\t$per_sim\n";		       
		   }
d326 1
a326 1
	    }
d344 3
a346 2
    
	    print "Aligning seq $o and seq $i\n";
d354 1
d356 1
d361 1
a361 1
		   if($max<$per_sim){
d364 2
a365 2
		   print FWOUTR"$o-$i $seq_o_name\t$seq_i_name\t$per_sim\n";		       
		   }
d392 2
d403 1
d405 15
a419 4
  print "\thit name: ", $hit->name(), "\n";    
  while( my $hsp = $hit->next_hsp()) { 	
    print "E: ", $hsp->evalue(), "  frac_identical: ",	$hsp->frac_identical(), "\n";    }}

@


1.13
log
@Blast2seq
@
text
@d287 42
@


1.12
log
@water alignment
@
text
@d217 4
a220 3
       #if($compfile_seq_name{$i} =~ /dispar102e08/){
       water_string_match($o,$i);
       #}
d253 2
a254 2
	    my $seq_o=$total_seq{$o};
	    my $seq_i=$compfile_seq{$i};
d257 2
a258 2
	    my $seq_o_name=$total_seq_name{$o};
	    my $seq_i_name=$compfile_seq_name{$i};
d286 35
@


1.11
log
@With Dispar
@
text
@a199 5
	#print E "sequence name is ", $s->display_id, "\t";
	#print E "sequence desc is ", $s->desc, "\t";
	#print E"sequence length is ", $s->length(), "\n";
	#my $r = $s->revcom();
	#print E"rev. complement is ", $r->seq(), "\n", $s->seq(), "\n";
a211 2
my $js=$l_utr;
my $je=$l_utr;
d216 15
a230 2
	    my $seq_i=$total_seq{$o};
	    my $seq_o=$compfile_seq{$i};
d233 4
a236 4
	    my $start_motif=10;
	    my $length_motif=10;
	    while ($seq_o =~ /$seq_i/g) {
		my $posi= ((pos $seq_o) - length($&) +1);
d238 1
a238 1
		my $moti = substr($seq_o,$start_posi,$length_motif);
d240 4
a243 2
		(pos $seq_o)=(pos $seq_o)-length($&) +1;
		print FWOUTR">$total_seq_name{$o}\n$compfile_seq_name{$i}\tPos in Seq $seq_o- $posi - $start_posi ($length_motif)\t$moti\n";
d245 32
a276 4
	#}
    }
}
}
d278 5
a282 65
#open(F2,"ecol_K12_MG1655genome.gbk")||die "can't open F";
#$je=301;$js=110;$sigma="Sigma70";
#while ($l=<F2>){	
#	if($l=~/^ORIGIN/){
#		while($ll=<F2>)
#                {
#		    $ll=~s/[0-9]//g;$ll=~s/\s+//g;chomp $ll;$ll=~s/\/\///g;$line.=$ll;
#                }
#        }
#}
#close F2;
#$line=uc($line);
#$rline=reverse ($line);
#$rline =~ tr/ATCG/TAGC/d;$lgo=length($rline);
##print ">forward\t$f\n$line\n";
##print ">reverse\t$f\n$rline\n";
#while($lin=<F>){
# chomp $lin;
# if($lin=~/^ECK/){
# @@t1=split(/\t/,$lin);
# #foreach  (@@t1) {print "$c\t $_ \n";$c++;}#print "@@t1[5]\n";
# $pos=@@t1[2];$str=uc(@@t1[5]);$str=~s/\s+//g;
#	 if(($pos eq "reverse") and (@@t1[4] eq $sigma)){ 
#		 $ccc++;
#  		 $ci= $rline =~ s/$str/$str/g; #print E">$ci\t@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\t$str\n$line\n";
#		 if($ci!=1){print ">$ccc\t$ci\t@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\t$str\n";}$ci=0;
#		 while ($rline =~ /$str/g) {
#			$posi= ((pos $rline) - length($&) +1);
#			$moti = substr($rline,($posi-$js),$je);$len=length($moti);
#			(pos $line)=(pos $rline)-length($&) +1;
#			$postss=$lgo-$posi-60+1;$sp=$postss-$js+60-1+1+$len-1-81;$st=$sp-$je+1;
#			print E">@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\tPos in GenSeq-$postss\tLen-$len [$sp-$st]\n$moti\n";
#		}

#	 }
#	 elsif(($pos eq "forward") and (@@t1[4] eq $sigma)) {
#		$ccc++;
#		$ci= $line =~ s/$str/$str/g; #print E">$ci\t@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\t$str\n$line\n";
#		if($ci!=1){print ">$ccc\t$ci\t@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\t$str\n";}$ci=0;
#		if($ccc==592){
#					while ($line =~ /$str/g) {
#						$posi= (pos $line) - length($&) +1;
#						$part1=(substr($line,($lgo-($js-$posi)-1),($js-$posi)));$strl=$je-($js-$posi);
#						$part2=(substr($line,0,$strl));
#						$moti = $part1.$part2;
#						$len=length($moti);
#						(pos $line)=(pos $line)-length($&) +1;
#						$postss=$posi+60;$st=($lgo-($js-$pos));$sp=($posi+length($str)+110);
#						#print E">@@t1[0]\t$ccc\t$posi\t($lgo-($js-$posi)-1)\t$js-$posi+1\t$strl\n";
#						print E">@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\tPos in GenSeq-$postss\tLen-$len [$st-$sp]\n$moti\n";
#					}

#			next;
#		}
#		while ($line =~ /$str/g) {
#			$posi= (pos $line) - length($&) +1;
#			$moti = substr($line,($posi-$js),$je);$len=length($moti);
#			(pos $line)=(pos $line)-length($&) +1;
#			$postss=$posi+60;$st=$postss-$js-60+1;$sp=$st+$len-1;
#			print E">@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\tPos in GenSeq-$postss\tLen-$len [$st-$sp]\n$moti\n";
#		}
#	 }
#	 #else{print "$ccc\t$lin\n";}
# }
#}
d284 1
a284 1
#close F;close E;
@


1.10
log
@other_seq_comp
@
text
@d166 1
a166 1
	seq_pic_other($total_file_name_utr,1);
d222 3
a224 3
	if($i==$o){
	    my $rline=$total_seq_utr{$o};
	    my $str=$compfile_seq{$i};
d226 7
a232 4
	    print FWOUTR"$total_seq_name{$o}\n$compfile_seq_name{$i}\n$rline\n$str\n";
	    while ($rline =~ /$str/g) {
		my $posi= ((pos $rline) - length($&) +1);
		my $moti = substr($rline,($posi-$js),$je);
d234 2
a235 6
		(pos $rline)=(pos $rline)-length($&) +1;
		my $postss=$posi-60+1;
		my $sp=$postss-$js+60-1+1+$len-1-81;
		my $st=$sp-$je+1;
		#print FWOUTR">@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\tPos in GenSeq-$postss\tLen-$len [$sp-$st]\n$moti\n";
		print FWOUTR">Pos in GenSeq- $posi - $len\t$postss\tLen-$len [$sp-$st]\n$moti\n";
d237 1
a237 1
	}
@


1.9
log
@1500
@
text
@d11 1
a11 1
my $total_seq_cnt_threshold=1500;
d16 1
d28 1
a28 2

my $n_gene_threshold=1500;
d33 3
a35 1

d55 3
a57 1
#seq_pic_other($total_file_name);
d166 1
d172 2
a173 2
	print FTTL">$h_seq_name{$o}\n$h_seq_utr{$o}\n";
	print FTTLUTR">$h_seq_name{$o}\n$h_seq{$o}\n";
d189 5
a193 5


    my $f1=shift @@ARGV;
    my $f2=$f1.".seqpic.txt";

a194 1

d196 2
a197 3
                                '-file'   => $f1
                              );

d199 13
a211 4
	print( "sequence is ", $s->seq(), "\n" );
	print( "sequence length is ", $s->length(), "\n" );
	my $r = $s->revcom();
	print( "rev. complement is ", $r->seq(), "\n" );
d213 2
d216 26
a241 1

a309 3


}
@


1.8
log
@Run
@
text
@d17 1
d32 2
d48 1
d168 1
@


1.7
log
@test
@
text
@d4 1
a4 1
my $l_utr=100;
d11 1
a11 1
my $total_seq_cnt_threshold=10;
d27 1
a27 1
my $n_gene_threshold=15;
@


1.6
log
@Histolytica for 1000 generation
@
text
@d199 33
a231 33
open(F2,"ecol_K12_MG1655genome.gbk")||die "can't open F";
$je=301;$js=110;$sigma="Sigma70";
while ($l=<F2>){	
	if($l=~/^ORIGIN/){
		while($ll=<F2>)
                {
		    $ll=~s/[0-9]//g;$ll=~s/\s+//g;chomp $ll;$ll=~s/\/\///g;$line.=$ll;
                }
        }
}
close F2;
$line=uc($line);
$rline=reverse ($line);
$rline =~ tr/ATCG/TAGC/d;$lgo=length($rline);
#print ">forward\t$f\n$line\n";
#print ">reverse\t$f\n$rline\n";
while($lin=<F>){
 chomp $lin;
 if($lin=~/^ECK/){
 @@t1=split(/\t/,$lin);
 #foreach  (@@t1) {print "$c\t $_ \n";$c++;}#print "@@t1[5]\n";
 $pos=@@t1[2];$str=uc(@@t1[5]);$str=~s/\s+//g;
	 if(($pos eq "reverse") and (@@t1[4] eq $sigma)){ 
		 $ccc++;
  		 $ci= $rline =~ s/$str/$str/g; #print E">$ci\t@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\t$str\n$line\n";
		 if($ci!=1){print ">$ccc\t$ci\t@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\t$str\n";}$ci=0;
		 while ($rline =~ /$str/g) {
			$posi= ((pos $rline) - length($&) +1);
			$moti = substr($rline,($posi-$js),$je);$len=length($moti);
			(pos $line)=(pos $rline)-length($&) +1;
			$postss=$lgo-$posi-60+1;$sp=$postss-$js+60-1+1+$len-1-81;$st=$sp-$je+1;
			print E">@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\tPos in GenSeq-$postss\tLen-$len [$sp-$st]\n$moti\n";
		}
d233 17
a249 17
	 }
	 elsif(($pos eq "forward") and (@@t1[4] eq $sigma)) {
		$ccc++;
		$ci= $line =~ s/$str/$str/g; #print E">$ci\t@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\t$str\n$line\n";
		if($ci!=1){print ">$ccc\t$ci\t@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\t$str\n";}$ci=0;
		if($ccc==592){
					while ($line =~ /$str/g) {
						$posi= (pos $line) - length($&) +1;
						$part1=(substr($line,($lgo-($js-$posi)-1),($js-$posi)));$strl=$je-($js-$posi);
						$part2=(substr($line,0,$strl));
						$moti = $part1.$part2;
						$len=length($moti);
						(pos $line)=(pos $line)-length($&) +1;
						$postss=$posi+60;$st=($lgo-($js-$pos));$sp=($posi+length($str)+110);
						#print E">@@t1[0]\t$ccc\t$posi\t($lgo-($js-$posi)-1)\t$js-$posi+1\t$strl\n";
						print E">@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\tPos in GenSeq-$postss\tLen-$len [$st-$sp]\n$moti\n";
					}
d251 13
a263 13
			next;
		}
		while ($line =~ /$str/g) {
			$posi= (pos $line) - length($&) +1;
			$moti = substr($line,($posi-$js),$je);$len=length($moti);
			(pos $line)=(pos $line)-length($&) +1;
			$postss=$posi+60;$st=$postss-$js-60+1;$sp=$st+$len-1;
			print E">@@t1[0]\t$ccc\t@@t1[1]\t@@t1[2]\t@@t1[3]\t@@t1[4]\tPos in GenSeq-$postss\tLen-$len [$st-$sp]\n$moti\n";
		}
	 }
	 #else{print "$ccc\t$lin\n";}
 }
}
d265 1
a265 1
close F;close E;
@


1.5
log
@Seq Pic Module and Hashed Sequence
@
text
@d49 1
d163 1
a163 1
	print FTTL">$h_seq_name{$o}\n$h_seq_utr{$o}\n$h_seq{$o}\n";
d179 19
a197 4
$f1 = shift 
$f2=$f1.".seqpic.txt";
open(F,$f1)||die "can't open $f1";
open(E,">$f2")||die "can't open $f2";
@


1.4
log
@threshold both
@
text
@d21 6
d29 1
d163 3
d176 77
@


1.3
log
@Multi seq file
@
text
@d4 1
a4 1
my $l_utr=500;
d11 1
a11 1
my $total_seq_cnt_threshold=5;
d15 7
a21 1
my $total_file_name="total.".$date_cnt.".fas";
d24 1
d44 1
d48 2
d53 3
a55 7
my $n_gene=0;
my %h_seq_name;
my %h_seq;
my %h_seq_utr;
for my $feat_object ($seq_object->get_SeqFeatures) {
    if ($feat_object->primary_tag eq "CDS") { 
    #if ($feat_object->primary_tag eq "gene") { 
d84 1
d98 1
d102 6
a107 1
         }
d109 7
a115 1
print "\n";
d119 1
a119 3

foreach my $o (sort {$a <=> $b} keys %h_seq_name) {
    my $per_sim; my $max;my $max_seq_name;
d145 2
a146 3
	if($max>$sim_thresh){
	    last;
	}
d150 1
a150 1
	die"Total Seq Count, $total_seq_cnt, reached $total_seq_cnt_threshold\n"; 
d153 1
a153 1
	print FT"\t$o-$max_seq_name-$max-$per_sim\t$gb_file\n";
d155 1
a155 2
	print FTTL">$gb_file ($o-$total_seq_cnt) $h_seq_name{$o}\n$h_seq_utr{$o}\n";
	#print FW">$o($gb_file)$h_seq_name{$o}\n$h_seq_utr{$o}\n";
d158 1
a158 2
    
}
d161 1
a162 2


@


1.2
log
@Threshold 38, subroutined, genbank file
@
text
@d4 31
a34 4
my $l_utr=100;
my $sim_thresh=38;
my $gb_file="AAFB01000002.1.gb";
select_utr($gb_file);
d62 2
a63 2
			    print $feat_object->get_tag_values('product');
			    print "\t@@product_name[0]\n";
d67 1
a67 1
				if(($tag eq "translation")){
d72 1
a72 2
					#if($value =~ /hypothetical/){print "$tag\t$value\tHello\n";}
					$seq_name.="$tag:$value\t";
a83 4
			    $seq_name.="S-$start E-$end L-$l_seq D-$strand\tUTR\tL-$al_utr";
			    $h_seq_name{$n_gene}=$seq_name;
			    $h_seq{$n_gene}=$seq;
			    $h_seq_utr{$n_gene}=$seq_utr;
a88 4
			    $seq_name.="S-$start E-$end L-$l_seq D-$strand\tUTR\tL-$al_utr";
			    $h_seq_name{$n_gene}=$seq_name;
			    $h_seq{$n_gene}=$seq;
			    $h_seq_utr{$n_gene}=$seq_utr;
d90 4
d99 2
a100 2
open(FW,">$gb_file_out");
open(FT,">temp.txt");
d133 8
a140 3
    if($max<$sim_thresh){
	print FT"\t$o-$max_seq_name-$max-$per_sim\n";
	print FW">$o($max-$max_seq_name)$h_seq_name{$o}\n$h_seq_utr{$o}\n";
d143 1
d145 2
a146 2
    close FW;
    close FT;
d149 1
@


1.1
log
@Initial revision
@
text
@d4 9
a12 6
my $gb_file="CP258.gb";
my $l_utr=500;
my $sim_thresh=80;
#$gb_file="CP258m.gb";
my $seqio_object = Bio::SeqIO->new(-file => $gb_file);
my $seq_object = $seqio_object->next_seq;
d21 2
a22 2
    #if ($feat_object->primary_tag eq "CDS") { 
    if ($feat_object->primary_tag eq "gene") { 
d33 17
a53 6
			    for my $tag ($feat_object->get_all_tags) {
				$seq_name.="$tag:";
				for my $value ($feat_object->get_tag_values($tag)){
				    $seq_name.="$value\t";
				}          
			    }       
a64 6
			    for my $tag ($feat_object->get_all_tags) {
				$seq_name.="$tag:";
				for my $value ($feat_object->get_tag_values($tag)){
				    $seq_name.="$value\t";
				}          
			    }       
d113 1
a113 1
	print FW">$o()$h_seq_name{$o}\n$h_seq_utr{$o}\n";
d117 3
a119 2
close FW;
close FT;
@

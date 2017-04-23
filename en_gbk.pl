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

my $l_utr=500;
my $l_dutr=500;
my $sim_thresh=90;
my $blast_thresh=90;
my $blast_len_thresh=0.50;

#my $l_utr=500;
#my $l_dutr=500;
#my $sim_thresh=2;
#my $blast_thresh=2;
my $blast_len_thresh=0.01;

my $n_other_source;
my %other_source_sequence_name;
my %other_source_sequence;

my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;
my $other_file_pattern=shift @ARGV;chomp $other_file_pattern;

system("ls -1 $other_file_pattern* > tempfile1");
my $tfl2;
open(FT2,"tempfile1");
my @other_file;
while($tfl2=<FT2>){
    chomp $tfl2;
    if($tfl2=~/gb$|gbk$/){
	push(@other_file,$tfl2);
    }
}
close FT2;



system("ls -1 $main_file_pattern* > tempfile1");
open(FT1,"tempfile1");
open(FT,">temp.txt");

my $total_seq_cnt_threshold=1500;
my $n_gene_threshold=1200;

my $total_seq_cnt_threshold=2;
my $n_gene_threshold=2;

my $total_seq_cnt;

my $tfl1;


#my $date_cnt=time;
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
open(FTTLDUTR,">$total_file_name_dutr");

while($tfl1=<FT1>){
    chomp $tfl1;
    if($tfl1=~/asn1$/){
		my @temp=split(/\./,$tfl1);
		my $foo=@temp[0].".gb";
		system("asn2gb.Win32 -i $tfl1 -o $foo -f b");
		select_utr($foo);
		#print "$tfl1\n";
    }
	else{
		my $foo=$tfl1;;
		select_utr($foo);
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
#print "Problem in $gb_file. Bad feature perhaps?\n" if $@;
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
my @t=split(/\./,$gb_file);
my $gb_file_out=@t[0].".utr.txt";
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
		   @t=split(/\(|\)/,$line);
		   @t[1]=~s/\%|\s+//g;
		   $per_sim=@t[1]+0;
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
	foreach (@other_file){
	    $other_seq_no++;
	    print "$_\t$other_seq_no\n";
	    get_other_source($_,$other_seq_no);
	}
	other_seq_comp($other_file_pattern,1);
	die"Total UTR Seq Count, $total_seq_cnt, reached $total_seq_cnt_threshold\n"; 
    }
    if(($max<$sim_thresh)){
	print FT"\t$o-$max_seq_name-$max-$per_sim\n";
	$total_seq_cnt++;
	print FTTLUTR">$h_seq_name{$o}\n$h_seq_utr{$o}\n";
	print FTTLDUTR">$h_seq_name{$o}\n$h_seq_dutr{$o}\n";
	print FTTL">$h_seq_name{$o}\n$h_seq{$o}\n";
	$total_seq_name{$total_seq_cnt}=$h_seq_name{$o};
	$total_seq_utr{$total_seq_cnt}=$h_seq_utr{$o};
	$total_seq_dutr{$total_seq_cnt}=$h_seq_dutr{$o};
	$total_seq{$total_seq_cnt}=$h_seq{$o};
	next;
    }
  }
}

sub get_other_source{
    my $foofile=shift;
    my $foofileno=shift;
    print "$foofile File Number $foofileno\n";
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
		    }
    }
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
   foreach my $i (sort {$a <=> $b} keys %other_source_sequence){
       #if($i==$o){
       #if($other_source_sequence_name{$i} =~ /dispar102e08/){
       true_string_match($o,$i);
       #water_string_match($o,$i);
       #needle_string_match($o,$i);
       blast2seq($o,$i,$foofile);
       #}
       #}
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
	    my $seq_i=$other_source_sequence{$i};
    $seq_i=~s/\-/N/g;
    $seq_o=~s/\-/N/g;

    my $seq_o_name=$total_seq_name{$o};
    my $seq_i_name=$other_source_sequence_name{$i};
    my $seq_o_length=length($total_seq{$o});
    my $seq_i_length=length($other_source_sequence{$i});

	    print "Aligning seq $o and seq $i with String Match\n";
	    #print FWOUTR"$total_seq_name{$o}\n$other_source_sequence_name{$i}\n$seq_i\n$seq_o\n";
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
    my $seq_i=$other_source_sequence{$i};
    $seq_i=~s/\-/N/g;
    $seq_o=~s/\-/N/g;
    my $seq_o_name=$total_seq_name{$o};
    my $seq_i_name=$other_source_sequence_name{$i};
    my $seq_o_length=length($total_seq{$o});
    my $seq_i_length=length($other_source_sequence{$i});
    
	    open(F1,">file1");
	    open(F2,">file2");
	    print F1">$seq_o_name\n$seq_o\n";
	    print F2">$seq_i_name\n$seq_i\n";
	    print "Aligning seq $o and seq $i with ";
	    system("water file1 file2 -gapopen=10 -gapext=0.5 -outfile=file3");
	    open(FN,"file3");
	    my $length;
            while(my $line=<FN>){
		if($line=~/^# Length: /){chomp $line;my @t=split(/\:/,$line);$length=@t[1];}
		if($line=~/^# Identity:     /){
		   my @t=split(/\(|\)/,$line);
		   @t[1]=~s/\%|\s+//g;
		   my $per_sim=@t[1]+0;
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
    my $seq_i=$other_source_sequence{$i};
    $seq_i=~s/\-/N/g;
    $seq_o=~s/\-/N/g;
    my $seq_o_name=$total_seq_name{$o};
    my $seq_i_name=$other_source_sequence_name{$i};
    my $seq_o_length=length($total_seq{$o});
    my $seq_i_length=length($other_source_sequence{$i});

	    open(F1,">file1");
	    open(F2,">file2");
	    print F1">$seq_o_name\n$seq_o\n";
	    print F2">$seq_i_name\n$seq_i\n";
	    print "Aligning seq $o and seq $i with ";
	    system("needle file1 file2 -gapopen=10 -gapext=0.5 -outfile=file3");
	    open(FN,"file3");
            my $length;
	    while(my $line=<FN>){
		if($line=~/^# Length: /){chomp $line;my @t=split(/\:/,$line);$length=@t[1];}
		if($line=~/^# Identity:     /){
		   my @t=split(/\(|\)/,$line);
		   @t[1]=~s/\%|\s+//g;
		   my $per_sim=@t[1]+0;
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
    my $seq_i=$other_source_sequence{$i};
    $seq_i=~s/\-/N/g;
    $seq_o=~s/\-/N/g;
    my $seq_o_name=$total_seq_name{$o};
    my $seq_i_name=$other_source_sequence_name{$i};
    my $seq_o_length=length($total_seq{$o});
    my $seq_i_length=length($other_source_sequence{$i});
    
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
	   "Score", $hsp->score,
	   "Direction", $hsp->strand), "\t";
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

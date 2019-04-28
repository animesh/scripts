#!/usr/bin/perl

use Bio::Seq;
use Bio::Index::Fasta;

print "File with list of genescan identified genes? ";		
$filename = <STDIN>;
open (FILENAME,$filename) || die " cannot open $filename: $!";

$dir="/home/andrew/exhome";
$db="eh2x";
$dbobj = Bio::Index::Abstract->new("$dir/$db");
while ($gene_seq =<FILENAME>) {
	chomp ($gene_seq);
	$gene_seq =~ s/pfcon-//; #remove header
	($start,$end,$name) = split /-/,$gene_seq;
	print "$start $end $name\n";
	$end = $start + $end;
	$name =~ s/cn_//;
	$name =~ s/ .*//;
	$id = $name;
	print "\n$name\n$start $end\n\n";
$seq=();

$seq = $dbobj->get_Seq_by_id($id);

$len = $seq->length();

if ($end <= ($len - 300)){
  $end = $end +300;
}else{
  $end = $len;
}
$gene = $seq->trunc($start,$end);
$sub_seq = $gene->seq();
gene_model($sub_seq);
$revgene = $gene->revcom();
$sub_seq = $revgene->seq();
gene_model($sub_seq);
}
print "Reached end";  

sub gene_model(\$)
{
$seq=shift(@_);
@seq=split(//,$seq);
@start_codon= qw(ATG atg);
@stop_codon=qw(TAA TAG taa tag tga);
@gene=();
@start_index=();
@stop_index=();
$length_of_seq=length($seq);
$noe=0;
@final=();
for($i=0;$i<$length_of_seq-2;$i++)
{

  $codon=$seq[$i].$seq[$i+1].$seq[$i+2];
  foreach $start_codon (@start_codon)
  {

    if($codon eq $start_codon)
    {
      $start_found+=1;
      @start_index=(@start_index,$i);
      #print "A start found at $i\n";
      last;	
    } ###End if
  } ## End foreach
  foreach $stop_codon (@stop_codon)
  {
    if($codon eq $stop_codon)
    {

      $stop_found+=1;
      @stop_index=(@stop_index,$i+3);
      #print "A stop found at $i";
      last;

   }
  }
 }# end outer for

 print "start: @start_index\n\n stops: @stop_index";

 foreach $stop_index (@stop_index)
 {
  foreach $start_index (@start_index)
  {
    $end=$stop_index;
    $difference= $stop_index-$start_index;
    if($difference%3==0 && $difference>60)
    {
      $start=$start_index;
      @gene=(@gene,$start,$end);
      $noe++;
      last;
    }
  }
 }

 for($i=0;$i<$noe;$i+=2)
 {
   for($j=2;$j<noe;$j+=2)
   {
     if($gene[$i]==$gene[$j])
     {
       $end=($gene[$i+1]>$gene[$j+1])?($gene[$i+1]):($gene[$j+1]);

     }
   }
   @final=(@final,$gene[$i],$end);

}

 print "@final";
}## End sub-routine
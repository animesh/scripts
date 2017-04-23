#!/usr/bin/perl -w

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
sub gene_model($)
{

$seq=shift(@_);
@start_codon= qw(ATG atg);
@stop_codon=qw(TAA TAG taa tag tga);
@stack1=();          ### To store start codon indices as they occur
$stack1_top=-1;      ### Points to the top-most element of the stack
@stack2=();          ### Used as a temporary storage structure
$stack2_top=-1;
@seq=split(//,$seq);
$length_of_seq=0;
$start_index=0;
$stop_index=0;
@gene = ();           ### initialising @gene
%gene =();
$length_of_seq = $#seq +1;
$noe=0;
$added_flag=0;
print "length of sequence : $length_of_seq\n";
for($i=0;$i<$length_of_seq-2;$i++)
{

  $codon=$seq[$i].$seq[$i+1].$seq[$i+2];
  foreach $start_codon (@start_codon)
  {

    if($codon eq $start_codon)
    {
      $start_found+=1;
      @start_indices=(@start_indices,$i);
      ### Push into stack1
      @stack1=(@stack1,$i);
      $stack1_top+=1;
      last;	
    } ###End if
  } ## End foreach
  foreach $stop_codon (@stop_codon)
  {
    if($codon eq $stop_codon)
    {

      $stop_found+=1;
      @stop_indices=(@stop_indices,$i);
      ### If a stop codon appears without a corresponding start codon neglect it
      while($stack1_top!=-1)
      {
        ###Pop from stack1 and compare indices. If in same frame join the sequence
        if($stack1_top>=0)
        {
         $start_index=$stack1[$stack1_top];
         $stack1_top-=1;
         $difference=$i-$start_index;
        }
        else
        {
          $difference=1;
        }
        ### If stop codon lies in the same frame
        if($difference%3==0 && $difference>=60)
        {

          @gene=(@gene,$start_index,$i+3);
          $noe++;
         }
         $added_flag=0;

        }
        else
        {
          ### Push This start codon index into stack2
          $stack2_top+=1;
          @stack2=(@stack2,$start_index);

        }

       }
      #### Restore those start codons whose matching stop codon is not yet found
      #### back into the first stack;
       @stack1=reverse(@stack2);
       @stack2=();
       $stack1_top=$stack2_top;
       $stack2_top=-1;
       	
    }##End If
   }### End foreach
 }### End outer for

for(my $ctr=0;$ctr<$noe;$ctr+=2)
{
  print "$gene[$ctr]\t$gene[$ctr+1]\n";

}
#foreach $genein (@gene){
#print "$genein\n";
#}

return;
}

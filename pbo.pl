use lib '/Home/siv11/ash022/bioperl/';
use Bio::SearchIO;

my $blast_report = new Bio::SearchIO ('-format' => 'blast',
			              '-file'   => $ARGV[0]);
my $result = $blast_report->next_result;


while( my $hit = $result->next_hit()) {    
  print "\thit name: ", $hit->name(),"\t";    
  while( my $hsp = $hit->next_hsp()) {  
#	if($hsp->score>1000){
		print join("\t",
			   #$hsp->P,
			   #$hsp->percent,
		   $hsp->score,
		   $hsp->bits,
		   #$hsp->percent,
		   #$hsp->P,
		   #$hsp->match,
		   #$hsp->positive,
		   $hsp->length,
		   $hsp->querySeq,
		   $hsp->sbjctSeq,
		   #$hsp->homologySeq,
		   $hsp->query->start,
		   $hsp->query->end,
		   $hsp->sbjct->start,
		   $hsp->sbjct->end,
		   $hsp->sbjct->seq_id,
		   #$hsp->sbjct->overlaps($exon),
			   "start" , $hsp->query->start(), 
			   "end",$hsp->query->end(),
			   $hsp->score,
			   "Dir", $strand), "\t";
#	}
	#last;
    }

	print "\n";	
}



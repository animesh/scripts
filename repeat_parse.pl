use Bio::Tools::BPlite;
my $report = new Bio::Tools::BPlite(-fh=>\*STDIN);

{
$report->query;
$report->database;
while(my $sbjct = $report->nextSbjct) {
   $name = $sbjct->name;
    while (my $hsp = $sbjct->nextHSP) {
#        $hsp->score;
#        $hsp->bits;
        $percent=$hsp->percent;
#        $hsp->P;
#        $hsp->match;
#        $hsp->positive;
        $length=$hsp->length;
        $qseq=$hsp->querySeq;
        $sseq=$hsp->sbjctSeq;
#        $hsp->homologySeq;
        $qs=$hsp->query->start;
        $qe=$hsp->query->end;
        $ss=$hsp->subject->start;
        $se=$hsp->subject->end;
        $hsp->subject->seqname;
        $hsp->subject->overlaps($exon);
    }
      $locseq = new Bio::LocatableSeq('-seq'=>('-'x($left{$var}-$left1)).$seq->seq(),
				    '-id'=>$var,}
				    '-start'=>$left{$var}-$left1,
				    '-end'=>$right{$var}-$left1,
				    );
       $aln->addSeq($locseq)

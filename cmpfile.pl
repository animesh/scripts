#!/usr/bin/perl
$f1=shift;
open(F1,$f1);
while(<F1>)
{
  if($_=~/^>/){
	chomp;
	$_=~s/^>//;
	@tmp=split(/\s+/);
	push(@name1,@tmp[0]);
	push(@name2,@tmp[2]);
	$n11{@tmp[0]}=@tmp[1];
	$n12{@tmp[2]}=@tmp[1];
	$namecord1{@tmp[0]}=@tmp[2];
	$cordname1{@tmp[2]}=@tmp[0];
            if ($seq ne ""){
              $seq1{@tmp[0]}=$seq;
              $seq = "";
            }
        }
        else{
            $seq=$seq.$_;
        }
}
$seq1{@tmp[0]}=$seq;
$seq="";
$f2=shift;
open(F2,$f2);
while(<F2>)
{
  if($_=~/^>/){
        chomp;
        $_=~s/^>//;
        @tmp=split(/\s+/);
        push(@name1,@tmp[0]);
        push(@name2,@tmp[2]);
        $n21{@tmp[0]}=@tmp[1];
        $n22{@tmp[2]}=@tmp[1];
        $namecord2{@tmp[0]}=@tmp[2];
	$cordname2{@tmp[2]}=@tmp[0];
            if ($seq ne ""){
              $seq2{@tmp[0]}=$seq;
              $seq = "";   
            } 
        }   
        else{
            $seq=$seq.$_;
        }   
}
$seq2{@tmp[0]}=$seq;
$seq="";
open(F1O,">$f1.$f2.res");
@uniquelistn = keys %{{map {$_=>1} @name1}};
foreach (@uniquelistn2){
        if($n11{$_} and $n21{$_}){
		$c2++;
                print F2O "$c2\t$_\t$n11{$_} and $n21{$_}\t$cordname1{$_} and $cordname2{$_} and $seq1{$_} and $seq2{$_}\n";
        }
}

__END__

$fp=$file1_$file2.".comp.txt";
open (FP,">$fp");
$fm=$file1_$file2.".mat.txt";
open (FM,">$fm");

for($c1=0;$c1<=$#seq1;c1++){
        open(F1,">file1");
        print F1">$seqname1[$c1]\n$seq1[$c1]\n";
        for($c2=0;$c2<=$#seq2;c2++){            
            open(F2,">file2");
            print F2">$seqname2[$c2]\n$seq2[$c2]\n";
            print "Aligning seq $seqname1[$c1] and seq $seqname2[$c2] with ";
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
                   print FP"$o-$i $seq_o_name\t$seq_i_name\t$per_sim\t$seq_o_length\t$seq_i_length\t$length\n";
                   print FM"$per_sim\t";
                   #}

                }
            }
            close FN;
            close F1;
            close F2;
        }
        print FM"\n";
}       

#!/usr/bin/perl

$file=shift @ARGV;chomp $file;
open (F,$file)||die "cant open  :$!";
$seq="";
while ($line = <F>){
        chomp ($line);
        if ($line =~ /^>/){
            $line =~ s/>//;
            push(@seqname,$line);
            if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
        }
        else{
            $seq=$seq.$line;
        }
}
push(@seq,$seq);
close F;
@seq1=@seq;
@seq1n=@seqname;
undef @seq;undef @seqname;

$file=shift @ARGV;chomp $file;
open (F,$file)||die "cant open  :$!";
$seq="";
while ($line = <F>){
        chomp ($line);
        if ($line =~ /^>/){
            $line =~ s/>//;
            push(@seqname,$line);
            if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
        }
        else{
            $seq=$seq.$line;
        }
}
push(@seq,$seq);
close F;
@seq2=@seq;
@seq2n=@seqname;
undef @seq;undef @seqname;

#$cont=affine($seq1,$seq2);
#print "\n\n>SEQ1.$seq1n[1]\n$seq1[1]\n>SEQ2.$seq2n[1]\n$seq2[1]\n\nSCORE-$cont\n\n";

for($c=0;$c<$#seq1;$c++){
	for($cc=0;$cc<=$#seq2;$cc++){
#		if($c < $cc){
			#$cont=affine(@seq[$c],@seq[$cc]);
			open(F1,">file1.txt");
			open(F2,">file2.txt");
			print F1">@seq1n[$c]\n@seq1[$c]\n";
			print F2">@seq2n[$cc]\n@seq2[$cc]\n";
#			system("bl2seq -i file1.txt -j file2.txt -p blastn -o $c.$cc.txt");
			system("supermatcher file1.txt file2.txt -gapopen=10 -gapext=1 -outfile=$c.$cc.txt");
			print "$c\t$cc\t@seq1n[$c]\t@seq2n[$cc]\t$cont\n";
			close F1;closeF2;
#		}
	}
}

sub affine {
	$sequence1=shift;chomp $seqeunce1;$seqeunce1=~s/\s+//g;
	@sequencerow=split(//,$sequence1); 
	unshift(@sequencerow,0);
	$sequence2=shift;chomp $seqeunce2;$seqeunce2=~s/\s+//g;
	@sequencecol=split(//,$sequence2);
	unshift(@sequencecol,0);
	for ($row=0;$row<=$#sequencerow;$row++)        {
		      for ($column=0;$column<=$#sequencecol;$column++){
		                      if ($row==0 ){
	                                $fscore1[$row][$column]=0-$gapopen*$column;
				      	if ($column>1 ){
		                        	$fscore1[$row][$column]=0-($gapopen+$gapext*$column);
		                        	$point1[$row][$column]="h";
					}
		                      }
		                      if ($column==0 ){
	                                $fscore1[$row][$column]=0-$gapopen*$column;
				      	if ($row>1 ){
		                        	$fscore1[$row][$column]=0-($gapopen+$gapext*$row);
		                        	$point1[$row][$column]="v";
					}
		                      }
		                      elsif ($row>0 and $column >0){
					$score=$fscore1[$row-1][$column-1]+$R{"$sequencecol[$column]-$sequencerow[$row]"};
					$fscore1[$row][$column]=$score;
					$point1[$row][$column]="d";
					if($score<($fscore1[$row-2][$column-1]-($gapopen+$gapext))){
						$score=$fscore1[$row-2][$column-1]-($gapopen+$gapext);
						$fscore1[$row][$column]=$score;
						$point1[$row][$column]="g";
					}
					if($score<($fscore1[$row-1][$column-1]-($gapopen+$gapext))){
						$score=$fscore1[$row-1][$column-1]-($gapopen+$gapext);
						$fscore1[$row][$column]=$score;
						$point1[$row][$column]="f";
					}
					if($score<($fscore1[$row-2][$column]-($gapext))){
						$score=$fscore1[$row-2][$column]-($gapext);
						$fscore1[$row][$column]=$score;
						$point1[$row][$column]="e";
					}
				      }
		                      print "$fscore1[$row][$column]-[$sequencecol[$column]-$sequencecol[$row]]-$point1[$row][$column]\t";
			}
			print "\n";
	}

	return ($score);
}


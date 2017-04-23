if($#ARGV<1){
    die "Usage: perl cluster_sort.pl file col_num, where file contains output from Tree with consensus sequences and motif scores added and col_num is the column with the score to use for the ranking (less is better)\n";
}

$file=$ARGV[0];
$col_num=$ARGV[1]-1;
open IN, $file;

$#details=$#bestscore=$#rankindex=$#bestrun=50000;

while($line=<IN>){
    if($line=~/^Cluster/){
	chomp($line);
	@a=split /\s/,$line;
#	chop($a[1]);
	$num=$a[1];
	$bestscore[$num]=10.0;
	$details[$num]="";
	while($line=<IN>){
	    chomp($line);
	    @a=split /\t/, $line;
	    last if($#a<$col_num);
	    $details[$num].=$line."\n";
	    if($bestscore[$num]>$a[$col_num]){
		$bestscore[$num]=$a[$col_num];
		$bestrun[$num]=$line;
	    }
	}
    }
}

for($i=1;$i<=$num;$i++){
    $rankindex[$i]=$i;
}

for($i=$num;$i>1;$i--){
    for($j=1;$j<$i;$j++){
	if($bestscore[$rankindex[$j]]>$bestscore[$rankindex[$j+1]]){
	    $temp=$rankindex[$j+1];
	    $rankindex[$j+1]=$rankindex[$j];
	    $rankindex[$j]=$temp;
	}
    }
}

for($i=1;$i<=$num;$i++){
    $br=$bestrun[$rankindex[$i]];
    $det=$details[$rankindex[$i]];
    @a=split /\t/,$br;
#    print STDOUT "Cluster $i\t$a[0]\t$a[1]\t$a[2]\t$a[4]\t$a[7]\t$a[8]\n\n";
    print STDOUT "Cluster $i\t$br\n\n";
    print STDOUT "$det\n\n";
    next;
    @b=split /\n/,$det;
    for($j=0;$j<=$#b;$j++){
	@c=split /\t/,$b[$j];
	print STDOUT "$c[0]\t$c[1]\t$c[2]\t$c[4]\t$c[7]\t$c[8]\n";
    }
    print STDOUT "\n";
}


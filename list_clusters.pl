if($#ARGV<1){
    die "Usage: perl list_clusters.pl file cutoff, where file contains output from Tree and cutoff is the value of the weakest connection to call a cluster in this listing\n";
}

$file=$ARGV[0];
open IN, $file;
$cutoff=$ARGV[1];

$num=0;
while($line=<IN>){
    $num++;
}
$num++;
#the number of clusters should be one less than the number of objects

close IN;
open IN, $file;
$#name_list=$num-1;
$#link=$num-1;
for($i=0;$i<$num;$i++){
    $link[$i]=$i;
}
$#seeds=$num-1;
$num_clusters=0;

#See vars below.  i is being subsumed by j.  A cluster is represented by a seed followed by a set of
#links terminated when link[i]==i.  Each i and j represent a set of such links along with the unique
#identifier name to be added at that step, name1.  So we go to the end of the link list from j, and at
#that point add a link to i.  In this way all of links associated with i are tacked on to the list from
#j.  After the specified cutoff is reached, seeds are collected.  The last line of the file has two 
#seeds, since in that case j is also a seed; hence the cleanup code at the end of the loop.

while($line=<IN>){
    chomp($line);
    @a=split /\t/,$line;
    $i=$a[0];
    $j=$a[1];
    $score=$a[2];
    $name1=$a[3]."\t".$a[4];
    $name2=$a[5]."\t".$a[6];
    $name_list[$i]=$name1;
    if($score>=$cutoff){
	$end=$j;
	while($link[$end]!=$end){
	    $end=$link[$end];
	}
	$link[$end]=$i;
    }
    else{
	$seeds[$num_clusters]=$i;
	$num_clusters++;
    }
}
$name_list[$j]=$name2;
$seeds[$num_clusters]=$j;
$num_clusters++;

print STDOUT "$num objects in $num_clusters clusters in file $file using cutoff $cutoff\n\n";

for($i=1;$i<=$num_clusters;$i++){
    $j=$seeds[$i-1];
    $count[$j]=1;
    for($node=$seeds[$i-1];$node!=$link[$node];$node=$link[$node]){
	$count[$j]++;
    }
}
$#seeds=$num_clusters-1;
@seeds_sorted = sort { $count[$a] <=> $count[$b] } @seeds;
@s2=reverse @seeds_sorted;

for($i=1;$i<=$num_clusters;$i++){
#    print STDOUT "Seeds\t$seeds[$i-1]\tSorted\t$seeds_sorted[$i-1]\tRev\t$s2[$i-1]\t$#s2\n";
    $j=$s2[$i-1];
    print STDOUT "Cluster $i ($count[$j] motifs):\n";
    print STDOUT "$name_list[$j]\n";
    for($node=$j;$node!=$link[$node];$node=$link[$node]){
	print STDOUT "$name_list[$link[$node]]\n";
    }	   
    print STDOUT "\n";
}

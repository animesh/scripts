if($#ARGV<1){
    die "orf_file master_file ident_file\n";
}

$orffile=$ARGV[0];
$master=$ARGV[1];
$idfile=$ARGV[2];

open IN, $master;
while($line=<IN>){
    if($line=~/^>/){
	$name=$line;
	@a=split /\s+/,$name;
	$key=substr($a[0],1);
	$nm{$key}=$name;
	if($key=~/_/){
	    @a=split /_/,$key;
	    for($i=0;$i<=$#a;$i++){
		$target{$a[$i]}=$key;
	    }
	}
	else{
	    $target{$key}=$key;
	}
    }
    else{
	$sq{$key}.=$line;
    }
}
close IN;

open ID, $idfile;
$num=0;
while($line=<ID>){
    chomp($line);
#    @a=split /\s+/,$line;
    $id[$num++]=$line;
}

open ORF,$orffile;
$n=0;
while($line=<ORF>){
    chomp($line);
    $line=~s/\015//g;
    $line=~tr/a-z/A-Z/;
    $k=$target{$line};
    if($k eq ""){
	print STDERR "no match for $line\n";
    }
    else{
	$f[$n++]=$k;
    }
}
@g=sort @f;
$last="not here";
$j=0;
for($i=0;$i<=$#f;$i++){
    next if($g[$i] eq $last);
    $rfs[$j++]=$g[$i];
    $last=$g[$i];
}

for($j=0;$j<=$#rfs;$j++){
    for($i=0;$i<$num;$i++){
	if($id[$i]=~/$rfs[$j]/){
#	    print "considering $rfs[$j]\n";
	    $mb{$rfs[$j]}=1;
	    next;
	}
    }
}

$cnt2=0;
for($i=0;$i<=$#rfs;$i++){
    if(!$mb{$rfs[$i]}){
	$rfs2[$cnt2++]=$rfs[$i];
    }
}

for($i=0;$i<$num;$i++){
    @a=split /\s+/,$id[$i];
    for($j=0;$j<=$#a;$j++){
	if($mb{$a[$j]}){
	    $rfs2[$cnt2++]=$a[$j];
	    last;
	    #this ensures that only the first in the id will be kept
	}
    }
}

@s_rfs2=sort @rfs2;
for($i=0;$i<$cnt2;$i++){
#    print "$s_rfs2[$i]\n";
    print "$nm{$s_rfs2[$i]}$sq{$s_rfs2[$i]}";
}

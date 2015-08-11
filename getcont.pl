#under GPL from krishn.bhakt@gmail.com
#!/usr/bin/perl
if((@ARGV)!=3){die "3 args needed\n";}
$file1=shift @ARGV;
$file2=shift @ARGV;
open(F1,$file2);
open(F2,$file1);
$length1=25;
$length2=$length1;
$file4=shift @ARGV;
open(F4,$file4);
        while ($line4=<F4>) {
                chomp ($line4);
                if ($line4 =~ /\(OK\)/){
			@jvt=split(/\./,$line4);
			$mval="@jvt[2]-@jvt[4]";
			$mval=~s/\'|\s+|C//g;
			$joinval{"@jvt[1]-@jvt[3]"}=$mval;
			$joinval{"@jvt[3]-@jvt[1]"}=reverse($mval);
		print "@jvt[1]-@jvt[3]\t$joinval{\"@jvt[1]-@jvt[3]\"}\t$joinval{\"@jvt[3]-@jvt[1]\"}\n";
                    }
        }

#getgraph();
readseqfile();
printconcatstring();

sub readseqfile {
	while ($line = <F2>) {
		chomp ($line);
		if ($line =~ /^>/){
		        $snames=$line;
		        chomp $snames;
		     push(@seqname,$snames);
		        if ($seq ne ""){
		      push(@seq,$seq);
		      $seq = "";
		    }
	      } else {$seq=$seq.$line;
	      }
	}push(@seq,$seq);
	$seq="";
	close F2;
}



sub printconcatstring {
	while(<F1>){
		@t1=split(/\s+/);
		if(@t1[0] eq "C"){
			$v1="C.".@t1[1];
			$v2="C.".@t1[3];
			$e1=@t1[2];
			$e2=@t1[4];
			$readcnt=@t1[5];
		        $node{$v1}++;
			$node{$v2}++;
			$label="$e1->$e2($readcnt)";
			($namen50s,$n50s)=ga("N",50);

			#$e1=10;$e2=10;#get other loops out
			if($e1==3 && $e2==5){
				
				$fas1=substr(@seq[@t1[1]-1],-($length1),$length1);
				$fas2=substr(@seq[@t1[3]-1],0,$length2);
				$fastest1=substr(@seq[@t1[1]-1],0,$length1).substr(@seq[@t1[1]-1],-($length1),$length1);
				$fastest2=substr(@seq[@t1[3]-1],0,$length2).substr(@seq[@t1[3]-1],-($length2),$length2);
				$rfastest1=reverse($fastest1);
				$rfastest2=reverse($fastest2);
				$rfastest1 =~ tr/ACGTacgt/TGCAtgca/;
				$rfastest2 =~ tr/ACGTacgt/TGCAtgca/;
				$rrfastest1=reverse($rfastest1);
				$rrfastest2=reverse($rfastest2);
				#print length($fastest1).$length1.length($fastest2).$length2."\n";
				if(length($fas1)==$length1 && length($fas2)==$length2 && $joinval{"$cnam{$v1}-$cnam{$v2}"} eq "3-5"){
					print ">FF.$cnam{$v1}.$e1.$cnam{$v2}.$e2\t$v1->$node{$v1}->$clen{$v1}->$cdep{$v1}\t$v2->$node{$v2}->$clen{$v2}->$cdep{$v2}\t$label\n";
					print $fas1.$n50s.$fas2."\n";
				}			
			}
			if($e1==3 && $e2==3){
				$fas1=substr(@seq[@t1[1]-1],-($length1),$length1);
				$fas2=substr(@seq[@t1[3]-1],-($length2),$length2);
				$rfas2=reverse($fas2);
				$rfas2 =~ tr/ACGTacgt/TGCAtgca/;
				$revcomp1 = reverse($fas2);
				$revcomp1 =~ tr/ACGTacgt/TGCAtgca/;
				$fastest1=substr(@seq[@t1[1]-1],0,$length1).substr(@seq[@t1[1]-1],-($length1),$length1);
				$fastest2=substr(@seq[@t1[3]-1],0,$length2).substr(@seq[@t1[3]-1],-($length2),$length2);
				$rfastest1=reverse($fastest1);
				$rfastest2=reverse($fastest2);
				$rfastest1 =~ tr/ACGTacgt/TGCAtgca/;
				$rfastest2 =~ tr/ACGTacgt/TGCAtgca/;
				$rrfastest1=reverse($rfastest1);
				$rrfastest2=reverse($rfastest2);
				if(length($fas1)==$length1 && length($fas2)==$length2 && $joinval{"$cnam{$v1}-$cnam{$v2}"} eq "3-3"){
					print ">FR.$cnam{$v1}.$e1.$cnam{$v2}.$e2\t$v1->$node{$v1}->$clen{$v1}->$cdep{$v1}\t$v2->$node{$v2}->$clen{$v2}->$cdep{$v2}\t$label\n";
					print $fas1.$n50s.$rfas2."\n";
				}			
			}
			if($e1==5 && $e2==3){
				$fas1=substr(@seq[@t1[1]-1],0,$length1);
				$rfas1=reverse($fas1);
				$rfas1 =~ tr/ACGTacgt/TGCAtgca/;
				$rrfas1=reverse($rfas1);
				$fas2=substr(@seq[@t1[3]-1],-($length2),$length2);
				$rfas2=reverse($fas2);
				$rfas2 =~ tr/ACGTacgt/TGCAtgca/;
				$fastest1=substr(@seq[@t1[1]-1],0,$length1).substr(@seq[@t1[1]-1],-($length1),$length1);
				$fastest2=substr(@seq[@t1[3]-1],0,$length2).substr(@seq[@t1[3]-1],-($length2),$length2);
				$rfastest1=reverse($fastest1);
				$rfastest2=reverse($fastest2);
				$rfastest1 =~ tr/ACGTacgt/TGCAtgca/;
				$rfastest2 =~ tr/ACGTacgt/TGCAtgca/;
				$rrfastest1=reverse($rfastest1);
				$rrfastest2=reverse($rfastest2);
				if(length($fas1)==$length1 && length($fas2)==$length2 && $joinval{"$cnam{$v1}-$cnam{$v2}"} eq "5-3"){
					print ">RR.$cnam{$v1}.$e1.$cnam{$v2}.$e2\t$v1->$node{$v1}->$clen{$v1}->$cdep{$v1}\t$v2->$node{$v2}->$clen{$v2}->$cdep{$v2}\t$label\n";
					print $rrfas1.$n50s.$rfas2."\n";
				}			
			}			
			if($e1==5 && $e2==5){
				$fas1=substr(@seq[@t1[1]-1],0,$length1);
				$rfas1=reverse($fas1);
				$rfas1 =~ tr/ACGTacgt/TGCAtgca/;
				$rrfas1=reverse($rfas1);
				$fas2=substr(@seq[@t1[3]-1],0,$length2);
				$fastest1=substr(@seq[@t1[1]-1],0,$length1).substr(@seq[@t1[1]-1],-($length1),$length1);
				$fastest2=substr(@seq[@t1[3]-1],0,$length2).substr(@seq[@t1[3]-1],-($length2),$length2);
				$rfastest1=reverse($fastest1);
				$rfastest2=reverse($fastest2);
				$rfastest1 =~ tr/ACGTacgt/TGCAtgca/;
				$rfastest2 =~ tr/ACGTacgt/TGCAtgca/;
				$rrfastest1=reverse($rfastest1);
				$rrfastest2=reverse($rfastest2);
				if(length($fas1)==$length1 && length($fas2)==$length2 && $joinval{"$cnam{$v1}-$cnam{$v2}"} eq "5-5"){
					print ">RF.$cnam{$v1}.$e1.$cnam{$v2}.$e2\t$v1->$node{$v1}->$clen{$v1}->$cdep{$v1}\t$v2->$node{$v2}->$clen{$v2}->$cdep{$v2}\t$label\n";
					print $rrfas1.$n50s.$fas2."\n";
				}			
			}
			#print "@seqname[@t1[1]-1]\n@seq[@t1[1]-1]\n";
			#print "@seqname[@t1[3]-1]\n@seq[@t1[3]-1]\n";
		}
		elsif (@t1[0] =~ /[0-9]/){
			$clen{"C.@t1[0]"}=@t1[2];
			$cdep{"C.@t1[0]"}=@t1[3];
			$cnam{"C.@t1[0]"}=@t1[1];
			push(@cl,@t1[2]);
		}
	}
	close F1;
}
sub gs{
	my $c;
	my $seq;
	my $b;
	my %atgc;
	my $name=shift;
	while($c<$cnt){
		$c++;
		$b=@base[rand(int(4))];
		$seq.=$b;
		$atgc{$b}++;
	}
	$name="Seq.$name\t";
	foreach (keys %atgc){$name.="$_=>$atgc{$_}\t";}
	return ($name,$seq);
}

sub ga{
	my $c;
	my $seq;
	my $b;
	my %atgc;
	my $name=shift;
	my $cnt=shift;
	while($c<$cnt){
		$c++;
		$b=$name;
		$seq.=$b;
		$atgc{$b}++;
	}
	$name=">Seq.$name\t";
	foreach (keys %atgc){$name.="$_=>$atgc{$_}\t";}
	return ($name,$seq);
}
__END__
sub getgraph{
	use GraphViz;
	$g = GraphViz->new(directed => 0); # A graphviz undirected graph.
	use Graph::Traversal;
	use Graph::Directed;
	use Graph::Undirected;
	$cg = Graph::Directed->new;   # A directed graph.
	$wcg = Graph::Directed->new;   # A directed graph with weights.
	$ucg = Graph::Undirected->new;   # A undirected graph.
	$wucg = Graph::Undirected->new;   # A undirected graph with weights.

	open(F,$file1);
	while(<F>){
		@t1=split(/\s+/);
		if(@t1[0] eq "C"){
			$v1="C.".@t1[1];
			$v2="C.".@t1[3];
			$rv1="C.".@t1[1].".R";
			$rv2="C.".@t1[3].".R";
			$e1=@t1[2];
			$e2=@t1[4];
			$readcnt=@t1[5];
		        $node{$v1}++;
			$node{$v2}++;
			$label="$e1->$e2($readcnt)";
			$wucg->add_weighted_path($v1,$readcnt,$v2);
		        #if($node{$v1}<1){
		               	$g->add_node($v1, label => $v1."\ndep-".$cdep{$v1}."\nlen-".$clen{$v1}."\n");
				#$g->add_node($v1);
				$cg->add_vertex($v1);	
				$ucg->add_vertex($v1);
				$cg->add_vertex($rv1);
		        #}
	   		#if($node{$v2}<1){
			      	$g->add_node($v2, label => $v2."\ndep-".$cdep{$v2}."\nlen-".$clen{$v2}."\n");
				#$g->add_node($v2);
				$ucg->add_vertex($v2);
				$cg->add_vertex($v2);
				$cg->add_vertex($rv2);
			#}
			if($readcnt>0){
	       			$g->add_edge($v1=>$v2,label=>$label);			
				#$g->add_edge($v1=>$v2);			
				$ucg->add_edge($v1,$v2);
				if($e1==3 && $e2==5){
					$wcg->add_weighted_path($v1,$readcnt,$v2);
					$wcg->add_weighted_path($rv2,$readcnt,$rv1);
					$cg->add_edge($v1,$v2);
					$cg->add_edge($rv2,$rv1);
					$edge_wcg{$v1.$v2}=$readcnt;
					$edge_wcg{$rv2.$rv1}=$readcnt;
				}
				if($e1==3 && $e2==3){ 
					$wcg->add_weighted_path($v1,$readcnt,$rv2);
					$wcg->add_weighted_path($v2,$readcnt,$rv1);
					$cg->add_edge($v1,$rv2);
					$cg->add_edge($v2,$rv1);
					$edge_wcg{$v1.$rv2}=$readcnt;
					$edge_wcg{$v2.$rv1}=$readcnt;
				}
				if($e1==5 && $e2==3){
					$wcg->add_weighted_path($rv1,$readcnt,$rv2);
					$wcg->add_weighted_path($v2,$readcnt,$v1);
					$cg->add_edge($rv1,$rv2);
					$cg->add_edge($v2,$v1);
					$edge_wcg{$rv1.$rv2}=$readcnt;
					$edge_wcg{$v2.$v1}=$readcnt;
				}
				if($e1==5 && $e2==5){
					$wcg->add_weighted_path($rv1,$readcnt,$v2);
					$wcg->add_weighted_path($rv2,$readcnt,$v1);
					$cg->add_edge($rv1,$v2);
					$cg->add_edge($rv2,$v1);
					$edge_wcg{$rv1.$v2}=$readcnt;
					$edge_wcg{$rv2.$v1}=$readcnt;
				}
			}
			#print "$v1->$node{$v1}\t$v2->$node{$v2}\t$label\t\t$rv1-$v2\t$edge_wcg{$rv1-$v2}\t$cdep{$v1}\t$cdep{$v2}\n";		
	
		}
		elsif (@t1[0] =~ /[0-9]/){
			$clen{"C.@t1[0]"}=@t1[2];
			$clen{"C.@t1[0].R"}=@t1[2];
			$cdep{"C.@t1[0]"}=@t1[3];
			$cnam{"C.@t1[0]"}=@t1[1];
			push(@cl,@t1[2]);
		}
	}
	open(FOPG,">$file1.gv.png");
	print FOPG $g->as_png;
	$APSP = $wcg->APSP_Floyd_Warshall;

	print "Graph: ", $wcg->stringify(), "\n";
	my @v = sort $wcg->vertices();
	print "Vertices: @v\n";

	# find and remove all cycles
	while( my @cyc = $wcg->find_a_cycle() ) {
		print "\nFound cycle: @cyc\n";
		my $apsp = $wcg->APSP_Floyd_Warshall();
		my %dist = map { $_ => $apsp->path_length('a',$_) } @cyc;
		my $far = (sort { $dist{$a} <=> $dist{$b} } keys %dist )[-1];
		print "Farthest vertex is $far\n";
		CYC: for my $v ( @cyc ) {
			next if $v eq $far;
			next unless $wcg->has_edge($far,$v);
			print "Remove edge (${far}->$v)\n";
			$wcg->delete_edge($far,$v);
			print "Graph is now: ", $wcg->stringify(), "\n";
			last CYC;
		}
	}
	foreach my $v ( $APSP->vertices ) { printf "%-9s ", "$v" } print "\n";
		foreach my $u ( $APSP->vertices ) {
			print "$u: ";
			foreach my $v ( $APSP->vertices ) {
				my $w = $APSP->get_attribute("weight", $u, $v);
				if (defined $w) {
					my $p = $APSP->get_attribute("path", $u, $v);
				printf "(%-5s)=%d ", "@$p", $w
				} 
				else {
					printf "%-9s ", "-"
				}
		}
		print "\n"
	}
	close F;
}

sub dump {
	#$SSSP = $wcg->SPT_Dijkstra;
	#print "$v1\t$v2\t$rv1\t$rv2\n$sptg\n";
	#$SSSP = $wucg->SSSP_Dijkstra($v2);
	#$SSSP = $wucg->SSSP_Dijkstra("C.1");
	#@apwcg = $wucg->articulation_points;
	#print "Contig Graph	 articulation points = @apwucg\n";
	#use Graph::Traversal::DFS;
    	#$b = Graph::Traversal::BFS->new($cg,%opt);
	#$b = Graph::Traversal::DFS->new($ucg);
	#$b->dfs; # Do the traversal.
	#@topo=$wucg->articulation_points;
	#@topo=$wucg->MST_Prim;
		#@topo=$wucg->MST_Kruskal;
	#print "$wucg\n$b\n";
	#for($c=0;$c<=$#topo;$c++){	
	#	print "@topo[$c]\n";	
	#}		
	#$SSSP = $wcg->SPT_Bellman_Ford;
	foreach my $u ( $SSSP->vertices ) {
		#print "$u - ",$SSSP->get_vertex_attribute($u, 'weight')," - ", $SSSP->get_vertex_attribute($u, 'p'), "\n"
	}
	$dwcg = $wcg->diameter;
	#print "$dwcg\n";
	@lpwcg = $wcg->longest_path;
	#print join ",", @lpwcg, "\n";
	$gvlpwcg= GraphViz->new();
	for($c=0;$c<$#lpwcg;$c++){
		$u=@lpwcg[$c];	
		$v=@lpwcg[$c+1];
		$d=$edge_wcg{$u.$v};
		$l=$clen{$u};
		if($l<0){	
			foreach $sl (@seenl) {if($sl==$l){
					open(GVLP,">$file1.lp.png");
					print GVLP $gvlpwcg->as_png;
					close GVLP;
					exit;
				}
			}
			push(@seenl,$l);
			$totall+=$l;
			#print "$u-$v\t$d\t$l\t$totall\n";	
			$gvlpwcg->add_node($u, label => $u,color=>'grey');
			$gvlpwcg->add_node($v, label => $v,color=>'grey');
			$gvlpwcg->add_edge($u=>$v,label=>$totall,color=>'orange',style=>'bold');			
		}
	}		
}


sub randseq {
	@base=qw/A T G C/;
	$cnt=250;
	$ts=4;

	for($c=0;$c<$ts;$c++){
		$n="$c.".time;
		($n1,$s1)=gs($n);
		($n2,$s2)=ga("ATG");
		$tn.=$n1.$n2;
		$s.=$s1.$s2;
	
	}
print ">$tn\n$s\n";
}




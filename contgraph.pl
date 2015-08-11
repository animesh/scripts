use lib '/usit/titan/u1/ash022/Graph-0.94/lib';
use lib '/usit/titan/u1/ash022/IPC-Run-0.90/lib';
use lib '/usit/titan/u1/ash022/GraphViz-2.04/lib'; 
if((@ARGV)!=2){die "2 args needed\n";}
$file1=shift @ARGV;
$file2=shift @ARGV;
open(F1,$file1);
open(F2,$file2);
$length1=100;
$length2=$length1;

getgraph();
#readseqfile();
#printconcatstring();

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
            if($e1==5 && $e2==3){
                print ">RR.$cnam{$v1}.$e1.$cnam{$v2}.$e2\t$v1->$node{$v1}->$clen{$v1}->$cdep{$v1}\t$v2->$node{$v2}->$clen{$v2}->$cdep{$v2}\t$label\n";
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
                print $rrfas1.$rfas2."\n";
            }
            $e1=10;$e2=10;#get other loops out
            if($e1==3 && $e2==5){
                print ">FF.$cnam{$v1}.$e1.$cnam{$v2}.$e2\t$v1->$node{$v1}->$clen{$v1}->$cdep{$v1}\t$v2->$node{$v2}->$clen{$v2}->$cdep{$v2}\t$label\n";
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
                print $fas1.$fas2."\n";
            }
        
            if($e1==3 && $e2==3){
                print ">FR.$cnam{$v1}.$e1.$cnam{$v2}.$e2\t$v1->$node{$v1}->$clen{$v1}->$cdep{$v1}\t$v2->$node{$v2}->$clen{$v2}->$cdep{$v2}\t$label\n";
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
                print $fas1.$rfas2."\n";
            }
            if($e1==5 && $e2==5){
                print ">RF.$cnam{$v1}.$e1.$cnam{$v2}.$e2\t$v1->$node{$v1}->$clen{$v1}->$cdep{$v1}\t$v2->$node{$v2}->$clen{$v2}->$cdep{$v2}\t$label\n";
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
                print $rrfas1.$fas2."\n";
            }
    #        print "@seqname[@t1[1]-1]\n@seq[@t1[1]-1]\n";
    #        print "@seqname[@t1[3]-1]\n@seq[@t1[3]-1]\n";
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

sub getgraph{
    use GraphViz;
    $g = GraphViz->new();use Graph::Traversal::BFS;
    use Graph::Directed;
    use Graph::Undirected;
    $cg = Graph::Directed->new;   # A directed graph.
    $wcg = Graph::Directed->new;   # A directed graph.
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
#            $wucg->add_weighted_path(qw($v1 $readcnt $v2));            
            $wucg->add_weighted_path($v1,$readcnt,$v2);
                if($node{$v1}<1){
                           $g->add_node($v1, label => $v1);
                $cg->add_vertex($v1);
                $ucg->add_vertex($v1);
                $wucg->add_vertex($v1);
                $cg->add_vertex($rv1);
                  }
               if($node{$v2}<1){
                      $g->add_node($v2, label => $v2);
                $ucg->add_vertex($v2);
                $wucg->add_vertex($v2);
                $cg->add_vertex($v2);
                $cg->add_vertex($rv2);
            }
            if($readcnt>0){
                   $g->add_edge($v1=>$v2,label=>$label);            
            $ucg->add_edge($v1,$v2);
            #$wucg->add_edge($v1,$v2);
                if($e1==3 && $e2==5){
                    $wcg->add_weighted_path($v1,$readcnt,$v2);
                    $wcg->add_weighted_path($rv2,$readcnt,$rv1);
                    $cg->add_edge($v1,$v2);
                    $cg->add_edge($rv2,$rv1);
                }
                if($e1==3 && $e2==3){
                    $wcg->add_weighted_path($v1,$readcnt,$rv2);
                    $wcg->add_weighted_path($v2,$readcnt,$rv1);
                    $cg->add_edge($v1,$rv2);
                    $cg->add_edge($v2,$rv1);
                }
                if($e1==5 && $e2==3){
                    $wcg->add_weighted_path($rv1,$readcnt,$rv2);
                    $wcg->add_weighted_path($v2,$readcnt,$v1);
                    $cg->add_edge($rv1,$rv2);
                    $cg->add_edge($v2,$v1);
                }
                if($e1==5 && $e2==5){
                    $wcg->add_weighted_path($rv1,$readcnt,$v2);
                    $wcg->add_weighted_path($rv2,$readcnt,$v1);
                    $cg->add_edge($rv1,$v2);
                    $cg->add_edge($rv2,$v1);
                }
            }
            #print "$v1->$node{$v1}\t$v2->$node{$v2}\t$label\n";
        }
    }
    open(FOPG,">$file1.png");
    print FOPG $g->as_png;
    use Graph::Traversal::DFS;
        #$b = Graph::Traversal::BFS->new($cg,%opt);
    #$b = Graph::Traversal::DFS->new($ucg);
    #$b->dfs; # Do the traversal.
    #@topo=$ucg->articulation_points;
    @topo=$wucg->MST_Prim;
    #@topo=$wucg->MST_Kruskal;
    print "$wucg\n$b\n";
    for($c=0;$c<=$#topo;$c++){    
        print "@topo[$c]\n";    
    }
    $SSSP = $wcg->SSSP_Dijkstra();
    foreach my $u ( $SSSP->vertices ) {
        print "$u ", $SSSP->get_attribute("weight", $u)," ", @{ $SSSP->get_attribute("path", $u) }, "\n"
    }
    close F;
}



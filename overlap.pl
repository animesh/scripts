#source http://en.wikibooks.org/wiki/Algorithm_implementation/Strings/Longest_common_substring#Perl
use strict;
use warnings;

my @reads = <>;

# normalise: keep only the most common k-mer length
my %lc;
for (@reads) { my $s=$_; chomp $s; $s=~s/\s+//g; $lc{length($s)}++ if $s ne "" }
my ($k) = sort { $lc{$b}<=>$lc{$a} } keys %lc;

# De Bruijn: build (k-1)-mer graph in one pass before the pairwise loop
my (%dbadj, %in_deg, %out_deg);
for my $r (@reads) {
	my $s=$r; chomp $s; $s=~s/\s+//g;
	next if $s eq "" or length($s) != $k;
	my ($u,$v) = (substr($s,0,$k-1), substr($s,1));
	push @{$dbadj{$u}}, $v;
	$out_deg{$u}++; $in_deg{$v}++;
}

# OLC: pairwise overlap -- your original loop, two fixes inside
my %ovlidx;
for(my $c1=0;$c1<=$#reads;$c1++){
	my $str1=$reads[$c1];
	chomp $str1;
	my $len1=length($str1);
	$str1=~s/\s+//g;
	next if length($str1) != $k;	# skip truncated tail k-mers
	for(my $c2=$c1+1;$c2<=$#reads;$c2++){
		my $str2=$reads[$c2];
		chomp $str2;
		my $len2=length($str2);
		$str2=~s/\s+//g;
		if($str2 ne $str1 and $str1 ne "" and $str2 ne "" and $len1 == $len2){
			my @ovl=overlap($str1,$str2);
			my $lenovl=length($ovl[0]);
			if($lenovl==($len2-1)){
				print "$str1\t$len1\t$str2\t$len2\t@ovl\t$lenovl\n";
				$ovlidx{$str1}=$str2;	# FIX: store kmer->kmer directly
			}
		}
	}
}

# OLC: walk %ovlidx chains to produce contigs
my %is_succ = map { $_ => 1 } values %ovlidx;
my @olc_starts = grep { !$is_succ{$_} } keys %ovlidx;
my @olc_contigs;
for my $start (@olc_starts) {
	my ($cur, $seq, %seen) = ($start, $start, ($start=>1));
	while (exists $ovlidx{$cur} and !$seen{$ovlidx{$cur}}) {
		$cur = $ovlidx{$cur};
		$seq .= substr($cur, $k-1);
		$seen{$cur} = 1;
	}
	push @olc_contigs, $seq;
}
@olc_contigs = sort { length($b)<=>length($a) } @olc_contigs;
print "\n--- OLC: ", scalar @olc_contigs, " contig(s) ---\n";
for my $i (0..$#olc_contigs) {
	printf ">contig_%d  len=%d\n%s\n", $i+1, length($olc_contigs[$i]), $olc_contigs[$i];
}

# De Bruijn: weakly connected components then Hierholzer per component
my %und;	# undirected adjacency for BFS
for my $u (keys %dbadj) {
	for my $v (@{$dbadj{$u}}) { push @{$und{$u}},$v; push @{$und{$v}},$u }
}
my (%vis, @comps);
my %all_nodes = map { $_ => 1 } (keys %dbadj, map { @{$dbadj{$_}} } keys %dbadj);
for my $n (keys %all_nodes) {
	next if $vis{$n};
	my (@comp, @q);		# declare separately -- my (@a,@b)=(x) is greedy
	push @q, $n; $vis{$n}=1;
	while (@q) {
		my $c=shift @q; push @comp,$c;
		push @q, grep { !$vis{$_}++ } @{$und{$c}//[]};
	}
	push @comps, \@comp;
}

my %adj_copy;	# consumed by Hierholzer -- copy so %dbadj stays intact
for my $u (keys %dbadj) { $adj_copy{$u}=[@{$dbadj{$u}}] }

my @dbg_contigs;
for my $comp (@comps) {
	# start at the node with out-in==1, else any node with out-edges
	my $start = (grep { ($out_deg{$_}//0)-($in_deg{$_}//0)==1 } @$comp)[0]
	         // (grep { ($out_deg{$_}//0)>0 } @$comp)[0];
	next unless defined $start;
	my (@stack,@path);
	push @stack,$start;
	while (@stack) {
		my $v=$stack[-1];
		if (@{$adj_copy{$v}//[]}) { push @stack, pop @{$adj_copy{$v}} }
		else                       { push @path,  pop @stack             }
	}
	@path=reverse @path;
	push @dbg_contigs, $path[0].join("",map{substr($_,-1)}@path[1..$#path]);
}
@dbg_contigs = sort { length($b)<=>length($a) } @dbg_contigs;
print "\n--- De Bruijn: ", scalar @dbg_contigs, " contig(s) ---\n";
for my $i (0..$#dbg_contigs) {
	printf ">contig_%d  len=%d\n%s\n", $i+1, length($dbg_contigs[$i]), $dbg_contigs[$i];
}

sub overlap{
  my ($str1, $str2) = @_; 
  my $l_length = 0; # length of longest common substring
  my $len1 = length $str1; 
  my $len2 = length $str2; 
  my @char1 = (undef, split(//, $str1)); # $str1 as array of chars, indexed from 1
  my @char2 = (undef, split(//, $str2)); # $str2 as array of chars, indexed from 1
  my @lc_suffix; # "longest common suffix" table
  my @substrings; # list of common substrings of length $l_length
  for my $n1 ( 1 .. $len1 ) { 
    for my $n2 ( 1 .. $len2 ) { 
      if ($char1[$n1] eq $char2[$n2]) {
        $lc_suffix[$n1-1][$n2-1] ||= 0;
        $lc_suffix[$n1][$n2] = $lc_suffix[$n1-1][$n2-1] + 1;
        if ($lc_suffix[$n1][$n2] > $l_length) {
          $l_length = $lc_suffix[$n1][$n2];
          @substrings = ();
        }
        if ($lc_suffix[$n1][$n2] == $l_length) {
          push @substrings, substr($str1, ($n1-$l_length), $l_length);
        }
      }
    }
  }   
  return @substrings;
}
__END__
perl -e '@b=qw/A T G C/;while($l<100){print @b[int(rand(4))];$l++;}' > rangen.txt
perl -ne 'for($c=0;$c<length;$c++){print substr($_,$c,10);print "\n"};' rangen.txt > rangen.txt.kmer 
perl overlap.pl rangen.txt.kmer

#source http://en.wikibooks.org/wiki/Algorithm_implementation/Strings/Longest_common_substring#Perl
use strict;
use warnings;

my @reads = <>;

# detect k-mer mode (sliding-window input) vs peptide mode (variable-length)
# k-mer files have >50% of strings at the same length; tail truncations are artifacts
my %lc;
for (@reads) { my $s=$_; chomp $s; $s=~s/\s+//g; $lc{length($s)}++ if $s ne "" }
my ($k)       = sort { $lc{$b}<=>$lc{$a} } keys %lc;
my $total     = grep { /\S/ } @reads;
my $kmer_mode = ($lc{$k}/$total > 0.5);   # >50% same length => k-mer mode, filter outliers
my $tile_k    = $k;                        # De Bruijn always tiles at most-common length
printf STDERR "kmer_mode=%s  k=%d  tile_k=%d\n", $kmer_mode?"yes":"no", $k, $tile_k;

# De Bruijn: tile every string of length >= tile_k into tile_k-mers in k-mer mode strings are already tile_k-mers; in peptide mode longer strings get tiled: peptides with internal repeats create shared (tile_k-1)-mer nodes that produce Eulerian paths not matching any real sequence -- OLC is preferred for peptides
my (%dbadj, %in_deg, %out_deg);
for my $r (@reads) {
	my $s=$r; chomp $s; $s=~s/\s+//g;
	next if $s eq "" or length($s) < $tile_k;
	next if $kmer_mode and length($s) != $tile_k;   # skip tail truncations
	for (my $i=0; $i<=length($s)-$tile_k; $i++) {
		my $km=substr($s,$i,$tile_k);
		my ($u,$v)=(substr($km,0,$tile_k-1), substr($km,1));
		push @{$dbadj{$u}},$v; $out_deg{$u}++; $in_deg{$v}++;
	}
}

# OLC: pairwise overlap k-mer mode:   both strings must be length k; overlap must be exactly k-1 (original logic) and peptide mode: any length; sfx_pfx in both directions; keep longest overlap per predecessor
my %ovlidx;
for(my $c1=0;$c1<=$#reads;$c1++){
	my $str1=$reads[$c1];
	chomp $str1;
	my $len1=length($str1);
	$str1=~s/\s+//g;
	next if $str1 eq "";
	next if $kmer_mode and length($str1) != $k;     # skip tail truncations
	for(my $c2=$c1+1;$c2<=$#reads;$c2++){
		my $str2=$reads[$c2];
		chomp $str2;
		my $len2=length($str2);
		$str2=~s/\s+//g;
		next if $str2 eq "" or $str2 eq $str1;
		next if $kmer_mode and length($str2) != $k;
		if($kmer_mode){
			# original logic: LCS must be exactly k-1
			my @ovl=overlap($str1,$str2);
			my $lenovl=length($ovl[0]);
			if($lenovl==($len2-1)){
				print "$str1\t$len1\t$str2\t$len2\t@ovl\t$lenovl\n";
				$ovlidx{$str1}=$str2;
			}
		} else {
			# peptide mode: directed sfx_pfx, both directions
			for my $pair ([$str1,$str2,$len1,$len2],[$str2,$str1,$len2,$len1]) {
				my ($a,$b,$la,$lb)=@$pair;
				my $n=sfx_pfx($a,$b);
				if($n>0){
					print "$a\t$la\t$b\t$lb\toverlap=$n\n";
					$ovlidx{$a}=$b
						if !exists $ovlidx{$a} or sfx_pfx($a,$ovlidx{$a})<$n;
				}
			}
		}
	}
}

# OLC: walk %ovlidx chains to produce contigs
my %is_succ = map { $_ => 1 } values %ovlidx;
my @olc_starts = grep { !$is_succ{$_} } keys %ovlidx;
my @olc_contigs;
for my $start (@olc_starts) {
	my ($cur,$seq,%seen)=($start,$start,($start=>1));
	while(exists $ovlidx{$cur} and !$seen{$ovlidx{$cur}}){
		my $nxt=$ovlidx{$cur};
		my $n=$kmer_mode ? $k-1 : sfx_pfx($cur,$nxt);
		$seq.=substr($nxt,$n);
		$seen{$nxt}=1; $cur=$nxt;
	}
	push @olc_contigs,$seq;
}

# peptide mode only: also emit isolated strings (no overlap with anything)
unless($kmer_mode){
	my %in_olc=map{$_=>1}(keys %ovlidx, values %ovlidx);
	for my $r (@reads){
		my $s=$r; chomp $s; $s=~s/\s+//g;
		push @olc_contigs,$s if $s ne "" and !$in_olc{$s};
	}
}

@olc_contigs=sort{length($b)<=>length($a)}@olc_contigs;
print "\n--- OLC: ",scalar @olc_contigs," contig(s) ---\n";
for my $i (0..$#olc_contigs){
	printf ">contig_%d  len=%d\n%s\n",$i+1,length($olc_contigs[$i]),$olc_contigs[$i];
}

# De Bruijn: weakly connected components then Hierholzer per component
my (%und,%vis,@comps);
for my $u (keys %dbadj){
	for my $v (@{$dbadj{$u}}){ push @{$und{$u}},$v; push @{$und{$v}},$u }
}
my %all_nodes=map{$_=>1}(keys %dbadj, map{@{$dbadj{$_}}}keys %dbadj);
for my $n (keys %all_nodes){
	next if $vis{$n};
	my (@comp,@q); push @q,$n; $vis{$n}=1;
	while(@q){
		my $c=shift @q; push @comp,$c;
		push @q, grep{!$vis{$_}++}@{$und{$c}//[]};
	}
	push @comps,\@comp;
}
my %adj_copy;
for my $u (keys %dbadj){ $adj_copy{$u}=[@{$dbadj{$u}}] }
my @dbg_contigs;
for my $comp (@comps){
	my $start=(grep{($out_deg{$_}//0)-($in_deg{$_}//0)==1}@$comp)[0]
	          //(grep{($out_deg{$_}//0)>0}@$comp)[0];
	next unless defined $start;
	my(@stack,@path); push @stack,$start;
	while(@stack){
		my $v=$stack[-1];
		if(@{$adj_copy{$v}//[]}){ push @stack,pop @{$adj_copy{$v}} }
		else                     { push @path, pop @stack             }
	}
	@path=reverse @path;
	push @dbg_contigs,$path[0].join("",map{substr($_,-1)}@path[1..$#path]);
}
@dbg_contigs=sort{length($b)<=>length($a)}@dbg_contigs;
print "\n--- De Bruijn (tile_k=$tile_k): ",scalar @dbg_contigs," contig(s) ---\n";
for my $i (0..$#dbg_contigs){
	printf ">contig_%d  len=%d\n%s\n",$i+1,length($dbg_contigs[$i]),$dbg_contigs[$i];
}

sub sfx_pfx {
	my ($a,$b)=@_;
	my $max=(length($a)<length($b))?length($a):length($b);
	for my $n (reverse 1..$max){
		return $n if substr($a,-$n) eq substr($b,0,$n);
	}
	return 0;
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
perl overlap.pl peplist.txt 

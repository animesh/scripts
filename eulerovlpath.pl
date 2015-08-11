use strict;

my @reads=<>;
my %ovlidx;
for(my $c1=0;$c1<=$#reads;$c1++){
	my $str1=$reads[$c1];
	chomp $str1;
	my $len1=length($str1);
	$str1=~s/\s+//g;
	for(my $c2=$c1+1;$c2<=$#reads;$c2++){
		my $str2=$reads[$c2];
		chomp $str2;
		my $len2=length($str2);
		$str2=~s/\s+//g;
		if($str2 ne $str1 and $str1 ne "" and $str2 ne "" and $len1 == $len2){
			my @ovl=overlap($str1,$str2);
			my $lenovl=length($ovl[0]);
			if($lenovl and ($len2-1) and $lenovl == ($len2-1)){
				push(@{$ovlidx{substr($ovl[0],1,$lenovl-1).substr($str2,$lenovl,1)}},$ovl[0]);				
				push(@{$ovlidx{$ovl[0]}},substr($str1,0,$lenovl-1).substr($ovl[0],$lenovl-2,1));
			}
		}
	}
}

#Call Euler sub and pick the last base from subsequent overlap
my @path=eulerPath(%ovlidx);
for(my $c=1;$c<=$#path;$c++){$path[0].=substr($path[$c],length($path[$c])-1,1);}
print "$path[0]\n";

#source http://en.wikibooks.org/wiki/Algorithm_implementation/Strings/Longest_common_substring#Perl
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
			#prini "$str1\t$len1\t$str2\t$len2\t@ovl\t$lenovl\n";
        }
        if ($lc_suffix[$n1][$n2] == $l_length) {
          push @substrings, substr($str1, ($n1-$l_length), $l_length);
        }
      }
    }
  }   
 
  return @substrings;
}

#source http://stackoverflow.com/questions/4031325/finding-eulerian-path-in-perl

sub eulerPath {
    my %graph = @_;
    my @odd = ();
    foreach my $vert ( sort keys %graph ) {
        my @edg = @{ $graph{$vert} };
        my $size = scalar(@edg);
        if ( $size % 2 != 0 ) {
            push @odd, $vert;
        }
    }
    push @odd, ( keys %graph )[0];
    if ( scalar(@odd) > 3 ) {
        return "None";
    }
    my @stack = ( $odd[0] );
    my @path  = ();
    while (@stack) {
        my $v = $stack[-1];
        #suggestion http://stackoverflow.com/a/4031608
        if ( @{$graph{$v}} ) {
                my $u = ( @{ $graph{$v} } )[0];
                push @stack, $u;
              # Find index of vertice v in graph{$u}
            my @graphu = @{ $graph{$u} };  # This is line 54.
            my ($index) = grep $graphu[$_] eq $v, 0 .. $#graphu;
            #suggestion http://stackoverflow.com/a/4031608
            splice @{ $graph{$u} }, $index, 1;
            splice @{ $graph{$v} }, 0, 1;
        }
        else {
            push @path, pop(@stack);
        }
    }
    return @path;
}


__END__
perl -e '@b=qw/A T G C/;print ">RandGenomeL1000\n";while($l<1000){print @b[int(rand(4))];$l++;}' > rangen.txt
perl -ne 'if ($p) { for($c=0;$c<length;$c++){print substr($_,$c,10);print "\n"}; $p = 0 } $p++ if />/' rangen.txt  > rangen.txt.kmer
perl eulerovlpath.pl rangen.txt.kmer 


#!/usr/local/bin/perl
use Getopt::Std;
package NW;

$| = 1;

sub new
{
    my($package, $a, $b, $payoff, %options) = @_;
    print "NW::new" if $options{v};
    $a = ['', split //, $a];
    $b = ['', split //, $b];
    my $rows = @$a;
    my $cols = @$b;
    my $lp;
    for ($row=0; $row<$rows; $row++)
    {
	print "." if $options{v};
	for (my $col=0; $col<$cols; $col++)
	{
	    my $cell = { row   => $row,
			 col   => $col,
		         score => 0   };

	    $lp->[$row][$col] = $cell;
	}
    }
    print "\n" if $options{v};

    my $nw = { a       => $a,
	       b       => $b,
	       rows    => $rows,
	       cols    => $cols,
	       lp      => $lp,
	       payoff  => $payoff,
	       options => \%options };

    bless $nw, $package
}


sub score
{
    my $nw      = shift;
    my $lp      = $nw->{lp};
    my $a       = $nw->{a};
    my $b       = $nw->{b};
    my $options = $nw->{options};

    my $rows = @$a;
    my $cols = @$b;

    my $payoff   = $nw->{payoff};
    my $match    = $payoff->{match};
    my $mismatch = $payoff->{mismatch};
    my $open     = $payoff->{open};
    my $extend   = $payoff->{extend};

    print "NW::score" if $options->{v};

    for (my $row=1; $row<$rows; $row++)
    {
	print "." if $options->{v};
	my $a1 = $a->[$row];
	for (my $col=1; $col<$cols; $col++)
	{
	    my $cell = $lp->[$row][$col];

	    my $b1 = $b->[$col];
	    my $compare = $a1 eq $b1 ? $match : $mismatch;
	    my $prev = $lp->[$row-1][$col-1];
	    $cell->{score} = $prev->{score} + $compare;
	    $cell->{prev}  = $prev;

	    for (my $r=0; $r<$row; $r++)
	    {
		my $prev  = $lp->[$r][$col];
		my $score = $prev->{score} + $open + $extend * ($row-$r);
		$score < $cell->{score} and next;
		$cell->{score} = $score;
		$cell->{prev}  = $prev;
	    }

	    for (my $c=0; $c<$col; $c++)
	    {
		my $prev  = $lp->[$row][$c];
		my $score = $prev->{score} + $open + $extend * ($col-$c);
		$score < $cell->{score} and next;
		$cell->{score} = $score;
		$cell->{prev}  = $prev;
	    }
	}
    }

    print "\n\n" if $options->{v};
}


sub dump_score
{
    my $nw = shift;
    my $a  = $nw->{a};
    my $b  = $nw->{b};
    my $lp = $nw->{lp};

    my @b = join('   ', @$b);
    print " @b\n";

    my $rows = @$a;
    my $cols = @$b;

    for (my $row=1; $row<$rows; $row++)
    {
	my $a1 = $a ->[$row];
	my $r1 = $lp->[$row];
	my @s1 = map { sprintf "%3d", $_->{score} } @$r1;
	shift @s1;
	print "$a1 @s1\n";
    }

    print "\n";
}


sub align
{
    my $nw = shift;

    $nw->{align} = { a => [],
		     s => [],
		     b => [] };

    my $cell = $nw->max_cell;
               $nw->{score} = $cell->{score};

	       $nw->align_tail($cell);
       $cell = $nw->align_body($cell);
    	       $nw->align_head($cell);

	       $nw->join_align;
}


sub get_score
{
    my $nw = shift;
    $nw->{score}
}


sub max(&@)
{
    my $less = shift;
    my $max  = shift;

    &$less($max, $_) and $max = $_  for (@_);

    $max
}


sub max_cell
{
    my $nw  = shift;
    my $lp  = $nw->{lp};

    my $rows = $nw->{rows};
    my $cols = $nw->{cols};

    my @right  = map { $lp->[$_][-1] } 1..$rows-1;
    my @bottom = map { $lp->[-1][$_] } 1..$cols-1;

    max { $_[0]->{score} < $_[1]->{score} } @right, @bottom
}


sub align_tail
{
    my($nw, $cell) = @_;

    my $a = $nw->{a};
    my $b = $nw->{b};

    my $row = $cell->{row};
    my $col = $cell->{col};

    my @a = @$a[$row+1..$#$a];
    my @s = ();
    my @b = @$b[$col+1..$#$b];
    
    $nw->unshift_align(\@a, \@s, \@b);
}


sub align_body
{
    my($nw, $cell) = @_;

    my $lp = $nw->{lp};
    my $a  = $nw->{a};
    my $b  = $nw->{b};
 
    my(@a, @s, @b);

    for (;;)
    {	
	my $row = $cell->{row};
	my $col = $cell->{col};
	$row and $col or last;

	my $prev = $cell->{prev};

	if ($prev->{row} < $row and $prev->{col} < $col)
	{
	    my $a1 = $a->[$row];
	    my $b1 = $b->[$col];
	    unshift @a, $a1;
	    unshift @s, $a1 eq $b1 ? '|' : ' ';
	    unshift @b, $b1;
	}
	elsif ($prev->{row} < $row)
	{
	    my $gap = $row - $prev->{row};
	    unshift @a, @$a[$row-$gap+1..$row];
	    unshift @s, ' ' x $gap;
	    unshift @b, '.' x $gap;
	}
	else
	{
	    my $gap = $col - $prev->{col};
	    unshift @a, '.' x $gap;
	    unshift @s, ' ' x $gap;
	    unshift @b, @$b[$col-$gap+1..$col];
	}

	$cell = $prev;
    }

    $nw->unshift_align(\@a, \@s, \@b);
    $cell
}


sub align_head
{
    my($nw, $cell) = @_;

    my $a  = $nw->{a};
    my $b  = $nw->{b};

    my $row = $cell->{row};
    my $col = $cell->{col};
    my $max = max { $_[0] < $_[1] } $row, $col;

    my @a = (' ' x $col, @$a[1..$row]);
    my @s = (' ' x $max		     );
    my @b = (' ' x $row, @$b[1..$col]);

    $nw->unshift_align(\@a, \@s, \@b);
}


sub unshift_align
{
    my($nw, $a, $s, $b) = @_;
    my $align = $nw->{align};

    unshift @{$align->{a}}, @$a;
    unshift @{$align->{s}}, @$s;
    unshift @{$align->{b}}, @$b;
}


sub join_align
{
    my $nw = shift;
    my $align = $nw->{align};

    for my $key (keys %$align)
    {
	my $x = $nw->{align}{$key};
	$nw->{align}{$key} = join('', @$x);
    }
}    


sub print_align
{
    my $nw = shift;
    my $align = $nw->{align};
    my $a = $align->{a};
    my $s = $align->{s};
    my $b = $align->{b};
    my $lineLen = 60;

    $a =~ tr[ -~][^]c;
    $b =~ tr[ -~][^]c;

    for (my $i=0; $i<length($a); $i+=$lineLen)
    {
	print substr($a, $i, $lineLen), "\n";
	print substr($s, $i, $lineLen), "\n";
	print substr($b, $i, $lineLen), "\n";
	print "\n";
    }
}


#########################################################################
package main;

my @Tests = ( [qw(abcde 		abcde)		],
	      [qw(abcdefgh 		abcxefgh)	],
	      [qw(abcdefgh 	       	bcdefghi)	],
	      [qw(abcdefghijklmnopqrst 	abcdijklqrst)	],
	      [qw(cgatcaaacaaccgat     	cgatcaaccgat)	] 
	     );

my $Payoff = { match    =>  1,
	       mismatch => -1,
	       open     => -1,
	       extend   => -1 };


my %Options;
getopt('p', \%Options);

$Options{t} and Test(), exit;

$Options{p} and $Payoff = ParsePayoff($Options{p});

my($File1, $File2) = @ARGV;
$File2 or die "align [-a] [-p m,m,o,e] [-s] [-t] [-v] File1 File2\n";
AlignFiles($File1, $File2, $Payoff);


sub Test
{
    $Options{a} = 1;
    for my $test (@Tests)
    {
	AlignStrings(@$test, $Payoff);
    }
}


sub ParsePayoff
{
    my $payoff = shift;
    my @payoff = split /,/, $payoff;
    my @keys   = qw(match mismatch open extend);

    + { map { $keys[$_] => $payoff[$_] } 0..3 }
}


sub AlignFiles
{
    my($fileA, $fileB, $payoff) = @_;

    my $a = Slurp($fileA);
    my $b = Slurp($fileB);

    my $start = time;
    AlignStrings($a, $b, $payoff);
    my $end = time;
    print $end-$start, " seconds\n" if $Options{v};
}


sub Slurp
{
    my $file = shift;
    open(FILE, $file) or die "Can't open $file: $!\n";
    local $/;
    undef $/;
    <FILE>
}


sub AlignStrings
{
    my($a, $b, $payoff) = @_;
    my $nw = new NW $a, $b, $payoff, %Options;

    $nw->score;
    $nw->align;

    my $score = $nw->get_score;
    print "Score $score\n";

    $nw->print_align if $Options{a};
    $nw->dump_score  if $Options{s};
}

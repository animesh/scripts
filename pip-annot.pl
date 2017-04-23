#!/usr/local/bin/perl
# compile annotations to lav input.

use 5.006_000;
use warnings;
use strict;
use diagnostics;


use fields;
use Getopt::Std;
use Class::Struct qw(struct);
use Data::Dumper;

# -----
package main;

my $emit;

sub quote_for_ps {
    die unless (@_);
    for (@_) {
        $_ ||= "";
        s/[[:space:]]/ /g;
        s/[^[:print:]]/_/g;
        s/([[:punct:]])/\\$1/g;
    }
    return @_;
}

sub quote_harshly {
    for (@_) {
        $_ ||= "";
        s/[^[:alnum:]]/_/g;
    }
    return @_;
}

# -----

package emit;
use strict;
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};
    bless ($self, $class);
    return $self;
}
sub start { }
sub end { }
sub emit { }
sub quote { }
1;

package emit_roff;
#use emit;
use strict;
@emit_roff::ISA=("emit");

sub start {
    #" range: 40 1010
    #" color: rgb 0.5 0.5 0.5
    #" desc: some string \\\!\@\#\$\%\^\&\*\(\)\"
    #" url: http\:\/\/some url\/foo\`bar\~\!baz
    #" row: 0
    print <<'END';
.\" --- initialize the dictionary ---"
.if !\n(.g .ab These ms macros require groff.
.de pdf*init
\X'ps: def /YMAX \\n(.p u def'\
\X'ps: def /rect [0 0 0 0] def'\
\X'ps: def /url () def /x 0 def /y 0 def /dx 0 def /st 0 def /sb 0 def'\
\X'ps: def /pdf-dest-thispage { 1 dict begin /dest exch def'\
\X'ps: def  [/Dest dest /View [/FitH YMAX] /DEST pdfmark end }def'\
\X'ps: def /pdf-rect-def {'\
\X'ps: def  currentpoint /y exch def /x exch def'\
\X'ps: def  /dx exch u def /sb exch u def /st exch u def /b exch u def'\
\X'ps: def  /rect [x y   x dx add   y st add sb sub] def }def'\
\X'ps: def /pdf-url {'\
\X'ps: def  /url exch def'\
\X'ps: def  [/Rect rect/Border [0 0 0]/Color [0 0 1]'\
\X'ps: def   /Action <</Subtype/URI/URI url>>'\
\X'ps: def   /Subtype /Link /ANN pdfmark }def'
..
.de pdf*dest*thispage
\X'ps: exec (\\$1) cvn pdf-dest-thispage'
..
.\" --- pdfmark a word ($1) with a url ($2) ---"
.de pdf*url
.nr ps*dx \w'\\$1'u
.nr ps*sb \\n[rsb]u
.nr ps*st \\n[rst]u
.nr ps*b  \\n(.vu/10u
\X'ps: exec \\n[ps*b] \\n[ps*sb] \\n[ps*st] \\n[ps*dx] pdf-rect-def'\
\X'ps: exec (\\$2) pdf-url'\\$1
..
.\" ---start annot"
.de (pA
.na
.in \w'XX'u
.ti -\w'XX'u
..
.\" ---annot dest"
.de pAdest
.pdf*dest*thispage "annot.\\$1"
..
.\" ---annot label"
.de pAlabel
\(bu \\$1\ \\$2 (\\$3;\ \\$4)
..
.\" ---annot url"
.de pAurl
.pdf*url " \(rh" "\\$1"
..
.\" ---annot text"
.de pAtext
.ad b
.in
.br
\&\\$1
..
.\" ---end annot"
.de pA)
.bp
..
.\" --- Defaults ---"
.ps 16
.vs 18
.pdf*init
END
}

sub emit {
    my $self = shift;
    die unless (@_);

    my ($a,$b,$c,$t,$l,$r,$n,$su) = @_;
    
    # these might be optional, so don't be undef.
    $l ||= ""; $su ||= [];
    $su = [{key=>"summary",val=>$l}] if $l && !@$su;

    #print main::Dumper($a,$b,$c,$t,$l,$r,$n,$su),"\n";

    print  ".(pA\n";
    printf '.pAdest "%s"%s', $n, "\n";
    printf '.pAlabel "%d" "%d" "%d" "%s"%s', $a, $b, $r, $t, "\n";

    for my $x (@{$su}) {
        if (${$x}{key} eq "summary") {
            printf('.pAtext "%s"%s', $x->{val}, "\n");
        } elsif (${$x}{key} eq "url") {
            printf('.pAurl "%s"%s', $x->{val}, "\n");
        }
    }
    print  ".pA)\n";
}

sub quote # troff style
{
    my $self = shift;
    die unless (@_);
    for (@_) {
	$_ ||= "";
	s/[^[:print:]]/_/g;
	s/\\/\\e/g;
	s/"/\\N'034'/g;
    }
    return @_;
}

1;

package emit_pip;
#use emit;
use strict;
@emit_pip::ISA=("emit");

sub start {
}

sub emit {
    my $self = shift;
    die unless (@_);

    my ($a,$b,$c,$t,$l,$r,$n,$su) = @_;
    printf "%d %d %d %d %s (%s) bkmrk-nannot-link\n", $a, $b, $r, $n, $c, $l;
}

sub quote {
    my $self = shift;
    return main::quote_for_ps @_;
}

1;

package emit_bookmark;
#use emit;
use strict;
@emit_bookmark::ISA=("emit");

sub start {
    my $self = shift;
    my $n = shift;
    printf("[/Title (annotations) /Count %d /OUT pdfmark\n", $n) if $n != 0;
}

sub emit {
    my $self = shift;
    die unless (@_);

    my ($a,$b,$c,$t,$l,$r,$n,$su) = @_;
    my $title = substr($l,0,70);
    $title =~ s|\\+$||g; # aaa\x => aaa\ => aaa
    printf "[/Title (%s) /Dest (%s) cvn /OUT pdfmark\n", $title, $l;
}

sub quote {
    my $self = shift;
    return main::quote_for_ps @_;
}

1;

# -------

package emit_legend;
#use emit;
use strict;
@emit_legend::ISA=("emit");

sub start {
    my $self = shift;
    my $n = shift;
    #print "[/Title (annotations legend) /OUT pdfmark\n";
}

sub emit {
    my $self = shift;
    die unless (@_);

    my ($a,$b,$c,$t,$l,$r,$n,$su) = @_;
}

sub quote {
    my $self = shift;
    return main::quote_for_ps @_;
}

sub end {
    my $self = shift;
    # die unless (@_);
    my %C = @_;

    my ($key,$value);
    while (($key,$value) = each %C) {
	main::quote_harshly $key;
	main::quote_harshly $value;
	print "$key $value\n";
    }
}

1;

# -----

package main;

my $A = $0; $A =~ s:.*/::;

# XXX - should read a standard table from somewhere!!
my @valid_colors = (
    "Black",
    "White",
    "Gray", "LightGray", "DarkGray",
    "Red", "LightRed", "DarkRed",
    "Green", "LightGreen", "DarkGreen",
    "Blue", "LightBlue", "DarkBlue",
    "Yellow", "LightYellow", "DarkYellow",
    "Pink", "LightPink", "DarkPink",
    "Cyan", "LightCyan", "DarkCyan",
    "Purple", "LightPurple", "DarkPurple",
    "Orange", "LightOrange", "DarkOrange",
    "rgb",
);

my %Colors;
my @Annots;

sub add_annot
{
  #print Dumper(@_), "\n";
  my($a,$b,$c,$t,$l,$n,$su) = @_;
  push @Annots, fields::phash([qw(a b c t l n su r)], [@_,0]);
}

sub intrsct
{
  my ($a0,$a1, $b0,$b1) = @_;
  return ($b1 >= $a0) && ($a1 >= $b0);
}

sub qsulist
{
    my @FF=@_;
    my @F=();
    while (@FF) {
	my $key = shift @FF;
	my $val = shift @FF;
	$emit->quote($val);
        if ($key =~ /summary|url/) {
            push(@F, {key=>$key,val=>$val});
        }
    }
    return \@F;
}

# -- main --

our $opt_t = "";
our $opt_p = "";
our $opt_b = "";
our $opt_l = "";
our $opt_T = "";
getopts("bptl") or die;

if ($opt_t) {
    $emit = new emit_roff;
} elsif ($opt_T) {
    $emit = new emit_roff2;
} elsif ($opt_b) {
    $emit = new emit_bookmark;
} elsif ($opt_p) {
    $emit = new emit_pip;
} elsif ($opt_l) {
    $emit = new emit_legend;
} else {
    $emit = new emit_pip;
}

my $n = 0;
$/ = '';
while (<>) {
    s/^\s*#.*$//mg; # delete comments
    s/\s*$//mg;	    # delete trailing spaces
    s/^\n*//;	    # delete blank lines
    s/\n([^%])/$1/g;    # fix continuation lines
    if (!/^$/) {
	my @F = split /\n*%(\w+)\s+/m;
	shift @F if $F[0] eq "";

	die "$A: missing key/value element near stanza $.:\n$_\n"
	    if ($#F%2) == 0;

	my %K = @F;

	my $t = $K{define};
	die "$A: undefined define near {$F[0] $F[1]} in stanza $.\n"
	     unless defined $t;
	if ($t eq "type") {
	    die "$A: undefined type name in stanza $.\n"
		 unless defined $K{name};
	    if (defined $K{rgb} &&
		$K{rgb} =~ /(\d+(\.\d+)?)\s+(\d+(\.\d+)?)\s+(\d+(\.\d+)?)/) {
		    $Colors{$K{name}} = "$1 $3 $5 setrgbcolor";
	    } elsif (defined $K{color} && grep($K{color} eq $_, @valid_colors)) {
		$Colors{$K{name}} = $K{color};
	    } else {
		die "$A: unknown color ``" . ($K{color} || $K{rgb} || "") . "''" .
		    "in stanza $.\n";
	    }
	} elsif ($t eq "annotation") {
	    my $range = $K{range} || "";
            die "$A: bad range {$range} in stanza $.\n"
		 unless ($range =~ /^(\d+)\s+(\d+)$/);
            my $x1 = $1;
            my $x2 = $2;
	    my $type = $K{type} || "";
	    die "$A: unknown type {$type} in stanza $.\n"
		unless grep($type =~ /^$_$/, keys %Colors);
            my $c = $Colors{$type};
	    my $label = $K{label} || "";
	    my $su = qsulist(@F);
	    $emit->quote($c,$type,$label);
            add_annot($x1,$x2,$c,$type,$label,$n++,$su);
        } else {
            die "$A: unknown annotation type ``$t'' in ``$_'', stanza $.\n";
        }
    }
}

# sort by length of interval
my @A = sort { ($b->{b} - $b->{a}) <=> ($a->{b} - $a->{a}) } @Annots;

A: for my $a (0..$#A) {
    my $r = 0;
    R: for $r (0..$a) {
	my $ok = 1;
	B: for my $b (0..$a-1) {
	    if (intrsct($A[$a]{a}, $A[$a]{b}, $A[$b]{a}, $A[$b]{b})) {
		if ($A[$b]{r} == $r) {
		    $ok = 0;
		}
	    }
	}
	if ($ok) {
	    $A[$a]{r} = $r;
	    last R;
	}
    }
}

$emit->start($#A+1);
my $maxr = 0;
for my $f (sort { $a->{a} - $b->{a} } @A) {
    $maxr = $f->{r} if $f->{r} > $maxr;
    $emit->emit($f->{a}, $f->{b}, $f->{c},
		$f->{t}, $f->{l}, $f->{r}, $f->{n},
		$f->{su});
}
$emit->end(%Colors);

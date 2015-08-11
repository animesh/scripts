#!/usr/bin/perl
#
# This perl script converts the Greek hyphenation patterns for the
# cbgreek encodings to the encoding used by the Ibycus greek font.
#
# Copyright Peter Heslin 2003.
#
# Usage: perl ibyhyph.pl < grhyph.tex > ibyhyph.tex
#
use strict;
my %seen;
my ($f, $p);

my $preamble = << 'END';
\message{Greek hyphenation patterns for Ibycus 4}
% This file was mechanically translated from a set of patterns
% for the standard greek encoding using the perl script ibyhyph.pl
\begingroup
\ifx\eTeXversion\undefined\message{not using eTeX}\else\savinghyphcodes=1\fi
\lccode`(=`( \lccode`)=`) \lccode``=``
\lccode `'=`' \lccode`==`= \lccode`+=`+
\lccode `|=`|
END

print $preamble;

my $v = '[aeiouhwr]';           # vowels plus rho
my $a = '[<>\'`~"|]';           # accents

# Will break if patterns begin on the same line
while(<>) {last if m/\\patterns{%/}
print "\\patterns{%\n";

LINE:
while (<>)
{
    last if m/^}/;
    if (m/^%/)
    {
        print $_;
        next;
    }

    for $p (split)
    {
        next LINE if $p =~ m/%/;
        #print STDERR "$p\n";
        $p =~ s/''(\s|$)/'.$1/g;                # apostrophe (at end of word)
        $p =~ s/(\s|^)''/.'/g;                 # apostrophe (at start)
        
        $p =~ s/\b\w*v\w*\b//g;           # get rid of patterns with v
        $p =~ s/<($a*)($v)/$2($1/g;      # move and change breathings
        $p =~ s/>($a*)($v)/$2)$1/g;      # move and change breathings
        $p =~ s/($a+)($v)/$2$1/g;        # move accents
        
        $p =~ s/~/=/g;                    # change circumflex
        $p =~ s/"/+/g;                    # change diaresis

        $p =~ tr/jxqc/qcxj/;              # change theta, xi, chi, final sigma

            # odd bits
        $p =~ s/<(\d)($v)/$2$1(/g;
        $p =~ s/>(\d)($v)/$2$1)/g;

        # This is a trick Ibycus can't use: breaking right after the vowel
        $p =~ s/^($v+)1$/${1}1 ${1}2'1 ${1}2`1 ${1}2=1 ${1}2)1 ${1}2)2'1 ${1}2)2`1 ${1}2)2=1 ${1}2(1 ${1}2(2'1 ${1}2(2`1 ${1}2(2=1 ${1}2+1 ${1}2+2'1 ${1}2+2`1/g;

        # iota subscript follows accents as well as vowels
        $p =~ s/$v(\d)\|(\d)/$1|$2/g;

        $p =~ s/r\d$a//g;
        $p =~ s/\w*\^\^\w*//g;

        # If we fold c and s, it causes duplicates
        next if $seen{$p};
        $seen{$p}++;
      
        #print STDERR "$p\n\n";
        
        print "$p\n" unless $p =~ m/^\s*$/;
    }

}

print "}\n\\endgroup\n\\endinput\n";

# end

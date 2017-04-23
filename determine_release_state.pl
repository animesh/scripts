#!/usr/bin/perl -w

use strict;

# This is the version in configure.ac:
my $official_version = $ARGV[0];

my $state = "unknown";
my $last_change = `darcs changes --last 1`;
if ($last_change =~ /tagged (1\..+[^0-9])(\d+)$/ &&
    "$1$2" eq $official_version) {
  my $n = $2;
  if ($1 =~ /pre$/) {
    $state = "prerelease $n";
  } elsif ($1 =~ /rc$/) {
    $state = "release candidate $n";
  } elsif ($1 =~ /\d$/ || $1 =~ /\.$/) {
    $state = "release";
  } else {
    $state = "tag $1$n";
  }
} else {
  my $lastrepo = $ENV{PWD};
  if (-f "_darcs/prefs/defaultrepo") {
    $lastrepo = `cat _darcs/prefs/defaultrepo`;
  }
  if ($lastrepo =~ /darcs-unstable/) {
    $state = "unstable branch";
  } elsif ($lastrepo =~ /abridgegame\.org.+darcs$|darcs\.net:.+darcs$/) {
    $state = "stable branch";
  }
}

print $state;

if (open(FIN,"ThisVersion.lhs.in") && open(FOUT,">ThisVersion.lhs.tmp")) {
  while (<FIN>) {
    s/\@DARCS_VERSION_STATE\@/$state/g;
    s/\@DARCS_VERSION\@/$official_version/g;
    print FOUT $_;
  }
  close(FIN);
  close(FOUT);
}

my $replace = 1;
if (open(FIN,"ThisVersion.lhs") && open(FTMP,"ThisVersion.lhs.tmp")) {
  my ($old, $new);
  read FIN, $old, 10000;
  read FTMP, $new, 10000;
  $replace = $old ne $new;
  close(FIN);
  close(FTMP);
}

if ($replace) {
  rename "ThisVersion.lhs.tmp", "ThisVersion.lhs";
} else {
  unlink "ThisVersion.lhs.tmp";
}


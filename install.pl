#!/usr/bin/perl -w

use strict;
use File::Copy 'copy';
use IO::Dir;

my $source = shift or exit 0;
my $dest   = shift or exit 0;

die "$source is not a directory" unless -d $source;
die "$dest is not a directory"   unless -d $dest;

copy_tree($source,'.',$dest);

sub copy_tree {
  my ($base,$subdir,$dest) = @_;
  -d "$dest/$subdir" || mkdir("$dest/$subdir",0777);

  my $dir = IO::Dir->new("$base/$subdir") or die "Can't opendir() $source: $!";
  while (my $thing = $dir->read) {

    next if $thing =~ /^\./;    # not hidden files
    next if $thing =~ /^\#/;   # not autosave files
    next if $thing =~ /~$/;    # not autosave files
    next if $thing eq 'CVS';   # not CVS directories
    next if $thing eq 'core';  # not core files

    if (-f "$base/$subdir/$thing") { # a regular file
      my $result = copy("$base/$subdir/$thing","$dest/$subdir/$thing");
      if ($result) {
	my $mode = (stat("$base/$subdir/$thing"))[2];
	chmod $mode,"$dest/$subdir/$thing";
      }
      print STDERR $result ? "OK:    " : "FAILED: ","$base/$subdir/$thing => $dest/$subdir/$thing\n",
    } elsif (-d "$base/$subdir/$thing") {
      copy_tree($base,"$subdir/$thing",$dest);
    }

  }
}

__END__

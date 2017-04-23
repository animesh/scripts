#!/usr/bin/perl

use 5.005;
use strict;

use Carp;
use Cwd 'chdir';
use File::Basename;

use lib dirname($0);
require "config.pl";

umask 002;

croak "no write access to $CFG::CgiDN"
  unless( -d $CFG::CgiDN && -r _ && -w _ && -x _);

croak "no write access to $CFG::HtdocRootDN"
  unless( -d $CFG::HtdocRootDN && -r _ && -w _ && -x _);

chdir dirname($0);

qx!tar -C cgi-bin -c . | tar -C $CFG::CgiDN -xf - !, $? && exit($?);
qx!tar -c mysqler_img | tar -C $CFG::HtdocRootDN -xf - !, $? && exit($?);
qx!cp ../perlib/PerfLogIterator.pm $CFG::CgiDN !, $? && exit($?);

print "cgi script and supporting files have been installed\n";

exit(0);

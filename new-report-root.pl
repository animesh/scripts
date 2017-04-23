#!/usr/bin/perl

use 5.005;
use strict;

use Carp;
use File::Basename;
use File::Path;

use lib dirname($0);
require "config.pl";

umask 002;

$ARGV[0] || croak "usage: ",basename($0), " myserver.mycompany.com";

croak "no access to $CFG::ArchiverDN"
  unless( -d $CFG::ArchiverDN && -r _ && -w _ && -x _);

$CFG::ArchiverDN .= "/" if( substr($CFG::ArchiverDN,-1,1) ne "/");
mkpath( $CFG::ArchiverDN . $ARGV[0] . "/graphs", 1, 0755);

exit(0);

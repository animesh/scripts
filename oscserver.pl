#!/usr/bin/perl

use strict;
use warnings;
use Audio::OSC::Server;

use Data::Dumper qw(Dumper);

sub dumpmsg {
    print "[$_[0]] ", Dumper $_[1];
}

my $server = Audio::OSC::Server->new(Port => 7777, Handler => \&dumpmsg) or
    die "Could not start server: $@\n";

print "[OSC Client] Receiving messages on port 7777";

$server->readloop();


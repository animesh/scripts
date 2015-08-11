#!/usr/bin/env perl
use warnings;
use strict;

=head1 INTRODUCTION

Checks if there are new unread messages in your GMail Inbox.

=head1 USAGE

    $ perl check_gmail.pl
    1       Swaroop C H     Looks like check_gmail.pl works

=cut

############## Configuration ##############

# Change this to your correct username.
use constant GMAIL_USERNAME => "sharma.animesh";
# Change this to your correct password.
use constant GMAIL_PASSWORD => "password";

########## Don't change anything below this. ##########

use LWP::UserAgent;
use XML::Atom::Feed;

my $fetcher = LWP::UserAgent->new();
$fetcher->agent("check_gmail.pl/0.01");

my $request = HTTP::Request->new(
    'GET'   => "https://mail.google.com/gmail/feed/atom",
);
$request->authorization_basic(GMAIL_USERNAME, GMAIL_PASSWORD);

my $response = $fetcher->request($request);

if (! $response->is_success())
{
    die("Unsuccessful in trying to talk to GMail");
}

my $content = $response->content;
my $feed = XML::Atom::Feed->new(\$content);
my @new_messages = $feed->entries();

my $i = 1;
foreach my $message(@new_messages)
{
    print join("\t", $i, $message->author->name,
                    $message->title), "\n";
    $i++;
}

# The End



#!/usr/bin/perl
# check_gmail.pl     krishna_bhakt@BHAKTI-YOGA     2006/09/05 07:00:07

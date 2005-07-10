#!/usr/bin/perl -w

#####################
# friendanalysis.pl #
##########################################################################
# Copyright 2005 Ben Bleything <ben@bleything.net>                       #
# Distributed under the BSD license.                                     #
#                                                                        #
# Please see the README for more information.                            #
##########################################################################

use strict;
use GDBM_File;
use Term::ReadKey;
use Digest::MD5 qw(md5_hex);
use XMLRPC::Lite;

# OPTIONS
my $server = "www.livejournal.com";

# SANITY
die("Usage: $0 <journal name>\n") unless defined $ARGV[0];
my $journal = $ARGV[0];

# Create the xmlrpc object
my $xmlrpc = new XMLRPC::Lite;
$xmlrpc->proxy("http://$server/interface/xmlrpc");

# Get the password
my $pwd = get_pass();
my %groups = get_groups($journal, $pwd);

# Open up the jbackup dump... or don't.
tie my %db, 'GDBM_File', "$journal.jbak", &GDBM_READER, 0600 or die "Could not open/tie $journal.jbak $!\n";

my %posts;
# GO TO TOWN
foreach my $jitemid (split /,/, $db{'event:ids'}) {
    next unless (defined $db{"event:security:$jitemid"} && $db{"event:security:$jitemid"} eq "usemask");

    my $group = defined $db{"event:allowmask:$jitemid"} ? $groups{$db{"event:allowmask:$jitemid"}} : "GROUP DELETED";
    my $postid = $jitemid * 256 + $db{"event:anum:$jitemid"};

    push @{$posts{$group}}, $postid;
}

foreach my $group (sort keys %posts) {
    print boxify($group);
    foreach my $post (@{$posts{$group}}) {
        print "http://$server/users/$journal/$post.html\n";
    }
}

# clean up
untie %db;

# Prompts for password, cleans it up once received
sub get_pass {
print "Enter your password: ";
    ReadMode('noecho');
    my $in = ReadLine(0);
    ReadMode('normal');
    print "\n";
    chomp $in;
    return $in;
}

# The magic xmlrpc_call method.  I didn't write this, it came from the protocol docs
sub xmlrpc_call {
    my ($method, $req) = @_;
    my $res = $xmlrpc->call($method, $req);
    if ($res->fault) {
        print STDERR "Error:\n".
        " String: " . $res->faultstring . "\n" .
        " Code: " . $res->faultcode . "\n";
        exit 1;
    }
    return $res->result;
}

# Given a password, fetch a challenge and buld the response
sub do_chal_resp {
    my $hpwd = md5_hex($_[0]);
    my $chal = xmlrpc_call('LJ.XMLRPC.getchallenge')->{'challenge'};
    my $resp = md5_hex($chal . $hpwd);

    return ($chal, $resp);
}

# Fetch the user's groups and format them nicely.
sub get_groups {
    my ($user, $pwd) = @_;
    my ($chal, $resp) = do_chal_resp($pwd);

    my $ret = xmlrpc_call('LJ.XMLRPC.getfriendgroups', {
            username       => $user,
            auth_method    => "challenge",
            auth_challenge => $chal,
            auth_response  => $resp,
            ver            => 1,
        }
    )->{friendgroups};

    my %groups;
    $groups{1} = 'Friends Only';
    foreach my $group (@$ret) {
        my $mask = 2 ** $group->{id};
        $groups{$mask} = $group->{name};
    }

    return %groups;
}

# pretty-print boxes around a hunk of text
sub boxify {
    my ($input) = @_;

    my $length = length $input;

    my $line = "+" . ("-" x ($length + 2)) . "+";
    my $body = "| $input |";

    return "$line\n$body\n$line\n";
}

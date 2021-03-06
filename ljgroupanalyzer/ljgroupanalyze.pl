#!/usr/bin/perl -w

#####################
# ljgroupanalyze.pl #
##########################################################################
# Copyright 2005-2006 Ben Bleything <ben@bleything.net>                  #
# Distributed under the BSD license.                                     #
#                                                                        #
# Please see the README for more information.                            #
##########################################################################

use strict;
use GDBM_File;
use Term::ReadKey;
use Digest::MD5 qw(md5_hex);
use XMLRPC::Lite;
use Getopt::Long; Getopt::Long::Configure( 'bundling' );

# OPTIONS
my %opts = (
    server      => 'www.livejournal.com',
    friendsonly => 0,
);

GetOptions( \%opts,
    'server|s=s',
    'journal|j|user|u=s',
    'password|p=s',
    'friendsonly|f!',
    'help|h|?',
    'simple',
    'empty|e',
#    'html',        # not yet implemented
#    'outfile|o=s', # not yet implemented
);

if ($opts{help}) {
    die <<EOH
ljgroupanalyze.pl
Copyright (c) 2005-2006 Ben Bleything <ben\@bleything.net>

OVERVIEW
  Examines a journal backup created with jbackup.pl and displays
  URLs for posts grouped by the friends group they are filtered to.

NOTE
  The jbackup-created journal dump must be located in the current
  directory.

OPTIONS
  -s, --server <some server>    Specify a server.  Defaults to
                                www.livejournal.com

  -j, --journal <journal name>  Specify journal name.  If you do not
                                use this flag, you will be prompted
                                for your journal name.

  -p, --password <password>     Specify journal password.  If you do not
                                use this flag, you will be prompted
                                for your password.

  --simple                      Simple mode.  You don't need to enter
                                your password, but you won't get the
                                names of your groups.

  -f, --friendsonly             Use this option if you would like to
                                display Friends Only posts as well as
                                filtered posts.

  -e, --empty                   Causes friends groups with no posts to
                                be displayed.

  -h, --help                    Display this message.

EXAMPLES
  ./ljgroupanalyze.pl -j exampleusername -p somepass -f
  ./ljgroupanalyze.pl -fj exampleusername
  ./ljgroupanalyze.pl -s www.deadjournal.com
EOH
}

# sanity checks
if( $opts{simple} && $opts{password} ) {
    die("You may not enter a password while using simple mode.\n");
}

# Get the journal name if we don't already have it
unless( $opts{journal} ) {
    $opts{journal} = get_journal();
}
die("You must specify a journal name\n") unless $opts{journal};

# Create the xmlrpc object
my $xmlrpc = new XMLRPC::Lite;
$xmlrpc->proxy("http://$opts{server}/interface/xmlrpc");

# Open up the jbackup dump... or don't.
tie my %db, 'GDBM_File', "$opts{journal}.jbak", &GDBM_READER, 0600 or die "Could not open/tie $opts{journal}.jbak: $!\nIs the file located in this directory?\n";

if( $opts{simple} ) {
    foreach my $jitemid (split /,/, $db{'event:ids'}) {
        next unless (defined $db{"event:security:$jitemid"} && $db{"event:security:$jitemid"} eq "usemask");

        my $mask = ( defined $db{"event:allowmask:$jitemid"} ? $db{"event:allowmask:$jitemid"} : -1 );
        next if ($opts{friendsonly} == 0 && $mask == 1);

        my $group = ($mask == -1 ? "GROUP DELETED" : $mask);
        my $postid = $jitemid * 256 + ($db{"event:anum:$jitemid"} ? $db{"event:anum:$jitemid"} : 0);
        print "$group -- http://$opts{server}/users/$opts{journal}/$postid.html\n";
    }
} else {
    # fetch the group names
    my %groups = get_groups();

    my %posts;
    my @groupless_posts;
    foreach my $jitemid (split /,/, $db{'event:ids'}) {
        next unless (defined $db{"event:security:$jitemid"} && $db{"event:security:$jitemid"} eq "usemask");

        my $mask = ( defined $db{"event:allowmask:$jitemid"} ? $db{"event:allowmask:$jitemid"} : 0 );
        my $postid = $jitemid * 256 + ($db{"event:anum:$jitemid"} ? $db{"event:anum:$jitemid"} : 0);

        push @groupless_posts, $postid if ($mask == 0);

        next if ($opts{friendsonly} == 0 && $mask == 1);

        foreach my $gm (keys %groups) {
            push @{$posts{$gm}}, $postid if (int($gm) & int($mask));
        }
    }

    # output!

    my @collection;
    if( $opts{empty} ) {
        @collection = keys %groups;
    } else {
        @collection = keys %posts;
    }

    foreach my $gm (sort {$groups{$a} cmp $groups{$b}} @collection) {
        # if we're not showing FO posts, don't show the group
        next if( $gm == 1 && $opts{empty} && $opts{friendsonly} == 0);

        # show the group name
        print boxify($groups{$gm});

        # if there aren't any posts, skip to the next group
        next unless $posts{$gm};

        foreach my $post (sort {$a<=>$b} @{$posts{$gm}}) {
            print "http://$opts{server}/users/$opts{journal}/$post.html\n";
        }

    }

    if (@groupless_posts) {
        print boxify('GROUP DELETED');

        foreach my $post (sort {$a<=>$b} @groupless_posts) {
            print "http://$opts{server}/users/$opts{journal}/$post.html\n";
        }
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

# Prompts for journal name, cleans it up once received
sub get_journal {
    print "Enter your journal name: ";
    my $in = ReadLine(0);
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
    $opts{password} = get_pass() unless $opts{password};
    my ($chal, $resp) = do_chal_resp($opts{password});

    my $ret = xmlrpc_call('LJ.XMLRPC.getfriendgroups', {
            username       => $opts{journal},
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

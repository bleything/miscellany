#!/usr/bin/perl -w

#################
## kol-daily.pl #
##########################################################################
# Copyright 2005 Ben Bleything <ben@bleything.net>                       #
# Distributed under the BSD license.                                     #
#                                                                        #
# Please see the README for more information.                            #
##########################################################################

use strict;
$| = 1;
use LWP::UserAgent;

#################
# Change these! #
#################

my $user = 'adventurer';
my $pass = 'isyou';

#######################
# Don't change these! #
#######################
my $ua = LWP::UserAgent->new;
$ua->cookie_jar( {} );
my $root = "http://www.kingdomofloathing.com";

&login($user,$pass);
my $pwd_hash = &get_pwd_hash;

########################
# Action Configuration #
##########################################################################
# It's here that you define what actions you want performed each day.    #
# Simply add or remove lines to suit.  Here's a sample configuration     #
# that picks all the mushrooms, plants knoll mushrooms (defined above!)  #
# in all the slots and conjures Dry Noodles.  I use this daily with my   #
# Pastamancer.                                                           #
#                                                                        #
# You could very easily set up more complex mushroom strategies by       #
# calling the singular plant actions.  Read the code for more details.   #
##########################################################################

&pick_all_shrooms;
&plant_all_shrooms('knoll');
&conjure('noodles');

###############################
# Don't change anything else! #
###############################

###################
# Utility actions #
###################

sub login {
    my ($user, $pass) = @_;

    print "Attempting to login with user $user...";
    my $resp = $ua->post("$root/login.php",
                            {
                                loggingin => "Yup.",
                                loginname => $user,
                                password  => $pass,
                            }
                        );
    die("Could not login!\n") unless $resp->code == 302;
    print "success!\n";
}

sub get_pwd_hash {
    print "Fetching password hash...";

    my $resp = $ua->get("$root/skills.php");
    $resp->content =~ /name=pwd value='(.*?)'/;

    print "success!\n";
    return $1;
}

####################################################################
# Aggregator actions.  These call a singular action multiple times #
####################################################################

sub pick_all_shrooms {
    print "Picking all shrooms...\n";

    for (my $i = 0; $i < 16; $i++) {
        print &pick_shroom($i) . "\n";
    }
}

sub plant_all_shrooms {
    my ($type) = @_;

    print "Planting $type shrooms in all positions\n";

    for (my $i = 0; $i < 16; $i ++) {
        print &plant_shroom($i, $type) . "\n";
    }
}

sub use_skill {
    my ($skill, $qty) = @_;

    print "Attempting to use skill $skill $qty times...";

    my %skills = (
        'patience of the tortoise' => 2000,
    );

    my $resp = $ua->post("$root/skills.php",
                            {
                                action     => "Skillz",
                                whichskill => $skills{$skill},
                                quantity   => $qty,
                                pwd        => $pwd_hash,
                            }
                        );
    if ($resp->content =~ /You acquire an effect/) {
        print "success!";
    } elsif ($resp->content =~ /You don't have enough/) {
        print "failure!  You don't have enough MP.";
    } else {
        print "Hmm... something weird is going on.";
        print $resp->content;
    }

    print "\n";
}

sub conjure {
    my ($item) = @_;

    my %items = (
        'noodles' => 3006,
        'reagents' => 4006,
    );

    print "Attempting to conjure 3 $item...";

    my $resp = $ua->post("$root/skills.php",
                            {
                                action     => "Skillz",
                                whichskill => $items{$item},
                                quantity   => 3,
                                pwd        => $pwd_hash,
                            }
                        );

    if ($resp->content =~ /You acquire <b>3/) {
        print "success!";
    } elsif ($resp->content =~ /You acquire (.*)/) {
        print "partial success: $1";
    } elsif ($resp->content =~ /You don't have enough/) {
        print "failure!  You don't have enough MP.";
    } elsif ($resp->content =~ /You can only conjure/) {
        print "failure!  You've already conjured your limit.";
    } else {
        print "Hmm... something weird is going on.";
        print $resp->content;
    }

    print "\n";
}

##############################################################
# Singular actions.  Called by themselves or by aggregators. #
##############################################################

sub plant_shroom {
    my ($pos, $type) = @_;

    my %shroom_types = (
        'spooky' => 1,
        'knob' => 2,
        'knoll' => 3
    );

    print "Attempting to plant $type shroom at position " . ($pos + 1) . "...";

    my $resp = $ua->post("$root/knoll_mushrooms.php",
                            {
                                action => "plant",
                                pos    => $pos,
                                whichspore => $shroom_types{$type},
                            }
                        );

    if ($resp->content =~ /You plant the spore/) {
        return "shroom planted!";
    } elsif ($resp->content =~ /You can't afford that spore/) {
        return "you're too broke to plant that shroom.";
    } elsif ($resp->content =~ /That position is not empty/) {
        return "there's already a shroom there!";
    } else {
        print $resp->content;
        return "Hmm... something weird is going on.";
    }
}

sub pick_shroom {
    my ($pos) = @_;
    print "Attempting to pick shroom at position " . ($pos + 1) . "...";
    my $resp = $ua->get("$root/knoll_mushrooms.php?action=click&pos=$pos");

    if ($resp->content =~ /You acquire an item/) {
        return "shroom picked!";
    } elsif ($resp->content =~ /What kind of spore would you like to plant/) {
        return "no shroom here.";
    } else {
        print $resp->content;
        return "Hmm... something weird is going on.";
    }
}

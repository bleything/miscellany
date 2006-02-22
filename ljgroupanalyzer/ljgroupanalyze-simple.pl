#!/usr/bin/perl -w

############################
# ljgroupanalyze-simple.pl #
##########################################################################
# Copyright 2005 Ben Bleything <ben@bleything.net>                       #
# Distributed under the BSD license.                                     #
#                                                                        #
# Please see the README for more information.                            #
##########################################################################

use strict;
use GDBM_File;

die("Usage: $0 <journal name>\n") unless defined $ARGV[0];
my $journal = $ARGV[0];

# Open up the jbackup dump... or don't.
tie my %db, 'GDBM_File', "$journal.jbak", &GDBM_READER, 0600 or die "Could not open/tie $journal.jbak: $!\n";

# GO TO TOWN
foreach my $jitemid (split /,/, $db{'event:ids'}) {
    next unless (defined $db{"event:security:$jitemid"} && $db{"event:security:$jitemid"} eq "usemask");

    my $group = defined $db{"event:allowmask:$jitemid"} ? $db{"event:allowmask:$jitemid"} : "GROUP DELETED";
    my $postid = $jitemid * 256 + $db{"event:anum:$jitemid"};
    print "$group -- http://www.livejournal.com/users/$journal/$postid.html\n";
}

# clean up
untie %db;

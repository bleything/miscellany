#!/usr/bin/perl -w

###############
# xwdfetch.pl #
##########################################################################
# Copyright 2006 Ben Bleything <ben@bleything.net>                       #
# Distributed under the BSD license.                                     #
#                                                                        #
# Please see the README for more information.                            #
##########################################################################

use strict;
#use CGI::Lite;

my @localtime = localtime;
my ($day, $month, $year) = @localtime[3,4,5];
$year += 1900;

my $dispatch = {
    crosscanada => sub {
        

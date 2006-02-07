#!/usr/bin/perl -w

use strict;
#use CGI::Lite;

my @localtime = localtime;
my ($day, $month, $year) = @localtime[3,4,5];
$year += 1900;

my $dispatch = {
    crosscanada => sub {
        
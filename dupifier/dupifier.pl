#!/usr/bin/perl -w

###############
# dupifier.pl #
##########################################################################
# Copyright 2005 Ben Bleything <ben@bleything.net>                       #
# Distributed under the BSD license.                                     #
#                                                                        #
# Please see the README for more information.                            #
##########################################################################


use strict;
use File::Find;
use Digest::MD5 qw(md5_hex);

die("Usage: $0 <absolute path to Maildir>\n") unless $ARGV[0];

my %hash;
my ( $counter, $dupes );

$counter = 0;

sub process {
    my $file = $File::Find::name;

    return unless $file =~ m!/(cur|new|tmp)/.!;

    open FILE, "< $file" or die "Couldn't open file $file: $!";
    $counter++;

    my ( $body, $inheader ) = ( "", 1 );
    while (<FILE>) {
        $inheader = 0 if /^$/;

        unless ($inheader) {
            $body .= $_;
        }
    }
    close FILE;

    $body =~ s/\s|\n//g;

    my $digest = md5_hex($body);

    push @{ $hash{$digest} }, $file;
}

find( \&process, shift );

foreach ( keys %hash ) {
    next unless scalar( @{ $hash{$_} } ) > 1;

    $dupes++;

    $, = "\n";
    print @{ $hash{$_} };
    print "\n\n";
}

print "DONE: processed $counter messages, ";
print "found $dupes sets of messages that may be dupes.\n";

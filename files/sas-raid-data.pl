#!/usr/bin/perl
 
use strict;
use Data::Dumper;
use JSON;

my $DEBUG = 0;

my $key    = shift @ARGV;
my $method = shift @ARGV;

my $toGrep;

if($key eq 'array')
{
    $toGrep = '2'
}
elsif($key eq 'disk')
{
    $toGrep = '3'
}
else
{
    exit 0;
}

my $data = `/usr/sbin/sas2ircu-status --nagios | cut -d'-' -f$toGrep`;

my $ok;
my $ko;
if($data =~ /OK:(\d+) Bad:(\d+)/)
{
    $ok = $1;
    $ko = $2;
}

$DEBUG and print "OK:$ok\nKO:$ko";

if($method eq 'ok')
{
	print $ok;
}
elsif($method eq 'ko')
{
	print $ko;
}
else
{
    exit 0;
}

exit 0;


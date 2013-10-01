#!/usr/bin/perl
 
use strict;
use Data::Dumper;
use JSON;

my $DEBUG = 0;

my $device = shift @ARGV;
my $key    = shift @ARGV;
my $method = shift @ARGV;

my $data = `sudo smartctl -A /dev/$device | grep $key | tail -1`;
my @array = split(" ", $data);

my $value     = int($array[3]);
my $threshold = int($array[5]);

$DEBUG and print "Value:$value\nThresh:$threshold\n";

if($method eq 'value')
{
	print $value;
}
elsif($method eq 'threshold')
{
	print $threshold;
}
else
{
	print $value-$threshold;
}
exit 0;


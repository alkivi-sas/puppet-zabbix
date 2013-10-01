#!/usr/bin/perl
 
use strict;
use Data::Dumper;

my $DEBUG = 0;

my $device = shift @ARGV;
my $key    = shift @ARGV;

my $mapping = {
	reads_completed          => 1,
	reads_merged             => 2,
	reads_sectors            => 3,
	reads_milliseconds       => 4,
	writes_completed         => 5,
	writes_merged            => 6,
	writes_sectors           => 7,
	writes_milliseconds      => 8,
	io_current               => 9,
	io_milliseconds          => 10,
	io_milliseconds_weighted => 11,
};

if(!exists $mapping->{$key})
{
	print STDERR "Error key $key does not exists";
	exit 1;
}

my $data = `cat /proc/diskstats | grep ' $device ' | tail -1`;
$DEBUG and print "Data $data\n";
my @array = split(" ", $data);

my $valueNumber = $mapping->{$key} + 2;
my $value     = int($array[$valueNumber]);

$DEBUG and print "Value $key : $value\n";
$DEBUG and print Dumper(\@array);

print $value;

exit 0;


#!/usr/bin/perl
 
use strict;
use Data::Dumper;
use JSON;

my $data = `cat /proc/diskstats | awk {'print \$3;'}`;
my $devices = [split("\n", $data)];
my $realDevices = [];

foreach my $device (@$devices)
{
	if($device =~ /^[a-z]+$/gi)
	{
		push @$realDevices, $device;
	}
}

my $data = [];
foreach my $device (@$realDevices)
{
	push @$data, { '{#DEVDEVICE}' => $device };
}

my $jsonData = { data => $data };


print to_json($jsonData);


exit 0;

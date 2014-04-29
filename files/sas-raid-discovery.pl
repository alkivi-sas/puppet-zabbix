#!/usr/bin/perl
 
use strict;
use Data::Dumper;
use JSON;

my $data = `sas2ircu list | tail --lines=+9 | head --lines=-1 | wc -l`;
my $realDevices = [];

for( my $device = 0; $device < $data; $device++) 
{
    push @$realDevices, $device;
}

my $data = [];
foreach my $device (@$realDevices)
{
	push @$data, { '{#DEVDEVICE}' => $device };
}

my $jsonData = { data => $data };


print to_json($jsonData);


exit 0;

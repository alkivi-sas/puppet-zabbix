#!/usr/bin/perl
 
use strict;
use Data::Dumper;
use JSON;

my $data = `grep -v '^#' /etc/backuppc/hosts`;
my $hosts = [split("\n", $data)];
my $realHosts = [];

foreach my $host (@$hosts)
{
    # name is everything execept space
        if($host =~ /^([^ ]*) 0$/gio)
        {
        my $realHost = $1;
        $realHost eq 'archive' and next;
                push @$realHosts, $realHost;
        }
}

my $data = [];
foreach my $host (@$realHosts)
{
        push @$data, { '{#BACKUP_HOST}' => $host };
}

my $jsonData = { data => $data };


print to_json($jsonData);


exit 0;

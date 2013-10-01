#!/usr/bin/perl

# Backuppc
use strict;
use lib "/usr/share/backuppc/lib/";
use BackupPC::Lib;
use BackupPC::CGI::Lib;

#Other
use Data::Dumper;
use Getopt::Long;
use JSON;

sub connect_server
{
    my %params = @_;
    my $bpc = $params{'bpc'};
    my %conf = $bpc->Conf();

    #
    # Verify that the server connection is ok
    #
    return if ( $bpc->ServerOK() );
    $bpc->ServerDisconnect();
    if ( my $err = $bpc->ServerConnect($conf{ServerHost}, $conf{ServerPort}) ) {
        if ( CheckPermission()
                and -f $conf{ServerInitdPath}
                and $conf{ServerInitdStartCmd} ne "" ) {
            die "todo in connect_server";
        }
    }

    #        my $content = eval("qq{$Lang->{Admin_Start_Server}}");
    #        Header(eval("qq{$Lang->{Unable_to_connect_to_BackupPC_server}}"), $content);
    #        Trailer();
    #        exit(1);
    #    } else {
    #        ErrorExit(eval("qq{$Lang->{Unable_to_connect_to_BackupPC_server}}"));
    #    }
    #}
}

sub get_server_info
{
    my %params = @_;
    my $status = $params{'status'};
    my $bpc    = $params{'bpc'};

    connect_server( bpc => $bpc );

    my %Jobs;
    my %QueueLen;
    my %Info;
    my %Status;
    my %StatusHost;

    my $reply = $bpc->ServerMesg("status $status");
    eval($reply);

    my $return = {};

    if($status =~ /jobs/)
    {
        $return->{'jobs'} = \%Jobs;
    }

    if($status =~ /queueLen/)
    {
        $return->{'queueLen'} = \%QueueLen;
    }

    if($status =~ /info/)
    {
        $return->{'info'} = \%Info;
    }

    if($status =~ /\bhosts\b/)
    {
        foreach my $host ( grep(/admin/, keys(%Status)) ) {
            delete($Status{$host}) if ( $bpc->isAdminJob($host) );
        }
        delete($Status{$bpc->trashJob});
        $return->{'hosts'} = \%Status;
    }

    if($status =~ /\bhost\(/)
    {
        $return->{'host'} = \%StatusHost;
    }

    return $return;
}

sub hosts_info
{
    my %params = @_;
    my $bpc    = $params{'bpc'};
    my $host   = $params{'host'};
    my $val = {};

    # variables
    my $fullSizeTot = 0;
    my $fullCnt = 0;
    my $fullCnt2 = 0;
    my $incrSizeTot = 0;
    my $incrCnt = 0;
    my $incrCnt2 = 0;
    my $total_speed_full = 0;
    my $total_speed_incr = 0;

    my @Backups = $bpc->BackupInfoRead($host);
    $bpc->ConfigRead($host);

    # variables
    my $fullAge;
    my $fullSize;
    my $fullDur;
    my $incrAge;
    my $incrSize;
    my $incrDur;
    my $xferErrs = 0;

    for ( my $i = 0 ; $i < @Backups ; $i++ ) 
    {
        if ( $Backups[$i]{type} eq "full" ) 
        {
            $fullCnt++;
            if ( $fullAge < 0 || $Backups[$i]{startTime} > $fullAge ) 
            {
                $fullAge  = $Backups[$i]{startTime};
                $fullSize = $Backups[$i]{size};
                $fullDur  = $Backups[$i]{endTime} - $Backups[$i]{startTime};

                if($Backups[$i]{xferErrs} > $xferErrs)
                {
                    $xferErrs = $Backups[$i]{xferErrs};
                }
            }
            $fullSizeTot += $Backups[$i]{size};
        } 
        else 
        {
            $incrCnt++;
            if ( $incrAge < 0 || $Backups[$i]{startTime} > $incrAge ) 
            {
                $incrAge  = $Backups[$i]{startTime};
                $incrSize = $Backups[$i]{size};
                $incrDur  = $Backups[$i]{endTime} - $Backups[$i]{startTime};

                if($Backups[$i]{xferErrs} > $xferErrs)
                {
                    $xferErrs = $Backups[$i]{xferErrs};
                }
            }
            $incrSizeTot += $Backups[$i]{size};
        }
    }
    # Sum the Last Full Backup Speed
    if ($fullSize > 0 && $fullDur >0)
    {
        $total_speed_full += ($fullSize / $fullDur);
        $fullCnt2++;
    }
    # Sum the Last Full Incr Speed
    if ($incrSize > 0 && $incrDur >0)
    {
        $total_speed_incr += ($incrSize / $incrDur);
        $incrCnt2++;
    }



    if ($fullCnt2 > 0 )
    { $val->{hostsAvgFullSpeed} = ($total_speed_full / $fullCnt2); }
    if ($incrCnt2 > 0 )
    { $val->{hostsAvgIncrSpeed} = ($total_speed_incr / $incrCnt2); }
    $val->{hostsFullAge}   = ( time() - $fullAge );
    $val->{hostsFullSize}  = $fullSizeTot;
    $val->{hostsFullCount} = $fullCnt;
    $val->{hostsIncrAge}   = ( time() - $incrAge );
    $val->{hostsIncrSize}  = $incrSizeTot;
    $val->{hostsIncrCount} = $incrCnt;
    $val->{xferErrs} = $xferErrs;

    return $val;
}


sub pool_info
{
    my %params = @_;
    my $info = $params{'info'};
    my $val = {};

    while ( my ($key, $value) = each(%$info) )
    {
        if ($key =~ /pool/)
        {
            my $value = $info->{$key};
            if($key eq 'cpoolKb')
            {
                $value = $value * 1024;
            }
            $val->{$key} = $value; 
        }
    }


    return $val;
}

sub general_info
{
    my %params = @_;
    my $info = $params{'info'};
    my $val = {};

    $val->{startTime}   = ( time() - $info->{startTime} ) ;
    $val->{version}     = $info->{Version};
    $val->{configLTime}	= ( time() - $info->{ConfigLTime} ) ;
    $val->{pid}	        = $info->{pid};

    return $val;

}

sub queue_info
{
    my %params = @_;
    my $queueLen = $params{'queueLen'};
    my $val = {};

    while ( my ($key, $value) = each(%$queueLen) ) 
    {
        if ($key =~ /Queue/)
        {
            $val->{lcfirst($key)} = $queueLen->{$key};
        }
    }

    return $val;
}


sub jobs_info 
{

    my %params = @_;
    my $jobs = $params{'jobs'};

    my $val = {};

    $val->{jobsIncr}  = 0;
    $val->{jobsFull}  = 0;
    $val->{jobsOther} = 0;

    # Jobs
    while ( my ($key, $value) = each(%$jobs) ) {
        #print "$key => $value\n";
        #print Dumper($value);
        if (!($key =~ /trashClean/i))
        {
            # Count Incrementail Jobs
            if( $value->{'type'} eq 'incr')
            { $val->{jobsIncr}++; }

            # Count Full Jobs
            elsif( $value->{'type'} eq 'full')
            { $val->{jobsFull}++; }

            # Everything Else
            else { $val->{jobsOther}++; }
        }
    }

    return $val;
}

#
#sub GetStatusInfo
#{
#    my($status) = @_;
#    ServerConnect();
#    %Status = ()     if ( $status =~ /\bhosts\b/ );
#    %StatusHost = () if ( $status =~ /\bhost\(/ );
#    my $reply = $bpc->ServerMesg("status $status");
#    $reply = $1 if ( $reply =~ /(.*)/s );
#    eval($reply);
#    # ignore status related to admin and trashClean jobs
#    if ( $status =~ /\bhosts\b/ ) {
#        foreach my $host ( grep(/admin/, keys(%Status)) ) {
#            delete($Status{$host}) if ( $bpc->isAdminJob($host) );
#        }
#        delete($Status{$bpc->trashJob});
#    }
#}
#
##
## Returns the list of hosts that should appear in the navigation bar
## for this user.  If $getAll is set, the admin gets all the hosts.
## Otherwise, regular users get hosts for which they are the user or
## are listed in the moreUsers column in the hosts file.
##
#sub GetUserHosts
#{
#    my($getAll) = @_;
#    my @hosts;
#
#    if ( $getAll ) {
#        @hosts = sort keys %$Hosts;
#    } else {
#        @hosts = sort grep { $Hosts->{$_}{user} eq $User ||
#        defined($Hosts->{$_}{moreUsers}{$User}) } keys(%$Hosts);
#    }
#    return @hosts;
#}
#
#
#sub ServerConnect
#{
#    #
#    # Verify that the server connection is ok
#    #
#    return if ( $bpc->ServerOK() );
#    $bpc->ServerDisconnect();
#    if ( my $err = $bpc->ServerConnect($Conf{ServerHost}, $Conf{ServerPort}) ) {
#        if ( CheckPermission()
#            && -f $Conf{ServerInitdPath}
#            && $Conf{ServerInitdStartCmd} ne "" ) {
#            my $content = eval("qq{$Lang->{Admin_Start_Server}}");
#            Header(eval("qq{$Lang->{Unable_to_connect_to_BackupPC_server}}"), $content);
#            Trailer();
#            exit(1);
#        } else {
#            ErrorExit(eval("qq{$Lang->{Unable_to_connect_to_BackupPC_server}}"));
#        }
#    }
#}
#
#
#


my $type;
my $key;
my $host;
my $debug = "";

my $fnret = GetOptions (
    'type=s' => \$type,
    'key=s'  => \$key,
    'host=s' => \$host,
    'debug'  => \$debug,
);

$fnret or die("Unable to GetOptions");

#
# Check params
# 
if(!$type)
{
    die("No type passed, use --type type");
}

if(!$key)
{
    die("No key passed, use --key key");
}

if($type eq 'host' and !$host)
{
    die("You have to pass host using --host hostname");
}

# 
# Verify params
#
my $type2status = {
    info => 'info',
    pool => 'info',
    queue => 'queueLen',
    jobs => 'jobs',
    hosts => 'hosts',
    host => 'host',
};

my @allowedKeys = qw//;


# Globals
my $bpc = BackupPC::Lib->new();

# Get hosts
#my $hosts = $bpc->HostInfoRead();
#print Dumper($hosts);
#exit 0;

# Allowed keys
# jobs:
#   jobsIncr
#   jobsFull
#   jobsOther
# info:
#   version
#   pid
#   startTime
#   configLTime
# queue:
#   cmdQueue
#   bgQueue
#   userQueue
# pool:
#   cpoolFileCnt (total file)
#   cpoolDirCnt (total dir)
#   cpoolKb (total kb)
# host:
#   hostsFullCount
#   hostsFullSize
#   hostsAvgFullSpeed
#   hostsFullAge
#   hostsIncrCount
#   hostsIncrSize
#   hostsAvgIncrSpeed
#   hostsIncrAge
#   xferErrs
 
if(! exists $type2status->{$type})
{
    die "Key type is not valid";
}

my $status = $type2status->{$type};
if($type eq 'host')
{
    $status = "$status($host)";
}

# Collect Data
my $serverInfos = get_server_info(bpc => $bpc, status => $status);
#print Dumper($serverInfos);

# All are hash references
# $info = Pool Info
# $queueLen = Command Queues
# $jobs = jobs

my $function;
my $hashKey;

if($type eq 'jobs')
{
    $function = \&jobs_info;
    $hashKey  = 'jobs';
}
elsif($type eq 'info')
{
    $function = \&general_info;
    $hashKey = 'info';
}
elsif($type eq 'queue')
{
    $function = \&queue_info;
    $hashKey  = 'queueLen';
}
elsif($type eq 'pool')
{
    $function = \&pool_info;
    $hashKey  = 'info';
}

my $hash;
if($type eq 'host')
{
    $hash = hosts_info( bpc => $bpc, host => $host );
}
else
{
    $hash = $function->( $hashKey => $serverInfos->{$hashKey} );
}

#print Dumper($hash);
if(! exists $hash->{$key} )
{
    die "No key name $key for type $type";
}
print $hash->{$key};
exit 0;

class zabbix::server (
  $listenPort              = '10051',
  $sourceIp                = undef,
  $logFile                 = '/var/log/zabbix-server/zabbix_server.log',
  $logFileSize             = undef,
  $debugLevel              = '3',
  $pidFile                 = '/var/run/zabbix-server/zabbix_server.pid',
  $dBHost                  = 'localhost',
  $dBName                  = 'zabbix',
  $dBUser                  = 'zabbix',
  $dBPassword              = 'CHANGEME',
  $startPollers            = '5',
  $startIPMIPollers        = '0',
  $startPollersUnreachable = '1',
  $startTrappers           = '5',
  $startPingers            = '1',
  $startDiscoverers        = '1',
  $startHTTPPollers        = '1',
  $listenIp                = undef,
  $housekeepingFrequency   = '1',
  $maxHousekeeperDelete    = '500',
  $disableHousekeeping     = '0',
  $senderFrequency         = '30',
  $cacheSize               = '8M',
  $cacheUpdateFrequency    = '60',
  $startDBSyncers          = '4',
  $historyCacheSize        = '8M',
  $trendCacheSize          = '4M',
  $historyTextCacheSize    = '16M',
  $timeout                 = '5',
  $trapperTimeout          = '300',
  $unreachablePeriod       = '45',
  $unavailableDelay        = '60',
  $alertScriptsPath        = '/home/alkivi/zabbix/alert-scripts/',
  $externalScripts         = '/home/alkivi/zabbix/external-scripts',
  $fpingLocation           = '/usr/bin/fping',
  $fping6Location          = '/usr/sbin/fping6',
  $motd                    = true,
) {

  if($motd)
  {
    motd::register{ 'Zabbix Server': }
  }

  if(! defined(Class['zabbix']))
  {
    class { 'zabbix': }
    Class['zabbix'] -> Class['zabbix::server']
  }

  # declare all parameterized classes
  class { 'zabbix::server::params': }
  class { 'zabbix::server::install': }
  class { 'zabbix::server::config': }
  class { 'zabbix::server::service': }

  # declare relationships
  Class['zabbix::server::params'] ->
  Class['zabbix::server::install'] ->
  Class['zabbix::server::config'] ->
  Class['zabbix::server::service']
}


class zabbix::proxy (
  $hostname,
  $server                  = 'zabbix.alkivi.fr',
  $serverPort              = '10051',
  $startPollers            = '5',
  $startIPMIPollers        = '0',
  $startPollersUnreachable = '1',
  $startTrappers           = '5',
  $startPingers            = '1',
  $startDiscoverers        = '1',
  $startHTTPPollers        = '1',
  $listenPort              = '10051',
  $heartbeatFrequency      = '60',
  $configFrequency         = '3600',
  $housekeepingFrequency   = '1',
  $senderFrequency         = '30',
  $proxyLocalBuffer        = '0',
  $proxyOfflineBuffer      = '1',
  $debugLevel              = '3',
  $timeout                 = '5',
  $trapperTimeout          = '5',
  $unreachablePeriod       = '45',
  $unavailableDelay        = '60',
  $pidFile                 = '/var/run/zabbix/zabbix_proxy.pid',
  $logFile                 = '/var/log/zabbix-proxy/zabbix_proxy.log',
  $alertScriptsPath        = '/home/alkivi/zabbix/alert-scripts/',
  $externalScripts         = '/home/alkivi/zabbix/external-scripts',
  $fpingLocation           = '/usr/bin/fping',
  $fping6Location          = '/usr/sbin/fping6',
  $tmpDir                  = '/tmp',
  $pingerFrequency         = '60',
  $dBHost                  = 'localhost',
  $dBName                  = 'zabbix',
  $dBUser                  = 'zabbix',
  $dBPassword              = alkivi_password('zabbix', 'db'),

  $sourceIp                = undef,
  $listenIp                = undef,
  $logFileSize             = undef,

  $motd                    = true,

) {

  if($motd)
  {
    motd::register{'Zabbix Proxy': }
  }

  if(! defined(Class['zabbix']))
  {
    class { 'zabbix': }
    Class['zabbix'] -> Class['zabbix::proxy']
  }

  # declare all parameterized classes
  class { 'zabbix::proxy::params': }
  class { 'zabbix::proxy::install': }
  class { 'zabbix::proxy::config': }
  class { 'zabbix::proxy::service': }

  # declare relationships
  Class['zabbix::proxy::params'] ->
  Class['zabbix::proxy::install'] ->
  Class['zabbix::proxy::config'] ->
  Class['zabbix::proxy::service']
}


class zabbix::server::config (
  $listenPort              = $zabbix::server::listenPort,
  $sourceIp                = $zabbix::server::sourceIp,
  $logFile                 = $zabbix::server::logFile,
  $logFileSize             = $zabbix::server::logFileSize,
  $debugLevel              = $zabbix::server::debugLevel,
  $pidFile                 = $zabbix::server::pidFile,
  $dBHost                  = $zabbix::server::dBHost,
  $dBName                  = $zabbix::server::dBName,
  $dBUser                  = $zabbix::server::dBUser,
  $dBPassword              = $zabbix::server::dBPassword,
  $startPollers            = $zabbix::server::startPollers,
  $startIPMIPollers        = $zabbix::server::startIPMIPollers,
  $startPollersUnreachable = $zabbix::server::startPollersUnreachable,
  $startTrappers           = $zabbix::server::startTrappers,
  $startPingers            = $zabbix::server::startPingers,
  $startDiscoverers        = $zabbix::server::startDiscoverers,
  $startHTTPPollers        = $zabbix::server::startHTTPPollers,
  $startTimers             = $zabbix::server::startTimers,
  $listenIp                = $zabbix::server::listenIp,
  $housekeepingFrequency   = $zabbix::server::housekeepingFrequency,
  $maxHousekeeperDelete    = $zabbix::server::maxHousekeeperDelete,
  $senderFrequency         = $zabbix::server::senderFrequency,
  $cacheSize               = $zabbix::server::cacheSize        ,
  $cacheUpdateFrequency    = $zabbix::server::cacheUpdateFrequency,
  $startDBSyncers          = $zabbix::server::startDBSyncers,
  $historyCacheSize        = $zabbix::server::historyCacheSize,
  $historyTextCacheSize    = $zabbix::server::historyTextCacheSize,
  $trendCacheSize          = $zabbix::server::trendCacheSize,
  $historyCacheSize        = $zabbix::server::historyCacheSize,
  $timeout                 = $zabbix::server::timeout,
  $trapperTimeout          = $zabbix::server::trapperTimeout,
  $unreachablePeriod       = $zabbix::server::unreachablePeriod,
  $unavailableDelay        = $zabbix::server::unavailableDelay,
  $alertScriptsPath        = $zabbix::server::alertScriptsPath,
  $externalScripts         = $zabbix::server::externalScripts,
  $fpingLocation           = $zabbix::server::fpingLocation,
  $fping6Location          = $zabbix::server::fping6Location,

)
{
  File {
    ensure => present,
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0640',
  }

  file { '/etc/zabbix/zabbix_server.conf':
    content => template('zabbix/zabbix_server.conf.erb'),
    notify  => Service[$zabbix::server::params::service_name],
  }

  file { '/var/log/zabbix-server':
    ensure => directory,
    mode   => '0750',
  }
}

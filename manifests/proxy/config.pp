class zabbix::proxy::config (
  $hostname                = $zabbix::proxy::hostname,
  $server                  = $zabbix::proxy::server,
  $serverPort              = $zabbix::proxy::serverPort,
  $startPollers            = $zabbix::proxy::startPollers,
  $startIPMIPollers        = $zabbix::proxy::startIPMIPollers,
  $startPollersUnreachable = $zabbix::proxy::startPollersUnreachable,
  $startTrappers           = $zabbix::proxy::startTrappers,
  $startPingers            = $zabbix::proxy::startPingers,
  $startDiscoverers        = $zabbix::proxy::startDiscoverers,
  $startHTTPPollers        = $zabbix::proxy::startHTTPPollers,
  $listenPort              = $zabbix::proxy::listenPort,
  $heartbeatFrequency      = $zabbix::proxy::heartbeatFrequency,
  $configFrequency         = $zabbix::proxy::configFrequency,
  $housekeepingFrequency   = $zabbix::proxy::housekeepingFrequency,
  $senderFrequency         = $zabbix::proxy::senderFrequency,
  $proxyLocalBuffer        = $zabbix::proxy::proxyLocalBuffer,
  $proxyOfflineBuffer      = $zabbix::proxy::proxyOfflineBuffer,
  $debugLevel              = $zabbix::proxy::debugLevel,
  $timeout                 = $zabbix::proxy::timeout,
  $trapperTimeout          = $zabbix::proxy::trapperTimeout,
  $unreachablePeriod       = $zabbix::proxy::unreachablePeriod,
  $unavailableDelay        = $zabbix::proxy::unavailableDelay,
  $pidFile                 = $zabbix::proxy::pidFile,
  $logFile                 = $zabbix::proxy::logFile,
  $alertScriptsPath        = $zabbix::proxy::alertScriptsPath,
  $externalScripts         = $zabbix::proxy::externalScripts,
  $fpingLocation           = $zabbix::proxy::fpingLocation,
  $fping6Location          = $zabbix::proxy::fping6Location,
  $tmpDir                  = $zabbix::proxy::tmpDir,
  $pingerFrequency         = $zabbix::proxy::pingerFrequency,
  $dBHost                  = $zabbix::proxy::dBHost,
  $dBName                  = $zabbix::proxy::dBName,
  $dBUser                  = $zabbix::proxy::dBUser,
  $dBPassword              = $zabbix::proxy::dBPassword,
  $sourceIp                = $zabbix::proxy::sourceIp,
  $listenIp                = $zabbix::proxy::listenIp,
  $logFileSize             = $zabbix::proxy::logFileSize,
)
{
  File {
    ensure => present,
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0640',
  }

  file { '/etc/iptables.d/20-zabbix.rules':
    source  => 'puppet:///modules/zabbix/zabbix.rules',
    require => Package['alkivi-iptables'],
    notify  => Service['alkivi-iptables'],
  }

  file { '/etc/zabbix/zabbix_proxy.conf':
    content => template('zabbix/zabbix_proxy.conf.erb'),
    notify  => Service[$zabbix::proxy::params::service_name],
  }

  file { '/var/run/zabbix-proxy':
    ensure => directory,
    mode   => '0750',
  }

  file { '/var/log/zabbix-proxy':
    ensure => directory,
    mode   => '0750',
  }
}

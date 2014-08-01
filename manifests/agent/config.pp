class zabbix::agent::config (
    $pidFile        = $zabbix::agent::pidFile,
    $logFile        = $zabbix::agent::logFile,
    $logFileSize    = $zabbix::agent::logFileSize,
    $debugLevel     = $zabbix::agent::debugLevel,
    $server         = $zabbix::agent::server,
    $serverActive   = $zabbix::agent::serverActive,
    $hostname       = $zabbix::agent::hostname,
    $raidParameter  = $zabbix::agent::raidParameter,
    $mysqlParameter = $zabbix::agent::mysqlParameter,
    $smartParameter = $zabbix::agent::smartParameter,
) {
  File {
    ensure => present,
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0640',
    notify => Class['zabbix::agent::service'],
  }

  file { '/etc/zabbix/zabbix_agentd.conf':
    content => template('zabbix/zabbix_agentd.conf.erb'),
  }

  file { '/var/log/zabbix-agent':
    ensure => directory,
    mode   => '0750',
  }

  if($zabbix::agent::firewall)
  {
    alkivi_base::firewall_rule{ 'zabbix-agent':
      dest_port => 10050,
      priority  => 30,
    }
  }
}

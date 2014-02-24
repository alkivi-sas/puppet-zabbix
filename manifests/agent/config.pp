class zabbix::agent::config () {
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

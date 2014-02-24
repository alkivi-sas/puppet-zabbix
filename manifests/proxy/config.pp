class zabbix::proxy::config ()
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

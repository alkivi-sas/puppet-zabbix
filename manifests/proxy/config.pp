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

  file { '/etc/zabbix/zabbix_proxy.conf.temp':
    content => template('zabbix/zabbix_proxy.conf.erb'),
  }

  # Fix password
  exec { '/etc/zabbix/zabbix_proxy.conf.password':
    command  => 'PASSWORD=`cat /root/.passwd/db/zabbix` && sed \'s/CHANGEME/\'\$PASSWORD\'/\' /etc/zabbix/zabbix_proxy.conf.temp > /etc/zabbix/zabbix_proxy.conf && touch /etc/zabbix/zabbix_proxy.conf.ok',
    provider => 'shell',
    creates  => '/etc/zabbix/zabbix_proxy.conf.ok',
    path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
    require  => File['/etc/zabbix/zabbix_proxy.conf.temp'],
    notify   => Class['zabbix::proxy::service'],
  }

  file { '/var/log/zabbix-proxy':
    ensure => directory,
    mode   => '0750',
  }
}

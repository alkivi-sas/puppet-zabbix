class zabbix::server::config () {
  File {
    ensure => present,
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0640',
  }

  file { '/etc/zabbix/zabbix_server.conf.temp':
    content => template('zabbix/zabbix_server.conf.erb'),
  }

  # Fix password
  exec { '/etc/zabbix/zabbix_server.conf.password':
    command  => 'PASSWORD=`cat /root/.passwd/db/zabbix` && sed \'s/CHANGEME/\'\$PASSWORD\'/\' /etc/zabbix/zabbix_server.conf.temp > /etc/zabbix/zabbix_server.conf && touch /etc/zabbix/zabbix_server.conf.ok',
    provider => 'shell',
    creates  => '/etc/zabbix/zabbix_server.conf.ok',
    path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
    require  => File['/etc/zabbix/zabbix_server.conf.temp'],
    notify   => Class['zabbix::server::service'],
  }
}

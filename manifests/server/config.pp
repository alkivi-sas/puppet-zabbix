class zabbix::server::config () {
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

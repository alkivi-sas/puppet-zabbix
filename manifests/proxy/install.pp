class zabbix::proxy::install () {
  mysql::database{ 'zabbix':
    user    => 'zabbix',
    require => Class['mysql'],
  }

  if(! defined(File['/root/preseed/']))
  {
    file { '/root/preseed':
      ensure => directory,
      mode   => '0750',
    }
  }

  $zabbix_password = alkivi_password('zabbix', 'db')
  $admin_password = alkivi_password('mysql', 'db')

  file { '/root/preseed/zabbix-proxy.preseed':
    content => template('zabbix/proxy.preseed.erb'),
    mode    => '0600',
    backup  => false,
    require => File['/root/preseed'],
  }

  package { $zabbix::proxy::params::package_name:
    ensure       => installed,
    responsefile => '/root/preseed/zabbix-proxy.preseed',
    require      => [Mysql::Database['zabbix'], File['/root/preseed/zabbix-proxy.preseed'] ],
  }
}

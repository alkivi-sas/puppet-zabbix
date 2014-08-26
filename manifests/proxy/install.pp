class zabbix::proxy::install () {
  mysql::db { 'zabbix':
    user     => 'zabbix',
    password => alkivi_password('zabbix', 'db'),
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
    ensure       => latest,
    responsefile => '/root/preseed/zabbix-proxy.preseed',
    require      => [Mysql::Db['zabbix'], File['/root/preseed/zabbix-proxy.preseed'] ],
  }
}

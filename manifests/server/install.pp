class zabbix::server::install () {
  mysql::database{ 'zabbix':
    user    => 'zabbix',
    require => Class['mysql'],
  }

  if ! defined(File['/root/preseed/'])
  {
    file { '/root/preseed':
      ensure => directory,
      mode   => '0750',
    }
  }

  $zabbix_password = alkivi_password('zabbix', 'db')
  $admin_password = alkivi_password('mysql', 'db')

  file { '/root/preseed/zabbix-server.preseed':
    content => template('zabbix/server.preseed.erb'),
    mode    => '0600',
    backup  => false,
    require => File['/root/preseed'],
  }

  package { $zabbix::server::params::package_name:
    ensure       => latest,
    responsefile => '/root/preseed/zabbix-server.preseed',
    require      => [Mysql::Database['zabbix'], File['/root/preseed/zabbix-server.preseed'] ],
  }
}

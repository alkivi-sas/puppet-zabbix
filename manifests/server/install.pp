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

  file { '/root/preseed/zabbix-server.preseed.temp':
    content => template('zabbix/server.preseed.erb'),
    mode    => '0600',
    backup  => false,
    require => File['/root/preseed'],
  }

  exec { '/root/preseed/zabbix-server.preseed':
    command  => 'ADMINPASS=`cat /root/.passwd/db/mysql` && PASSWORD=`cat /root/.passwd/db/zabbix` && sed \'s/ZABBIXPASSWD/\'\$PASSWORD\'/g\' /root/preseed/zabbix-server.preseed.temp > /root/preseed/zabbix-server.preseed && sed -i \'s/MYSQLADMIN/\'\$ADMINPASS\'/g\' /root/preseed/zabbix-server.preseed && touch /root/preseed/zabbix-server.preseed.ok',
    provider => 'shell',
    creates  => '/root/preseed/zabbix-server.preseed.ok',
    path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
    require  => File['/root/preseed/zabbix-server.preseed.temp'],
  }

  package { $zabbix::server::params::package_name:
    ensure       => installed,
    responsefile => '/root/preseed/zabbix-server.preseed',
    require      => [Mysql::Database['zabbix'], Exec['/root/preseed/zabbix-server.preseed'] ],
  }
}

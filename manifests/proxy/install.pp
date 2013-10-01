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

  file { '/root/preseed/zabbix-proxy.preseed.temp':
    content => template('zabbix/proxy.preseed.erb'),
    mode    => '0600',
    backup  => false,
    require => File['/root/preseed'],
  }

  exec { '/root/preseed/zabbix-proxy.preseed':
    command  => 'ADMINPASS=`cat /root/.passwd/db/mysql` && PASSWORD=`cat /root/.passwd/db/zabbix` && sed \'s/ZABBIXPASSWD/\'\$PASSWORD\'/g\' /root/preseed/zabbix-proxy.preseed.temp > /root/preseed/zabbix-proxy.preseed && sed -i \'s/MYSQLADMIN/\'\$ADMINPASS\'/g\' /root/preseed/zabbix-proxy.preseed && touch /root/preseed/zabbix-proxy.preseed.ok',
    provider => 'shell',
    creates  => '/root/preseed/zabbix-proxy.preseed.ok',
    path     => ['/bin', '/sbin', '/usr/bin', '/root/alkivi-scripts/'],
    require  => File['/root/preseed/zabbix-proxy.preseed.temp'],
  }

  package { $zabbix::proxy::params::package_name:
    ensure       => installed,
    responsefile => '/root/preseed/zabbix-proxy.preseed',
    require      => [Mysql::Database['zabbix'], Exec['/root/preseed/zabbix-proxy.preseed'] ],
  }
}

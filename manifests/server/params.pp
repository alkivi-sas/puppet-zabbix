class zabbix::server::params () {
  case $::operatingsystem {
    /(Ubuntu|Debian)/: {
      $service_name   = 'zabbix-server'
      $package_name   = 'zabbix-server-mysql'
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}


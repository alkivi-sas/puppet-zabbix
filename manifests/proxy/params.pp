class zabbix::proxy::params () {
  case $::operatingsystem {
    /(Ubuntu|Debian)/: {
      $service_name   = 'zabbix-proxy'
      $package_name   = 'zabbix-proxy-mysql'
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}


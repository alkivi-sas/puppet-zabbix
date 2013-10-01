class zabbix::agent::params () {
  case $::operatingsystem {
    /(Ubuntu|Debian)/: {
      $service_name   = 'zabbix-agent'
      $package_name   = 'zabbix-agent'
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}


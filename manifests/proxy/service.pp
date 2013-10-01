class zabbix::proxy::service () {
  service { $zabbix::proxy::params::service_name:
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }
}


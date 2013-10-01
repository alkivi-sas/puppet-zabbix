class zabbix::server::service () {
  service { $zabbix::server::params::service_name:
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }
}


class zabbix::agent::service () {
  service { $zabbix::agent::params::service_name:
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }
}


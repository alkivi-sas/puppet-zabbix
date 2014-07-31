class zabbix::agent::install () {
  package { $zabbix::agent::params::package_name:
    ensure  => latest,
  }
}

class zabbix::agent::install () {
  package { 'zabbix-sender':
    ensure  => latest,
  }

  package { $zabbix::agent::params::package_name:
    ensure  => latest,
  }
}

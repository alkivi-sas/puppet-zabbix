class zabbix () {
  # Define apt reposity
  apt::source { 'zabbix':
    location   => 'http://repo.zabbix.com/zabbix/2.0/debian',
    repos      => 'main',
    release    => 'wheezy',
    key        => '79EA5ED4',
    key_source => 'http://repo.zabbix.com/zabbix-official-repo.key',
  }
}


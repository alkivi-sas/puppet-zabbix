class zabbix::agent (
  $hostname,
  $pidFile      = '/var/run/zabbix/zabbix_agentd.pid',
  $logFile      = '/var/log/zabbix-agent/zabbix_agent.log',
  $logFileSize  = undef,
  $debugLevel   = '3',
  $server       = ['127.0.0.1'],
  $serverActive = ['127.0.0.1'],
  $raid         = false,
  $mysql        = false,
  $smart        = true,
  $backuppc     = false,
  $ups          = false,
  $hwraid       = false,
  $motd         = true,
  $firewall     = true,
  $nginx        = false,
  $postgresql   = false,
  $php_fpm      = false,
  $uwsgi        = false,
  $haproxy      = false,
) {


  if($motd)
  {
    motd::register{'Zabbix Agent': }
  }

  if(! defined(Class['zabbix']))
  {
    class{ 'zabbix': }
  }

  Class['zabbix'] -> Class['zabbix::agent']

  # declare all parameterized classes
  class { 'zabbix::agent::params': }
  class { 'zabbix::agent::install': }
  class { 'zabbix::agent::config': }
  class { 'zabbix::agent::service': }

  File {
    ensure  => present,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    notify  => Service[$zabbix::agent::params::service_name],
    require => Package[$zabbix::agent::params::package_name],
  }

  file { '/etc/zabbix/custom-scripts.d/':
    ensure => directory,
  }

  file { '/etc/zabbix/zabbix_agentd.conf.d/':
    ensure => directory,
  }

  if($smart)
  {
    # Add custom scripts for smart status
    file { '/etc/zabbix/custom-scripts.d/smart-discovery.pl':
      source  => 'puppet:///modules/zabbix/smart-discovery.pl',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }

    file { '/etc/zabbix/custom-scripts.d/smart-data.pl':
      source  => 'puppet:///modules/zabbix/smart-data.pl',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }

    file { '/etc/zabbix/custom-scripts.d/io-data.pl':
      source  => 'puppet:///modules/zabbix/io-data.pl',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }

    # Push rules to user paremters
    file { '/etc/zabbix/zabbix_agentd.conf.d/smart.conf':
      source  => 'puppet:///modules/zabbix/smart.conf',
      require => File['/etc/zabbix/zabbix_agentd.conf.d/'],
    }

    # sudoers for puppet smartctl
    sudo::conf { 'zabbix-smartctl':
      priority => 20,
      content  => "zabbix ALL=(ALL) NOPASSWD: /usr/sbin/smartctl -A /dev/*\n",
    }
  }

  if($raid)
  {
    # Add custom script
    file { '/etc/zabbix/custom-scripts.d/md-discovery.sh':
      source  => 'puppet:///modules/zabbix/md-discovery.sh',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }

    file { '/etc/zabbix/zabbix_agentd.conf.d/raid.conf':
      source  => 'puppet:///modules/zabbix/raid.conf',
      require => File['/etc/zabbix/zabbix_agentd.conf.d/'],
    }

    # sudoers for puppet mdadm
    sudo::conf { 'zabbix-mdadm':
      priority => 20,
      content  => "zabbix ALL=(ALL) NOPASSWD: /sbin/mdadm --detail *\n",
    }
  }
  else
  {
  }

  if($backuppc)
  {
    # Add custom script
    file { '/etc/zabbix/custom-scripts.d/backuppc-discovery.pl':
      source  => 'puppet:///modules/zabbix/backuppc-discovery.pl',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }

    file { '/etc/zabbix/custom-scripts.d/backuppc-data.pl':
      source  => 'puppet:///modules/zabbix/backuppc-data.pl',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }

    file { '/etc/zabbix/custom-scripts.d/backuppc-hosts.pl':
      source  => 'puppet:///modules/zabbix/backuppc-hosts.pl',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }

    file { '/etc/zabbix/zabbix_agentd.conf.d/backuppc.conf':
      source  => 'puppet:///modules/zabbix/backuppc.conf',
      require => File['/etc/zabbix/zabbix_agentd.conf.d/'],
    }

    # sudoers for puppet mdadm
    sudo::conf { 'zabbix-backuppc':
      priority => 20,
      content  => 'zabbix ALL=(backuppc) NOPASSWD: /etc/zabbix/custom-scripts.d/backuppc-data.pl *',
    }

    sudo::conf { 'zabbix-backuppc-hosts':
      priority => 20,
      content  => 'zabbix ALL=(backuppc) NOPASSWD: /etc/zabbix/custom-scripts.d/backuppc-hosts.pl *',
    }
  }
  else
  {
  }

  if($mysql)
  {
    file { '/etc/zabbix/zabbix_agentd.conf.d/mysql.conf':
      source  => 'puppet:///modules/zabbix/mysql.conf',
      require => File['/etc/zabbix/zabbix_agentd.conf.d/'],
    }
  }

  if($postgresql)
  {
    file { '/etc/zabbix/zabbix_agentd.conf.d/postgresql.conf':
      source  => 'puppet:///modules/zabbix/postgresql.conf',
      require => File['/etc/zabbix/zabbix_agentd.conf.d/'],
    }

    file { '/etc/zabbix/custom-scripts.d/postgresql-data.sh':
      source  => 'puppet:///modules/zabbix/postgresql-data.sh',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }

    file { '/etc/zabbix/custom-scripts.d/postgresql-discovery.sh':
      source  => 'puppet:///modules/zabbix/postgresql-discovery.sh',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }
  }

  if($nginx)
  {
    file { '/etc/zabbix/zabbix_agentd.conf.d/nginx.conf':
      source  => 'puppet:///modules/zabbix/nginx.conf',
      require => File['/etc/zabbix/zabbix_agentd.conf.d/'],
    }

    file { '/etc/zabbix/custom-scripts.d/nginx-check.sh':
      source  => 'puppet:///modules/zabbix/nginx-check.sh',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }
  }

  if($php_fpm)
  {
    file { '/etc/zabbix/zabbix_agentd.conf.d/php-fpm.conf':
      source  => 'puppet:///modules/zabbix/php-fpm.conf',
      require => File['/etc/zabbix/zabbix_agentd.conf.d/'],
    }

    file { '/etc/zabbix/custom-scripts.d/php-fpm-check.sh':
      source  => 'puppet:///modules/zabbix/php-fpm-check.sh',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }
  }

  if($uwsgi)
  {
    file { '/etc/zabbix/zabbix_agentd.conf.d/uwsgi.conf':
      source  => 'puppet:///modules/zabbix/uwsgi.conf',
      require => File['/etc/zabbix/zabbix_agentd.conf.d/'],
    }

    file { '/etc/zabbix/custom-scripts.d/uwsgi-data.py':
      source  => 'puppet:///modules/zabbix/uwsgi-data.py',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }
  }

  if($ups)
  {
    file { '/etc/zabbix/zabbix_agentd.conf.d/ups.conf':
      source  => 'puppet:///modules/zabbix/ups.conf',
      require => File['/etc/zabbix/zabbix_agentd.conf.d/'],
    }
  }

  if($hwraid)
  {
    file { '/etc/zabbix/custom-scripts.d/sas-raid-data.pl':
      source  => 'puppet:///modules/zabbix/sas-raid-data.pl',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }

    file { '/etc/zabbix/zabbix_agentd.conf.d/hwraid.conf':
      source  => 'puppet:///modules/zabbix/hwraid.conf',
      require => File['/etc/zabbix/zabbix_agentd.conf.d/'],
    }

    sudo::conf { 'zabbix-hwraid':
      priority => 20,
      content  => 'zabbix ALL=(ALL) NOPASSWD: /etc/zabbix/custom-scripts.d/sas-raid-data.pl *',
    }
  }

  if($haproxy)
  {
    file { '/etc/zabbix/custom-scripts.d/haproxy-data.py':
      source  => 'puppet:///modules/zabbix/haproxy-data.py',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }

    file { '/etc/zabbix/custom-scripts.d/haproxy-discovery.py':
      source  => 'puppet:///modules/zabbix/haproxy-discovery.py',
      require => File['/etc/zabbix/custom-scripts.d/'],
    }
  }

  # declare relationships
  Class['sudo'] ->
  Class['zabbix::agent::params'] ->
  Class['zabbix::agent::install'] ->
  Class['zabbix::agent::config'] ->
  Class['zabbix::agent::service']
}

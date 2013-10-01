# Zabbix Module

This module will install and configure a Zabbix Server or Proxy or Agent, according to your wishes.

## Usage

### Minimal server configuration

```puppet
class { 'zabbix::server': }
```
This will do the typical install, configure and service management.
Preseed file is autofill using alkivi_base module which :
- search for mysql admin password in /root/.passwd/db/mysql
- create zabbix password in /root/.passwd/db/zabbix

### More server configuration

```puppet
class { 'zabbix::server':
  listenPort              => '10051',
  sourceIp                => undef,
  logFile                 => '/var/log/zabbix-server/zabbix_server.log',
  logFileSize             => undef,
  debugLevel              => '3',
  pidFile                 => '/var/run/zabbix-server/zabbix_server.pid',
  dBHost                  => 'localhost',
  dBName                  => 'zabbix',
  dBUser                  => 'zabbix',
  dBPassword              => 'CHANGEME',
  startPollers            => '5',
  startIPMIPollers        => '0',
  startPollersUnreachable => '1',
  startTrappers           => '5',
  startPingers            => '1',
  startDiscoverers        => '1',
  startHTTPPollers        => '1',
  listenIp                => undef,
  housekeepingFrequency   => '1',
  maxHousekeeperDelete    => '500',
  disableHousekeeping     => '0',
  senderFrequency         => '30',
  cacheSize               => '8M',
  cacheUpdateFrequency    => '60',
  startDBSyncers          => '4',
  historyCacheSize        => '8M',
  trendCacheSize          => '4M',
  historyTextCacheSize    => '16M',
  timeout                 => '5',
  trapperTimeout          => '300',
  unreachablePeriod       => '45',
  unavailableDelay        => '60',
  alertScriptsPath        => '/home/alkivi/zabbix/alert-scripts/',
  externalScripts         => '/home/alkivi/zabbix/external-scripts',
  fpingLocation           => '/usr/bin/fping',
  fping6Location          => '/usr/sbin/fping6',
  motd                    => true,
}
```
Please consult the Zabbix documentation for explanations on configuration options: https://www.zabbix.com/documentation/2.0/manual/appendix/config/zabbix_server


### Proxy configuration

```puppet
class { 'zabbix::proxy':
  hostname => 'flamagine.alkivi.fr',
}
```

### More Proxy configuration

```puppet
class { 'zabbix::proxy':
  hostname                => 'flamagine.alkivi.fr',
  server                  => 'zabbix.alkivi.fr',
  serverPort              => '10051',
  startPollers            => '5',
  startIPMIPollers        => '0',
  startPollersUnreachable => '1',
  startTrappers           => '5',
  startPingers            => '1',
  startDiscoverers        => '1',
  startHTTPPollers        => '1',
  listenPort              => '10051',
  heartbeatFrequency      => '60',
  configFrequency         => '3600',
  housekeepingFrequency   => '1',
  senderFrequency         => '30',
  proxyLocalBuffer        => '0',
  proxyOfflineBuffer      => '1',
  debugLevel              => '3',
  timeout                 => '5',
  trapperTimeout          => '5',
  unreachablePeriod       => '45',
  unavailableDelay        => '60',
  pidFile                 => '/var/run/zabbix-proxy/zabbix_proxy.pid',
  logFile                 => '/var/log/zabbix-proxy/zabbix_proxy.log',
  alertScriptsPath        => '/home/alkivi/zabbix/alert-scripts/',
  externalScripts         => '/home/alkivi/zabbix/external-scripts',
  fpingLocation           => '/usr/bin/fping',
  fping6Location          => '/usr/sbin/fping6',
  tmpDir                  => '/tmp',
  pingerFrequency         => '60',
  dBHost                  => 'localhost',
  dBName                  => 'zabbix',
  dBUser                  => 'zabbix',
  dBPassword              => 'CHANGEME',

  sourceIp                => undef,
  listenIp                => undef,
  logFileSize             => undef,

  motd                    => true,
}
```

Please consult the Zabbix documentation for explanations on configuration options: https://www.zabbix.com/documentation/2.0/manual/appendix/config/zabbix_proxy

### Agent configuration

```puppet
class { 'zabbix::agent':
  hostname => 'web.alkivi.fr',
}
```

### More Agent configuration

```puppet
class { 'zabbix::agent':
  logFile      => '/var/log/zabbix-agent/zabbix_agent.log',
  logFileSize  => undef,
  debugLevel   => '3',
  server       => ['127.0.0.1'],
  serverActive => ['127.0.0.1'],
  raid         => false,
  mysql        => false,
  smart        => true,
  backuppc     => false,
  ups          => false,
  motd         => true,
}
```

raid, mysql, smart, backuppc, ups are boolean that trigger the installation of custom scripts to monitoring.
Check our github page, zabbix module will be present (soon ...)

## Limitations

* This module has been tested on Debian Wheezy, Squeeze.

## License

All the code is freely distributable under the terms of the LGPLv3 license.

## Contact

Need help ? contact@alkivi.fr

## Support

Please log tickets and issues at our [Github](https://github.com/alkivi-sas/)

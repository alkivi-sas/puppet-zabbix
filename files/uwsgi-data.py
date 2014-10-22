#!/usr/bin/env python
# Based on https://gist.github.com/codeinthehole/7f60b011f969787a7fff

"""
Extract metrics from a uWSGI log file

This should be saved as /etc/zabbix/pluginx/uwsgi_stats and called from
/etc/zabbix/zabbix_agentd.conf.d/uwsgi.conf, which should have contents:

    UserParameter=uwsgi.stats[*],/etc/zabbix/plugins/uwsgi_stats $1 $2

To gather these metrics in Zabbix, create a new item which calls this plugin and 
passes the filepath and metric key.  Eg:

    uwsgi.stats[/var/log/client/project/logs/prod/uwsgi.log,req_count]

The available metric keys are:

 - req_count -> requests per minute
 - get_req_count -> GET requests per minute
 - post_req_count -> POST requests per minute
 - avg_req_time -> average request time in ms
 - avg_req_size -> average request size in bytes

Author: David Winterbottom
"""

import datetime
import subprocess
import re
import sys
import os
import json

HOST='127.0.0.1'
PORT='1717'

def extract_metric(metric):
    """Using url to get stats and then extract metric
    """

    # Extract data from access log using nc
    try:
        output = subprocess.Popen(
                ["nc", HOST, PORT], stdout=subprocess.PIPE).communicate()[0]
    except subprocess.CalledProcessError:
        return None
    data = json.loads(output)

    if metric in ['listen_queue', 'listen_queue_errors', 'load', 'pid', 'gid', 'uid']:
        if metric in data:
            return data[metric]
        else:
            return None

    if metric in  ['requests', 'delta_requests', 'exceptions', 'signals',
                    'static_offload_threads', 'rss', 'respawn_count', 'tx',
                    'avg_rt']:
        return compute_worker_average(data['workers'], metric)
    return None

def compute_worker_average(data, metric):
    """Take the average of workers in data
    """
    times = [int(x[metric]) for x in data]
    return float(sum(times)) / len(times)

def get_stat_url(app):
    """Parse file in /etc/uwsgi/apps-enabled
    """
    filename = os.path.join(BASE,app)
    if os.path.isfile(filename):
        for line in open(filename):
            if "stats" in line:
                url = line.split('=')[1]
                import re
                pattern = re.compile(r'\s+')
                url = re.sub(pattern, '', url)
                return url
    return None

if __name__ == '__main__':
    metric_key = sys.argv[1]
    metric = extract_metric(metric_key)
    if metric is not None:
        print metric
    else:
        exit(1)


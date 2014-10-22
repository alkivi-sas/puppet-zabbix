#!/usr/bin/python

""" Fetch HAProxy stats and send Low-Level Discovery to Zabbix

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

import urllib
from optparse import OptionParser
import os
from tempfile import mkstemp
import StringIO
import csv
import re
import json

class ErrorSendingValues(RuntimeError):
    """ An error occured while sending the values to the Zabbix 
    server using zabbix_sender. 
    """

def fetchURL(url, user = None, passwd = None):
    """ Return the data from a URL """
    if user and passwd:
        parts = url.split('://')
        url = parts[0] + "://" + user + ":" + passwd + "@" + parts[1]

    conn = urllib.urlopen(url)
    try:
        data = conn.read()
    finally:
        conn.close()
    return data

def sendValues(filepath, zabbixserver = "localhost", zabbixport = 10051, senderloc = "zabbix_sender"):
    r = os.system("%s --zabbix-server '%s' --port '%s' -i '%s' -vv" % (senderloc, zabbixserver, zabbixport, filepath))
    if r != 0:
        raise ErrorSendingValues, "An error occured sending the values to the server"

def parse(data):
    """ Parse the nginx status into a dict of data
    """
    csvobj = csv.reader(StringIO.StringIO(data))
    keys = csvobj.next()
    stats={
        'fe':{},
        'be':{},
        'sv':{}
    }
    while True :
        try:
            row = csvobj.next()
            pairs=zip( keys, row )
            dict={}
            for k,v in pairs:
                if k == '# pxname' :
                    k = 'pxname'
                if k != '' :
                    dict[k]=v
            if dict['pxname'] != 'stats' :
                if dict['svname'] == 'FRONTEND' :
                    stats['fe'].setdefault(dict['pxname'],{})[dict['svname']]=dict
                elif dict['svname'] == 'BACKEND' :
                    stats['be'].setdefault(dict['pxname'],{})[dict['svname']]=dict
                else :
                    stats['sv'].setdefault(dict['pxname'],{})[dict['svname']]=dict
        except StopIteration :
            break
    return stats
 
if __name__ == "__main__":
    parser = OptionParser(
                        usage = "%prog [-z <Zabbix hostname or IP>] [-o <Nginx hostname or IP>]",
                        version = "%prog $Revision$",
                        prog = "NginxStatsForZabbix",
                        description = """This program gathers data from nginx's
                                        built-in status page and sends it to 
                                        Zabbix. The data is sent via zabbix_sender. 
                                        Author: Robert Bridge, Paulson McIntyre (GpMidi)
                                        License: GPLv2
                        """,
                        )
    parser.add_option(
                      "-l",
                      "--url",
                      action = "store",
                      type = "string",
                      dest = "url",
                      default = None,
                      help = "Override the automatically generated URL with one of your own",
                      )
    parser.add_option(
                      "-o",
                      "--host",
                      action = "store",
                      type = "string",
                      dest = "host",
                      default = "localhost",
                      help = "Host to connect to. [default: %default]",
                      )
    parser.add_option(
                      "-p",
                      "--port",
                      action = "store",
                      type = "int",
                      dest = "port",
                      default = 80,
                      help = "Port to connect on. [default: %default]",
                      )
    parser.add_option(
                      "-r",
                      "--proto",
                      action = "store",
                      type = "string",
                      dest = "proto",
                      default = "http",
                      help = "Protocol to connect on. Can be http or https. [default: %default]",
                      )
    parser.add_option(
                      "-z",
                      "--zabbixserver",
                      action = "store",
                      type = "string",
                      dest = "zabbixserver",
                      default = "localhost",
                      )
    parser.add_option(
                      "-u",
                      "--user",
                      action = "store",
                      type = "string",
                      dest = "user",
                      default = None,
                      help = "HTTP authentication user to use when connection. [default: None]",
                      )
    parser.add_option(
                      "-a",
                      "--passwd",
                      action = "store",
                      type = "string",
                      dest = "passwd",
                      default = None,
                      help = "HTTP authentication password to use when connecting. [default: None]",
                      )
    parser.add_option(
                      "-s",
                      "--sender",
                      action = "store",
                      type = "string",
                      dest = "senderloc",
                      default = "/usr/bin/zabbix_sender",
                      help = "Location to the zabbix_sender executable. [default: %default]",
                      )
    parser.add_option(
                      "-q",
                      "--zabbixport",
                      action = "store",
                      type = "int",
                      dest = "zabbixport",
                      default = 10051,
                      help = "Zabbix port to connect to. [default: %default]",
                      )
    parser.add_option(
                      "-c",
                      "--zabbixsource",
                      action = "store",
                      type = "string",
                      dest = "zabbixsource",
                      default = "localhost",
                      help = "Zabbix host to use when sending values. [default: %default]",
                      )
    (opts, args) = parser.parse_args()
    if opts.url and (opts.port != 80 or opts.proto != "http"):
        parser.error("Can't specify -u with  -p or -r")

    if not opts.url:
        opts.url = "%s://%s:%s/haproxy?stats\;csv" % (opts.proto, opts.host, opts.port)

    data = fetchURL(opts.url, user = opts.user, passwd = opts.passwd)

    try:
        (tempfiled, tempfilepath) = mkstemp()
        tempfile = open(tempfilepath, 'wb')
    except:
        parser.error("Error creating temporary file")

    try:
        try:
            data = parse(data = data)
        except csv.Error:
            parser.error("Error parsing returned data")

        disc={}

        for k0 in data.keys() :
            """ k0 is the class of record, fe, be, or sv."""
            disc[k0]={'data':[]}
            for k1 in data[k0].keys() :
                """k1 is the proxy name."""
                for k2 in data[k0][k1] :
                    """k2 is the svname"""
                    disc[k0]['data'].append({"{#HASTAT}":k1+"-"+k2,"{#HAPX}":k1,"{#HASV}":k2})
        
        try:
            for k0 in disc.keys() :
                """k0 is the discovered record class"""
                tempfile.write("%s %s %s\n" % (opts.zabbixsource, 'haproxy.'+k0+'.discovery', json.dumps(disc[k0], sort_keys=True)))
#            for cls, clsdict in data.items() :
#                for px, pxdict in clsdict.items():
#                    for sv, svdict in pxdict.items() :
#                        for k, v in svdict.items() :
#                            if v != '' :
#                                tempfile.write("%s haproxy.%s[%s.%s.%s] %s\n" % (opts.zabbixsource, cls, px, sv, k, v))
            tempfile.close()
        except "bogus":
            parser.error("Error creating the file to send")

        try:
            sendValues(filepath = tempfilepath, zabbixserver = opts.zabbixserver, zabbixport = opts.zabbixport, senderloc = opts.senderloc)
        except ErrorSendingValues:
            parser.error("An error occurred while sending values to the Zabbix server")

    finally:
        try:
            tempfile.close()
        except:
            pass
        os.remove(tempfilepath)


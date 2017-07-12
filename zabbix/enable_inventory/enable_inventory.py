#!/usr/bin/env python

#import re
import os
import sys
import logging
import logging.config
import ConfigParser
#import json
#import simplejson as json
#from time import gmtime, strftime
import time
#from pprint import pprint
from pyzabbix import ZabbixAPI
from pyzabbix import ZabbixAPIException


####################################
# THIS SCRIPT REQUIRES             #
#                                  #
# aptitude install python-pip      #
# pip install pyzabbix             #
####################################

# JUST PRETTY TERMINAL COLORS
class bcolors:
  HEADER = '\033[95m'
  OKBLUE = '\033[94m'
  OKGREEN = '\033[92m'
  WARNING = '\033[93m'
  FAIL = '\033[91m'
  ENDC = '\033[0m'
  BOLD = '\033[1m'
  UNDERLINE = '\033[4m'


# GET DIR SCRIPT IS RUNNING FROM
# CHANGE THIS TO WHERE EVER YOU PUT THE CONFIGS
config_path = os.path.dirname(os.path.realpath(__file__))

# LOAD OPTIONS FROM CONFIG FILE
def get_config(filepath):
  logger.debug("get_config")
  config = ConfigParser.RawConfigParser()
  config.read('%s/zdh.conf' % (config_path))
  return config

#######
# MAIN
#######

now = int(time.time())
#print "NOW: %s" % now

# ENABLE LOGGING
logging.config.fileConfig('%s/logging.conf' % (config_path))
logger = logging.getLogger("zdh")
logger.debug("zabbix disable host v1.0")

# GET COMMAND LINE ARGUMENTS
argc = len(sys.argv)

if (argc != 3):
  get_status = False
  msg = "insufficient arguments"
  logger.fatal(msg)
  raise Exception(msg)

host_name = str(sys.argv[1])
host_invMode = str(sys.argv[2])

host_id = 11008
#host_id = str(host_id)

print "\n---------------------------"
print "host_name: %s" % host_name
print "host_invMode: %s" % host_invMode
print "---------------------------\n"

# GET LOCAL CONFIGURATION
config = get_config("zdh.conf")
server={}
server['url'] = config.get('server','url')
server['user'] = config.get('server','user')
server['password'] = config.get('server','password')
logger.debug("server     = '%s'" % server)


# LOGIN TO ZABBIX
zapi = ZabbixAPI(server['url'])
zapi.login(server['user'],server['password'])
logger.debug("connected to Zabbix API Version %s" % zapi.api_version())


#zapi.host.massupdate(hosts=hlookup,inventory_mode=invm)

#11008

if host_invMode == "auto": host_invMode=int(1)
elif host_invMode == "disabled": host_invMode=int(-1)
elif host_invMode == "manual": host_invMode=int('0')
else:
  msg = "Error: unknown inventory mode: %s" % host_invMode
  sys.exit(msg)

#hlookup.append({unicode('hostid'): unicode(hid)})
#host_payload = []
#host_payload.append({unicode('hostid'): unicode(host_id)})

host_payload = [{unicode('hostid'): unicode(host_id)}]
host_invMode = int(host_invMode)

#{"hostid": "11008","inventory_mode": 0},"auth": "c395cb8cc3add9f8733a479948fc81b6","id": 1}
try:
  print "SENDING: zapi.host.update(hostid=%s,inventory_mode=%s)\n" % (host_id,host_invMode)
  result = zapi.host.update(hostid=host_id,inventory_mode=host_invMode)
  #print result

  #print "\n========\n"
  #dump = zapi.host.get(output='extend',hostids=host_id)
  #print dump

except:
  sys.exit("Error: Something went wrong while performing the update\n")

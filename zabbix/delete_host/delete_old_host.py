#!/usr/bin/python

import re
import os
import sys
import logging
import logging.config
import ConfigParser
import json
import time
from pprint import pprint
from pyzabbix import ZabbixAPI
from pyzabbix import ZabbixAPIException


debug_me = False


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

if (argc != 2):
  get_status = False
  msg = "insufficient arguments"
  logger.fatal(msg)
  raise Exception(msg)

#host_name = str(sys.argv[1])
#days_back = int(sys.argv[2])

days_back = int(sys.argv[1])

if (debug_me == True):
  print "---------------------------"
  #print "host_name: %s" % host_name
  print "days_back: %s" % days_back
  print "---------------------------\n"


#logger.debug("host_name  = '%s'",host_name)
#logger.debug("new_status = '%i'",new_status)

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

#sys.exit

found_host=False

if (debug_me == True): print ""

for h in zapi.host.getobjects(status=1):

  ##################
  # JUST INFO
  #print bcolors.BOLD + "%s (%s) is %s\n" % (h['host'],h['hostid'],host_status_text) + bcolors.ENDC
  #for key, value in sorted(h.iteritems(), key=lambda (k,v): (v,k)):
    #print "%s: %s" % (key, value)
  #print ""
  #print "---------------------------\n"
  ##################

  #host_name = "ip-172-16-46-10"

  #if (str(h['host']) == host_name):
    found_host = True
    host_name = str(h['name'])
    host_status = int(h['status'])
    host_id = str(h['hostid'])

    if (host_status == 1): host_status_text = "disabled"
    if (host_status == 0): host_status_text = "enabled"

    if (debug_me == True):
      print bcolors.BOLD + "FOUND" + bcolors.ENDC + ": %s - %s (%s) - %s" % (found_host,host_name,h['host'],host_status_text)
      #print bcolors.BOLD + "FOUND" + bcolors.ENDC + ": %s - %s - %s\n" % (found_host,h['host'],host_status_text)

    result = zapi.host.get(
             withInventory=1,
             output=["date_hw_decomm"],
             hostids=host_id,
             selectInventory=["date_hw_decomm"]
             )

    if (debug_me == True): print "RESULT: %s" % result

    if (result):
      # reformat the JSON coming in from Zabbix
      newResult = re.sub('u\'','\"',str(result))
      newResult = re.sub('\'','\"',str(newResult))
      newResult = re.sub('\[|\]','',str(newResult))

      if (debug_me == True): print "NEWRESULT: %s" % newResult

      inventory = json.loads(newResult)
      for key, value in dict.items(inventory["inventory"]):
        if (key == "date_hw_decomm"):
          value = re.sub('.*\(|\).*','',str(value))
          value = int(value)

          if (debug_me == True):
            print "%s, %i" % (key,value)
            print "VALUE: %s - NOW: %s" % (value,now)

          if (value < now):
            diff = int((now - value) / 86400)

            if (diff > days_back):
              if (debug_me == True):
                print "I WOULD DELETE %s - days_back: %s - diff: %s" % (host_name,days_back,diff)
                print "---------------------------\n"
            else:
              if (debug_me == True):
                print "NO DELETE %s - days_back: %s - diff: %s" % (host_name,days_back,diff)
                print "---------------------------\n"
      found_host = False
    else:
      if (debug_me == True):
        print "%s has no inventory inforamtion.  SKIPPING..." % h['host']
        print "---------------------------\n"
      found_host = False

if (debug_me == True): print ""

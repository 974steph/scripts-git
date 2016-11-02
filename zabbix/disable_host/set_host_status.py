#!/usr/bin/python

import sys
import os
import time
import datetime
import logging
import logging.config
import ConfigParser
from pyzabbix import ZabbixAPI
from pyzabbix import ZabbixAPIException


debug_me = False


##########################################
# THIS SCRIPT REQUIRES                   #
#                                        #
# aptitude install python-pip            #
# pip install pyzabbix                   #
#                                        #
#                                        #
# WHAT I DO:                             #
#                                        #
# DISABLE REQUESTED HOST                 #
# ENABLE INVENTORY (disabled by defualt) #
# SET "serialno_b" TO EPOCH OF "NOW"     #
#                                        #
# SYNTAX                                 #
# ./set_host_status.py [HOST] [1|0]      #
# 1 == DISABLE HOST                      #
# 0 == ENABLE HOST                       #
##########################################

# GET DIR SCRIPT IS RUNNING FROM
# CHANGE THIS TO WHERE EVER YOU PUT THE CONFIGS
config_path = os.path.dirname(os.path.realpath(__file__))

#LOAD OPTIONS FROM CONFIG FILE
def get_config(filepath):
  logger.debug("get_config")
  config = ConfigParser.RawConfigParser()
  config.read('%s/zdh.conf' % (config_path))
  return config

#######
# MAIN
#######


#ENABLE LOGGING
logging.config.fileConfig('%s/logging.conf' % (config_path))
logger = logging.getLogger("zdh")
logger.debug("zabbix disable host v1.0")

#GET COMMAND LINE ARGUMENTS
argc = len(sys.argv)

#if (argc < 3):
if (argc < 2):
  get_status = False
  msg = "insufficient arguments"
  logger.fatal(msg)
  raise Exception(msg)
if (argc == 2):
  get_status = True
  do_reset = False
if (argc == 3):
  get_status = False
  if (sys.argv[2] == "reset"):
    do_reset = True
    new_status = int(0)
    status_text = "enabled"
  else:
    #status_text = int(sys.argv[2])
    #new_status = int(sys.argv[2])
    if (sys.argv[2] == "disable"):
      do_reset = False
      status_text = "disabled"
      new_status = int(1)
    else:
      do_reset = False
      status_text = "enabled"
      new_status = int(0)


host_name = sys.argv[1]

logger.debug("host_name  = '%s'",host_name)
#logger.debug("new_status = '%i'",new_status)

# NOW
#now = int(time.time())
epoch_now = int(time.time())
#epoch_now = int(1433131200)
pretty_now = datetime.datetime.fromtimestamp(epoch_now)
pattern = '%Y-%m-%d %H:%M:%S'
new_epoch = int(time.mktime(time.strptime(str(pretty_now), pattern)))

#print "EPOCH_NOW:: %s" % epoch_now
#print "PRETTY_NOW: %s" % pretty_now
#print "NEW_EPOCH: %s" % new_epoch


#GET LOCAL CONFIGURATION
config = get_config("zdh.conf")
server={}
server['url'] = config.get('server','url')
server['user'] = config.get('server','user')
server['password'] = config.get('server','password')
logger.debug("server     = '%s'" % server)


#LOGIN TO ZABBIX
zapi = ZabbixAPI(server['url'])
zapi.login(server['user'],server['password'])
logger.debug("connected to Zabbix API Version %s" % zapi.api_version())


found_host=False

for h in zapi.host.get(filter={"host": host_name}, output="extend"):
  if (h['host'] == host_name):
    found_host=True
    host_id = h['hostid']
    host_status = h['status']
    #msg = "host %s (%s) status is '%s'" % (h['host'],h['hostid'],h['status'])

    if (host_status == "1"): host_status_text = "disabled"
    if (host_status == "0"): host_status_text = "enabled"

    #logger.info("host_status_text: %s",host_status_text)

    try:

      if (do_reset == True):
        ##################
        # RESET HOST TO NORMAL

        # ENABLE MONITORING
        zapi.host.update(hostid=host_id, status=new_status)
        if (debug_me == True): print "%s (%s) is %s" % (h['host'],h['hostid'],host_status_text)
        # BLANK date_hw_decomm
        payload = {'date_hw_decomm': ""}
        result = zapi.host.update(hostid=host_id,inventory=payload)
        if (debug_me == True): print "Blanked date_hw_decomm on %s (%s)" % (host_name,host_id)
        # DISABLE INVENTORY
        host_invMode = int(-1)
        zapi.host.update(hostid=host_id,inventory_mode=host_invMode)
        if (debug_me == True): print "%s (%s) inventory has been disabled" % (host_name,host_id)

      elif (get_status == True):
        print "%s is %s" % (h['host'],host_status_text)
        sys.exit()

      else:

        ##################
        # DISABLE HOST
        try:

          zapi.host.update(hostid=host_id, status=new_status)
          #logger.info("host %s (%s) has been %s" % (host_name,host_id,status_text))
          if (debug_me == True): print "%s (%s) has been %s" % (host_name,host_id,status_text)

        except ZabbixAPIException as e:
          print(e)
          logger.error(e)
          sys.exit()

        ##################
        # ENABLE INVENTORY
        # 1: AUTO
        # 0: MANUAL
        # -1: DISABLED
        try:
          host_invMode = int(0)
          zapi.host.update(hostid=host_id,inventory_mode=host_invMode)
          if (debug_me == True): print "%s (%s) inventory has been enabled" % (host_name,host_id)

        except ZabbixAPIException as e:
          print(e)
          logger.error(e)
          sys.exit()

        ##################
        # WRITE EPOCH TO INVENTORY
        try:
          upn = unicode(pretty_now)
          uen =  unicode(epoch_now)
          payload = {'date_hw_decomm': upn +" ("+ uen +")"}
          #payload = {'date_hw_decomm': uen}
          result = zapi.host.update(hostid=host_id,inventory=payload)
          if (debug_me == True): print "Wrote \"%s (%s)\" to %s (%s)" % (pretty_now,epoch_now,host_name,host_id)

        except ZabbixAPIException as e:
          print(e)
          logger.error(e)
          sys.exit()

    except ZabbixAPIException as e:
      print(e)
      logger.error(e)
      sys.exit()
    break

if (found_host!=True):
  msg = "host %s not found" % host_name
  logger.error(msg)
  raise Exception(msg)


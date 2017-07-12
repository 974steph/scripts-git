#!/usr/bin/env python

####################################
# THIS SCRIPT REQUIRES             #
#                                  #
# aptitude install python-pip      #
# pip install pyzabbix             #
####################################


####################################
# SET TO TRUE FOR LOTS-O-OUTPUT
debug_me = False
####################################

import re
import os
import sys
import logging
import logging.config
import ConfigParser
import json
from pyzabbix import ZabbixAPI
from pyzabbix import ZabbixAPIException


# GET DIR SCRIPT IS RUNNING FROM
# CHANGE THIS TO WHERE EVER YOU PUT THE CONFIGS
config_path = os.path.dirname(os.path.realpath(__file__))

# LOAD OPTIONS FROM CONFIG FILE
def get_config(filepath):
  logger.debug("get_config")
  config = ConfigParser.RawConfigParser()
  config.read('%s/zdh.conf' % (config_path))
  return config

####################################
# SETUP

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
jmx_template_id = str(sys.argv[2])

#host_id = 11008
#host_id = str(host_id)

if ( debug_me == True):
  print "\n---------------------------"
  print "host_name: %s" % host_name
  print "jmx_template_id: %s" % jmx_template_id
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
####################################


####################################
# INITIAL VARS

template_list = []
jmx_exists = False
jmx_linked = False

# stuff to make debug json pretty to pipe to formatter
# | python -m json.tool
json_start="{\"jsonrpc\": \"2.0\", \"result\": ["
json_end="], \"id\": 1}"
####################################


####################################
# GET HOSTID FROM PROVIDED NAME
#

# list current zabbix interfaces
for h in zapi.host.get(filter={"host": host_name}, output="extend"):

  # if it's the requested host, get the ID#
  if (h['host'] == host_name):

    host_id = h['hostid']

    if ( debug_me == True ): print "%s is ID# %s\n" % (host_name, host_id)

  else:
    print "%s is not %s" % (h['hostid'],host_name)
####################################


####################################
# CREATE JMX INTERFACE IF NEEDED
#

for i in zapi.hostinterface.get(hostid=host_id, output="extend"):


  if ( i['hostid'] == host_id ):

    #get info from the agent interface
    if ( int(i['type']) == 1 ):
      zabb_dns = unicode(i['dns'])
      zabb_ip = unicode(i['ip'])
      zabb_main = unicode(i['main'])
      zabb_port = unicode(i['port'])
      zabb_useip = unicode(i['useip'])

    if ( debug_me == True ):
      print "\tzabb_dns: %s" % zabb_dns
      print "\tzabb_ip: %s" % zabb_ip
      print "\tzabb_main: %s" % zabb_main
      print "\tzabb_port: %s" % zabb_port
      print "\tzabb_useip: %s" % zabb_useip
      #print 

    if ( int(i['type']) == 4 ):
      jmx_exists = True
      if ( debug_me == True ): print "\tFound existing JMX Interface: %s" % jmx_exists


# create the JMX interface
#if ( i['type'] != 4 ):
if ( jmx_exists == False ):
  result=zapi.hostinterface.create(
    hostid=host_id,
    type=4,
    main=1,
    useip=1,
    ip=zabb_ip,
    dns=zabb_dns,
    port=8765)

  newResult = re.sub('u\'','\"',str(result))
  newResult = re.sub('\'','\"',str(newResult))
  newResult = re.sub('\[|\]','',str(newResult))

  if (debug_me == True): print "\tRESULT: %s" % newResult
  if (debug_me == True): print "JMX interface added to %s (%s) Skipping create...\n=========\n" % (host_name, host_id)

else:
  if (debug_me == True): print "JMX interface already exists for %s (%s) Skipping create...\n=========\n" % (host_name, host_id)
####################################



####################################
# LINK TEMPLATE
#
result = zapi.host.get(hostids=host_id,output='hostid',selectParentTemplates='templateid,name')

if ( debug_me == True ): print "\tresult: %s" % result

# CURRENT TEMPLATES
for t in zapi.host.get(
        hostids=host_id,
        output='hostid',
        selectParentTemplates='templateid,name'):


  for id in t['parentTemplates']:

    template_id = id['templateid']

    if ( debug_me == True ): print "\ttemplate_id %s" % template_id

    if ( template_id == jmx_template_id ):
      jmx_linked = True

      if ( debug_me == True ): print "JMX Template (%s) already linked to %s (%s) Skipping link...\n=========\n" % (template_id, host_name, host_id)

      sys.exit()

    else:
      template_list.append({'templateid': template_id})

# NEED JMX TEMPLATE
if ( jmx_linked != True ):

  if ( debug_me == True ): print "Linking JMX Template (%s) to %s (%s)\n=========\n" % (template_id, host_name, host_id)

  if ( len(template_list) == 0 ):
    template_list = "{'templateid': 10799}, {'templateid': 10001}"

    if ( debug_me == True ): print "\tBUILT template_list %s" % str(template_list)

  else:
    template_list.append({'templateid': jmx_template_id})

    if ( debug_me == True ): print "\tEXIST template_list %s" % str(template_list)

  if ( debug_me == True ): print "\t template_list: %s" % template_list

  payload = {
    'output': 'extend',
    'hostid': host_id,
    'templates': template_list}

  if ( debug_me == True ): print "\tPAYLOAD: %s" % payload

  result = zapi.host.update(payload)

  if ( debug_me == True ):
    print "\tresult: %s" % result
    print "\ttemplate_list: %s" % template_list
    print "JMX Template (%s) linked to %s (%s)\n=========\n" % (template_id, host_name, host_id)
    #print len(template_list)

sys.exit()

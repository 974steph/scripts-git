from pyzabbix import ZabbixAPI

zapi = ZabbixAPI("http://zabbix.use1dev1.zonoff.io")
zapi.login("zabbix user", "zabbix pass")
print "Connected to Zabbix API Version %s" % zapi.api_version()

for h in zapi.host.get(output="extend"):
    print h['hostid']

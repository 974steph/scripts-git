#!/bin/sh
# this script updates the dynamic ip on http://freedns.afraid.org/ using curl
# check http://freedns.afraid.org/api/ and as weapon ASCII for the phrase in UPDATE_URL


source $HOME/Sources/scripts-git/secret_stuff.sh

#UPDATE_URLS="${UN}world,http://freedns.afraid.org/dynamic/update.php?TG82eFJDVWQ4OUhmYkhXTXkxZm9CVE9BOjExNDczNzg5 \
#	shoveitinstorage,https://freedns.afraid.org/dynamic/update.php?TG82eFJDVWQ4OUhmYkhXTXkxZm9CVE9BOjE1OTMxMjA5"

UPDATE_URLS="combined,http://freedns.afraid.org/dynamic/update.php?TG82eFJDVWQ4OUhmYkhXTXkxZm9CVE9BOjExNDczNzg5"

case $1 in
	debug)	DEBUG="yes";;
	force)	FORCE="yes";;
esac


function ExternalIP() {

	[ ${DEBUG} ] && echo "Getting CURRENT_IP"

# 	CURRENT_IP=$(wget http://ipinfo.io/ip -qO -)
#	CURRENT_IP=$(curl -s http://ipinfo.io/ip)
	CURRENT_IP=$(upnpc -s | awk '/External/ {print $3}')
# 	CURRENT_IP=$(curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//')

	[ ${DEBUG} ] && echo "CURRENT_IP: ${CURRENT_IP}"
}


function UpdateIP() {

	/usr/bin/curl -s "$1"
	UPDATE_TRAP=$?

	if [ ${UPDATE_TRAP} -ne 0 ] ; then
		echo "Failed to update ${DOMAIN}"
	else
		echo ${CURRENT_IP} > ${PREVIOUS_IP_FILE}
	fi
}


ExternalIP


for UPDATE_URL in ${UPDATE_URLS} ; do

	DOMAIN=$(echo ${UPDATE_URL} | cut -d, -f1)
	URL=$(echo ${UPDATE_URL} | cut -d, -f2)

	PREVIOUS_IP_FILE="/var/tmp/$(basename $0 | sed 's/\.sh$//')-${DOMAIN}"

	[ ${DEBUG} ] && echo "PREVIOUS_IP_FILE: ${PREVIOUS_IP_FILE}"

	if [ -f ${PREVIOUS_IP_FILE} ] ; then
		PREVIOUS_IP=$(cat ${PREVIOUS_IP_FILE})
	else
		PREVIOUS_IP="UNKNOWN"
	fi

	[ ${DEBUG} ] && echo "PREVIOUS_IP: ${PREVIOUS_IP}"

	if [ ! "${CURRENT_IP}" == "${PREVIOUS_IP}" ] ; then
		UpdateIP ${URL}
	else
		[ ${DEBUG} ] && echo "External IP not changed: ${CURRENT_IP} == ${PREVIOUS_IP}"

		[ ${FORCE} ] && UpdateIP ${URL}
	fi
done

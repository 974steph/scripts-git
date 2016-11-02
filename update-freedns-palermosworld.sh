#!/bin/sh
# this script updates the dynamic ip on http://freedns.afraid.org/ using curl
# check http://freedns.afraid.org/api/ and as weapon ASCII for the phrase in UPDATE_URL


OLDIP_FILE="/var/tmp/$(basename $0 | sed 's/\.sh$//')"

#CHECK_CMD="/usr/bin/curl -s http://ip.dnsexit.com/ | sed -e 's/ //'"
CHECK_CMD="wget http://ipinfo.io/ip -qO -"
UPDATE_URL="http://freedns.afraid.org/dynamic/update.php?TG82eFJDVWQ4OUhmYkhXTXkxZm9CVE9BOjExNDczNzg5"
UPDATE_COMMAND="/usr/bin/curl -s $UPDATE_URL"

case $1 in
	debug) DEBUG="yes";;
esac

[ ${DEBUG} ] && echo "Getting current IP"
CURRENTIP=`${CHECK_CMD}`
[ ${DEBUG} ] && echo "Found ${CURRENTIP}"

if [ ! -e "${OLDIP_FILE}" ] ; then
	[ ${DEBUG} ] && echo "Creating ${OLDIP_FILE}"
	echo "0.0.0.0" > "${OLDIP_FILE}"
fi

OLDIP=`cat ${OLDIP_FILE}`

if [ "${CURRENTIP}" != "${OLDIP}" ] ; then
	[ ${DEBUG} ] && echo "Issuing update command"
	${UPDATE_COMMAND}
fi

[ ${DEBUG} ] && echo "Saving IP"
echo "${CURRENTIP}" > "${OLDIP_FILE}"

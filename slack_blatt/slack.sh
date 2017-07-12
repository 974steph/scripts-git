#!/usr/bin/env bash

TZ="US/Eastern"

###########################
# YOU BROKE IT

if [ ! "$1" -o ! "$2" ] ; then
	echo -e "\\nUsage: $(basename $0) [TITLE] [BODY]\\n"
	echo -e "all options: $(basename $0) [TITLE] [BODY] [ICON] [CHANNEL] [USERNAME] [ok/warn/crit]\\v"
	exit 1
else
	TITLE="$1"
	TEXT="$2"
fi
###########################


###########################
# CLOCK
function clockEmoji() {
	NOW=$(date +%s)

	HOUR=$(TZ=${TZ} date -d @${NOW} +%-I)
	MINS=$(TZ=${TZ} date -d @${NOW} +%M)

	[ ${MINS} -ge 30 ] && CMIN=30

	echo ":clock${HOUR}${CMIN}:"
}
###########################


###########################
# CHANGE ICON

if [ "$3" ] ; then

	EMOJI=$(echo "$3" | tr [':upper:'] [':lower:'])

	case ${EMOJI} in
		clock)  EMOJI=$(clockEmoji);;
		*)      EMOJI=":${EMOJI}:";;
	esac
else
	EMOJI=':boom:'
fi
###########################


###########################
# DESTINATION CHANNEL

if [ "$4" ] ; then
	CHANNEL="#$4"
else
#	CHANNEL='#production-alerts'
	CHANNEL='#alerts-warning'
#	CHANNEL='#alerts-beta'
fi
###########################


###########################
# FROM NAME
if [ "$5" ] ; then
	USERNAME="$5"
else
	USERNAME='Video Services'
fi
###########################


###########################
# COLOR LEVEL

[ "$6" ] && LEVEL=$(echo "$6" | tr [':upper:'] [':lower:'])

case "$LEVEL" in
	ok)     COLOR="00c900";;
	warn)   COLOR="ff8300";;
	crit)   COLOR="ff0000";;
	*)      COLOR="00a600";;
esac
###########################


###########################
# THE STUFF

FALLBACK="*${TITLE}*\n\n${TEXT}"

#ATTACHMENT="{\"title\":\"${TITLE}\", \"text\":\"${TEXT}\", \"fallback\":\"${FALLBACK}\", \"mrkdwn_in\":[\"title\", \"text\", \"fallback\"]}"
ATTACHMENT="{\"title\":\"${TITLE}\", \
	\"color\":\"#${COLOR}\", \
	\"text\":\"${TEXT}\", \
	\"fallback\":\"${FALLBACK}\", \
	\"mrkdwn_in\":[\"title\", \"text\", \"fallback\"]}"

PAYLOAD="payload={\"channel\":\"${CHANNEL}\", \"username\":\"${USERNAME}\", \"icon_emoji\":\"${EMOJI}\", \"attachments\":[${ATTACHMENT}]}"

#echo -e \\v"=========\\n$PAYLOAD\\n========\\v"

/usr/bin/curl -s -X POST --data-urlencode "${PAYLOAD}" "https://hooks.slack.com/services///"

#/usr/local/bin/mail_log.php
###########################

#!/bin/sh

case $1 in
	debug)	DEBUG="yes";;
	*)	S="s"
		Q="--quiet"
		;;
esac

NOW=$(date +%s)

FINAL_IMG="$(date -d @${NOW} +%Y%m%d_%H%M%S).jpg"

URL_CAM="http://67.210.198.15:8081"

TAR_PAN="1580"
TAR_TILT="0"
TAR_ZOOM="44"

TANK="$HOME/Pictures/Mountain North Sister"

#UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"
#UA="$(curl -sL "https://techblog.willshouse.com/2012/01/03/most-common-user-agents/" | grep -i "^Mozilla" | shuf -n1)"
UA="$(curl -sL "https://udger.com/resources/ua-list/browser-detail?browser=Chrome" | awk '/Useragentstring example/,/<\/td><\/tr>/' | sed 's/<[^>]\+>/ /g;s/ \+/ /g;s/.*Useragentstring example.*//' | egrep -v "^$|^ $" | shuf | head -n1)"

SLEEP=5

function SaveCurrent() {

	[ ${DEBUG} ] && echo "SAVE CURRENT"

	eval $(curl -A "${UA}" -G${S} "${URL_CAM}/cgi-bin/absget" | egrep "PAN|TILT|ZOOM" | sed "s/&nbsp//" | tr \\r\\n \\n)

	PREV_ZOOM=${ZOOM}
	PREV_PAN=${PAN}
	PREV_TILT=${TILT}

	if [ ! "${PAN}" -o ! "${TILT}" -o ! "${ZOOM}" ] ; then

		[ ${DEBUG} ] && echo "Failed to get and save current cam info.  Sleeping and trying again."
		sleep ${SLEEP}
		SaveCurrent
	fi

	if [ ${DEBUG} ] ; then
		echo "PREV_PAN: ${PREV_PAN}"
		echo "PREV_TILT: ${PREV_TILT}"
		echo "PREV_ZOOM: ${PREV_ZOOM}"
		echo "---------"
	fi
}

function MoveCam() {

	[ ${DEBUG} ] && echo -e "MOVE\\n---------"

#	curl -LGs "${URL_CAM}/cgi-bin/absctrl" -d zoom=${TAR_ZOOM} -d pan=${TAR_PAN} -d tilt=${TAR_TILT}
	curl -A "${UA}" -G${S} "${URL_CAM}/cgi-bin/absctrl" -d zoom=${TAR_ZOOM} -d pan=${TAR_PAN} -d tilt=${TAR_TILT}

	[ ${DEBUG} ] && echo "${URL_CAM}/cgi-bin/absctrl -d zoom=${TAR_ZOOM} -d pan=${TAR_PAN} -d tilt=${TAR_TILT}"
}


function CheckCurrent() {

	[ ${DEBUG} ] && echo CheckCurrent

	RESPONSE=$(curl -A "${UA}" -G${S} "${URL_CAM}/cgi-bin/absget")
	eval $(echo "${RESPONSE}" | egrep "PAN|TILT|ZOOM" | sed "s/&nbsp//" | tr \\r\\n \\n)


	if [ ! "${PAN}" -o ! "${TILT}" -o ! "${ZOOM}" ] ; then
		sleep ${SLEEP}
		CheckCurrent
	fi

	if [ ! "${PAN}" -eq "${TAR_PAN}" -o ! "${TILT}" -eq "${TAR_TILT}" -o ! "${ZOOM}" -eq "${TAR_ZOOM}" ] ; then

		if [ ${DEBUG} ] ; then
			echo "PAN - HAVE: ${PAN} | WANT: ${TAR_PAN}"
			echo "TILT - HAVE: ${TILT} | WANT: ${TAR_TILT}"
			echo "ZOOM - HAVE: ${ZOOM} | WANT: ${TAR_ZOOM}"
			echo -e "WAITING\\n---------"
		fi

		sleep ${SLEEP}

		CheckCurrent
	else

		if [ ${DEBUG} ] ; then
			echo "PAN - HAVE: ${PAN} | WANT: ${TAR_PAN}"
			echo "TILT - HAVE: ${TILT} | WANT: ${TAR_TILT}"
			echo "ZOOM - HAVE: ${ZOOM} | WANT: ${TAR_ZOOM}"
			echo -e "TAKE PIC!"
		fi

		wget ${Q} -O "${TANK}/${FINAL_IMG}" "${URL_CAM}/cgi-bin/camera?resolution=1024"
	fi
}


function ResetCam() {

	[ ${DEBUG} ] && echo RESET
	curl -A "${UA}" -G${S} "${URL_CAM}/cgi-bin/absctrl" -d zoom=${PREV_ZOOM} -d pan=${PREV_PAN} -d tilt=${PREV_TILT}
}



SaveCurrent

MoveCam

CheckCurrent

ResetCam

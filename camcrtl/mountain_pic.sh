#!/bin/sh

# DEBUG="yes"

NOW=$(date +%s)

FINAL_IMG="$(date -d @${NOW} +%Y%m%d_%H%M%S).jpg"

URL_CAM="http://67.210.198.15:8081"

TAR_PAN="1580"
TAR_TILT="0"
TAR_ZOOM="44"

TANK="$HOME/Mountain"

#WEATHER=$(curl -s "http://forecast.weather.gov/MapClick.php?lat=44.0583&lon=-121.314&unit=0&lg=english&FcstType=dwml" | xmllint --nowrap --noblanks --format - | sed -n '/data type="current observations"/,$p' | grep "weather-summary" | sed 's/.*"\(.*\)".*/\1/')

function SaveCurrent() {

	[ ${DEBUG} ] && echo "SAVE CURRENT"

	eval $(curl -GLs "${URL_CAM}/cgi-bin/absget" | egrep "PAN|TILT|ZOOM" | sed "s/&nbsp//" | tr \\r\\n \\n)

	PREV_ZOOM=${ZOOM}
	PREV_PAN=${PAN}
	PREV_TILT=${TILT}

	if [ ${DEBUG} ] ; then
		echo "PREV_PAN: ${PREV_PAN}"
		echo "PREV_TILT: ${PREV_TILT}"
		echo "PREV_ZOOM: ${PREV_ZOOM}"
	fi
}

function MoveCam() {

	[ ${DEBUG} ] && echo MOVE

	curl -LGs "${URL_CAM}/cgi-bin/absctrl" -d zoom=${TAR_ZOOM} -d pan=${TAR_PAN} -d tilt=${TAR_TILT}
}


function CheckCurrent() {

	[ ${DEBUG} ] && echo CheckCurrent

	eval $(curl -GLs "${URL_CAM}/cgi-bin/absget" | egrep "PAN|TILT|ZOOM" | sed "s/&nbsp//" | tr \\r\\n \\n)

	if [ ${DEBUG} ] ; then
		echo "PAN: \"${PAN}\""
		echo "TILT: \"${TILT}\""
		echo "ZOOM: \"${ZOOM}\""
	fi

#	if [ ! ${PAN} -eq ${TAR_PAN} -a ! ${TILT} -eq ${TAR_TILT} -a ! ${ZOOM} -eq ${TAR_ZOOM} ] ; then
	if [ ! ${PAN} -eq ${TAR_PAN} -o ! ${TILT} -eq ${TAR_TILT} -o ! ${ZOOM} -eq ${TAR_ZOOM} ] ; then

		[ ${DEBUG} ] && echo "WAITING"

		sleep 2

		unset PAN
		unset TILT
		unset ZOOM

		CheckCurrent
	else

		[ ${DEBUG} ] && echo "TAKE PIC"
		[ ! ${DEBUG} ] && Q="--quiet"

		wget ${Q} -O "${TANK}/${FINAL_IMG}" "${URL_CAM}/cgi-bin/camera?resolution=1024"
	fi
}


function ResetCam() {

	[ ${DEBUG} ] && echo RESET
	curl -LGs "${URL_CAM}/cgi-bin/absctrl" -d zoom=${PREV_ZOOM} -d pan=${PREV_PAN} -d tilt=${PREV_TILT}
}



SaveCurrent

MoveCam

CheckCurrent

ResetCam

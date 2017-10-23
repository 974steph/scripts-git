#!/bin/sh

function giveFeedback() {

	NAME="$1"
	EC="$2"

	if [ "${EC}" -gt 0 ] ; then
		echo "${NAME} failed to update: ${EC}"
	else
		echo "${NAME} updated."
	fi

	unset TRAP
}


#SUNRISE - OLD MILL
MILL="67.210.198.15:7271/cgi-bin"
curl -Gs ${MILL}/absctrl -d zoom=22 -d pan=1950 -d tilt=30
TRAP=$?
giveFeedback "Mill" ${TRAP}
#echo "Mill: $(curl -Gs ${MILL}/absget | grep ^[A-Z] | awk -F\& '{print $1}' | tr \\n " ")"


#SUNRISE - PAVILION
PAVILION="67.210.198.15:8919/cgi-bin"
curl -Gs ${PAVILION}/absctrl -d zoom=14 -d pan=2450 -d tilt=0
TRAP=$?
giveFeedback "Pavilion" ${TRAP}
#echo "Pavilion: $(curl -Gs ${PAVILION}/absget | grep ^[A-Z] | awk -F\& '{print $1}' | tr \\n " ")"


#SUNRISE - RIVER PARK
RIVER_PARK="67.210.198.15:9092/cgi-bin"
curl -Gs ${RIVER_PARK}/absctrl -d zoom=10 -d pan=2840 -d tilt=0
TRAP=$?
giveFeedback "RiverPark" ${TRAP}
#echo "River Park: $(curl -Gs ${RIVER_PARK}/absget | grep ^[A-Z] | awk -F\& '{print $1}' | tr \\n " ")"

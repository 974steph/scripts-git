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


# SUNSET - DOWNTOWN
DOWNTOWN="67.210.198.15:8081/cgi-bin"
curl -GLs ${DOWNTOWN}/absctrl -d zoom=10 -d pan=1300 -d tilt=0
TRAP=$?
giveFeedback "Downtown" ${TRAP}
#echo "Downtown: $(curl -Gs ${DOWNTOWN}/absget | grep ^[A-Z] | awk -F\& '{print $1}' | tr \\n " ")"

# SUNSET - BPRD
#BPRD="67.204.164.159:9293/cgi-bin"
#curl -GLs ${BPRD}/absctrl -d zoom=10 -d pan=1890 -d tilt=50
#TRAP=$?
#giveFeedback "BPRD" ${TRAP}
#echo "BPRD: $(curl -Gs ${BPRD}/absget | grep ^[A-Z] | awk -F\& '{print $1}' | tr \\n " ")"

# SUNSET - PAVILION
PAVILION="67.210.198.15:8919/cgi-bin"
curl -GLs ${PAVILION}/absctrl -d zoom=15 -d pan=600 -d tilt=0
TRAP=$?
giveFeedback "Pavilion" ${TRAP}
#echo "Pavilion: $(curl -Gs ${PAVILION}/absget | grep ^[A-Z] | awk -F\& '{print $1}' | tr \\n " ")"


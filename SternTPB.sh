#!/usr/bin/env bash

#DEBUG="yes"

case $1 in
	[0-9]*-[0-9]*-[0-9]*)
		DATE=$1
		;;
	check)
		CHECK=TRUE
		if [ $2 ] ; then
			DATE=$2
		else
			DATE=$(date +%Y-%m-%d)
		fi
		;;
	*)
		DATE=$(date +%Y-%m-%d)
		;;
esac

MAG_DATE_WORD=$(date -d ${DATE} +%b.%-d.%Y)
MAG_DATE_NUM=$(date -d ${DATE} +%-m.%d.%Y)
MAG_DATE_LWORD=$(date -d ${DATE} +%Y\.%B\.%d)
MAG_DATE_LEADING=$(date -d ${DATE} +%b.%d.%Y)

GOING=$(ps ax | egrep -i "${MAG_DATE_LEADING}|${MAG_DATE_LWORD}|${MAG_DATE_NUM}|${MAG_DATE_WORD}" | grep -v grep)

if [ "${GOING}" ] ; then
	echo "Already downloading ${DATE}.  Bailing..."
	echo "${GOING}"
	exit
fi

UA="Mozilla/5.0 (Linux; Android 6.0; XT1585 Build/MCK24.78-13.12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.89 Mobile Safari/537.36"

URL="https://m.thepiratebay.org"

SEARCH_URL="${URL}/search/howard+stern/0/100/0"

[ ${DEBUG} ] && echo -e "\\vcurl -sL \"${SEARCH_URL}\""
[ ${CHECK} ] && echo -e "\\vcurl -sL \"${SEARCH_URL}\""

if [ ${DEBUG} ] ; then
	echo -e "========="
	echo "MAG_DATE_WORD: $MAG_DATE_WORD"
	echo "MAG_DATE_LWORD: $MAG_DATE_LWORD"
	echo "MAG_DATE_NUM: $MAG_DATE_NUM"
	echo "MAG_DATE_LEADING: $MAG_DATE_LEADING"
	echo "SEARCH: Howard+Stern+Show+${MAG_DATE_WORD}"
	echo "ACTUAL: Howard+Stern+Show+AUG+9+2016+Tue"
	echo "egrep -i \"${MAG_DATE_LEADING}|${MAG_DATE_LWORD}|${MAG_DATE_NUM}|${MAG_DATE_WORD}\""
	echo -e "========="
fi

function findbest() {

	SAVE_IFS=$IFS
	IFS=$'\n'

	for POSSIBLE in ${POSSIBLES} ; do

		BITRATE=$(echo "${POSSIBLE}" | sed 's/.*+\([0-9]\+\)[kK]+.*/\1/')

		if [ ! "$(echo ${BITRATE} | grep [a-zA-Z])" ] ; then

			[ ! ${BESTBIT} ] && BESTBIT=${BITRATE}

			if [ ${BITRATE} -ge ${BESTBIT} ] ; then
				[ ${DEBUG} ] && echo "Updating BESTBIT to: ${BITRATE}"
				BESTBIT="${BITRATE}"
				BESTMAG="${POSSIBLE}"
				[ ${DEBUG} ] && echo "IF BESTBIT: $BESTBIT || BITRATE: $BITRATE"
			else
				[ ${DEBUG} ] && echo "ELSE BESTBIT: $BESTBIT || BITRATE: $BITRATE"
			fi
		else
			[ ${DEBUG} ] && echo "NOT FOUND: ${BITRATE}"
			FALLBACK="${POSSIBLE}"
		fi
	done

	IFS=${SAVEIFS}

	if [ "${BESTMAG}" -a "${BESTBIT}" ] ; then
		echo -e  "\\vFound the best bitrate: ${BESTBIT}k"
		MAG_RAW="${BESTMAG}"
	else
		echo -e "\\vNo bitrates found.  Using fallback..."
		MAG_RAW="${FALLBACK}"
	fi

	[ ${DEBUG} ] && echo -e "\\v${MAG_RAW}\\n"
#	echo -e "\\v${MAG_RAW}\\n"

	MAG_PRETTY=$(echo "${MAG_RAW}" | sed 's/&amp;tr=.*//g;s/^.*dn=\(.*\)/\1/;s/+/ /g')
	echo "Using: ${MAG_PRETTY}"
}


RESULTS=$(curl -sL -A "${UA}" "${SEARCH_URL}" | grep magnet:)

#POSSIBLES=$(echo ${RESULTS} | tidy - 2>/dev/null | egrep -i "Howard.*Stern.*${MAG_DATE_LEADING}|Howard.*Stern.*${MAG_DATE_LWORD}|Howard.*Stern.*${MAG_DATE_NUM}|Howard.*Stern.*${MAG_DATE_WORD}")
POSSIBLES=$(echo ${RESULTS} | tidy - 2>/dev/null | egrep -i "${MAG_DATE_LEADING}|${MAG_DATE_LWORD}|${MAG_DATE_NUM}|${MAG_DATE_WORD}" | sed 's/"//g')

if [ "${POSSIBLES}" ] ; then

	echo -e "\\vShow for ${DATE} available!"

	findbest

	[ ${CHECK} ] && exit 0

	$HOME/Sources/scripts-git/TransManually "${MAG_RAW}" tail

else
	echo -e \\v"Nothing found for ${DATE}."\\v
fi

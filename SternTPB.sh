#!/usr/bin/env bash

DEBUG="yes"

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

TMPFILE="/tmp/$(basename $0).tmp"
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

SEARCH_URL="${URL}/search/howard+stern/0/3/0"
#SEARCH_URL="${URL}/search/howard+stern/0/10/0"

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
	echo "SEARCH_URL: $SEARCH_URL"
	echo "egrep -i \"${MAG_DATE_LEADING}|${MAG_DATE_LWORD}|${MAG_DATE_NUM}|${MAG_DATE_WORD}\""
	echo -e "========="
fi

function findbest() {

	SAVE_IFS=$IFS
	IFS=$'\n'

	for POSSIBLE in ${POSSIBLES} ; do

		BITRATE=$(echo "${POSSIBLE}" | sed 's/.*+\([0-9]\+\)[kK]+.*/\1/')
		MAGID=$(echo "${POSSIBLE}" | sed 's/^.*btih:\(.*\)&amp;dn=.*/\1/')
		[ ${DEBUG} ] && echo "MAGID: $MAGID"

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
			[ ${DEBUG} ] && echo "NO BITRATE FOUND: ${BITRATE}"
			FALLBACK="${POSSIBLE}"
		fi

		[ ${DEBUG} ] && echo "---------"
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

function bestbit() {
	[ ! ${BESTBIT} ] && BESTBIT=${MAG_BITRATE}

	if [ ${MAG_BITRATE} -ge ${BESTBIT} ] ; then
		[ ${DEBUG} ] && echo "Updating BESTBIT to: ${MAG_BITRATE}"
		BESTBIT=${MAG_BITRATE}
		BESTBITUID=${MAG_UID}
#		echo BESTBITUID: ${MAG_UID}
		BESTBITMAG=${POSSIBLE}
		[ ${DEBUG} ] && echo "IF BESTBIT: $BESTBIT || MAG_BITRATE: $MAG_BITRATE"
	else
		[ ${DEBUG} ] && echo "ELSE BESTBIT: $BESTBIT || MAG_BITRATE: $MAG_BITRATE"
	fi
}

function bestsize() {
	[ ! ${BESTSIZE} ] && BESTSIZE=${MAG_SIZE}

	if [ ${MAG_SIZE} -ge ${BESTSIZE} ] ; then
		[ ${DEBUG} ] && echo "Updating BESTSIZE to: ${MAG_SIZE}"
		BESTSIZE=${MAG_SIZE}
		BESTSIZEUID=${MAG_UID}
		BESTSIZEMAG=${POSSIBLE}
		[ ${DEBUG} ] && echo "IF BESTBIT: $BESTSIZE || MAG_SIZE: $MAG_SIZE"
	else
		[ ${DEBUG} ] && echo "ELSE BESTSIZE: $BESTSIZE || MAG_SIZE: $MAG_SIZE"
	fi
}

function magstats() {

	SAVE_IFS=$IFS
	IFS=$'\n'

	for POSSIBLE in ${POSSIBLES} ; do

		MAG_UID=$(echo "${POSSIBLE}" | sed 's/^.*btih:\(.*\)&amp;dn=.*/\1/')
		MAG_BITRATE=$(echo "${POSSIBLE}" | sed 's/.*+\([0-9]\+\)[kK]+.*/\1/')
		[ "$(echo ${MAG_BITRATE} | grep [a-zA-Z])" ] && MAG_BITRATE=0
#		MAG_SIZE=$(curl -sL "${SEARCH_URL}" | grep -A2 -i "${MAG_UID}" | grep Size | sed 's/^.*Size \(.*\)\..*&nbsp\;MiB.*/\1/')
		MAG_SIZE=$(grep -A2 -i "${MAG_UID}" ${TMPFILE} | grep Size | sed 's/^.*Size \(.*\)\..*&nbsp\;MiB.*/\1/')

		if [ ${DEBUG} ] ; then
			echo "MAG_UID: \"$MAG_UID\""
			echo "MAG_BITRATE: \"$MAG_BITRATE\""
			echo "MAG_SIZE: \"$MAG_SIZE\""
#			echo "---------"
		fi

		bestbit

		bestsize

		if [ ${DEBUG} ] ; then
			echo "BESTBITUID: $BESTBITUID"
			echo "BESTBITMAG: $BESTBITMAG"
			echo "BESTBIT: $BESTBIT"
			echo "~~~~~~~~~"
			echo "BESTSIZEUID: $BESTSIZEUID"
			echo "BESTSIZEMAG: $BESTSIZEMAG"
			echo "BESTSIZE: $BESTSIZE"
		fi

	done

#		if [ ! ${BESTMAG} ] ; then
			if [[ "${BESTSIZEUID}" == "${BESTBITUID}" ]] ; then

				echo "Size ${BESTSIZE} and Bitrate ${BESTBIT} wins"
#				MAG_RAW_UID=$(grep -i magnet:.*${BESTBITMAG} ${TMPFILE} | sed 's/^.*\(magnet:.*6969\)" title=".*/\1/')
				MAG_RAW_UID=${BESTBITUID}
				MAG_RAW=${BESTBITMAG}
#				BESTMAG=yes

			elif [ "${BESTBIT}" -ge 128 ] ; then
				echo "Bitrate of ${BESTBIT} wins"
#				MAG_RAW_UID=$(grep -i magnet:.*${BESTBITMAG} ${TMPFILE} | sed 's/^.*\(magnet:.*6969\)" title=".*/\1/')
				MAG_RAW_UID=${BESTBITUID}
				MAG_RAW=${BESTBITMAG}
#				BESTMAG=yes
			else
				echo "Falling back to size of ${BESTSIZE}"
#				MAG_RAW_UID=$(grep -i magnet:.*${BESTSIZEMAG} ${TMPFILE} | sed 's/^.*\(magnet:.*6969\)" title=".*/\1/')
				MAG_RAW_UID=${BESTSIZEUID}
				MAG_RAW=${BESTSIZEMAG}
#				BESTMAG=yes
			fi

			MAG_PRETTY=$(echo "${MAG_RAW}" | sed 's/&amp;tr=.*//g;s/^.*dn=\(.*\)/\1/;s/+/ /g')
#			MAG_RAW_UID=${MAG_RAW_UID}
			echo
			echo "BEST MAG_RAW_UID: ${MAG_RAW_UID}"
			echo "BEST MAG_RAW: ${MAG_RAW}"

			[ ${DEBUG} ] && echo "========="
#		fi
}

function cleanup() {
	[ -f ${TMPFILE} ] && rm -f ${TMPFILE}
	exit
}


#RESULTS=$(curl -sL -A "${UA}" "${SEARCH_URL}" | grep magnet:)
#RESULTS=$(curl -sL "${SEARCH_URL}" | grep magnet:)

[ ! -f ${TMPFILE} ] && curl -sL "${SEARCH_URL}" > ${TMPFILE}

#POSSIBLES=$(echo ${RESULTS} | tidy - 2>/dev/null | egrep -i "Howard.*Stern.*${MAG_DATE_LEADING}|Howard.*Stern.*${MAG_DATE_LWORD}|Howard.*Stern.*${MAG_DATE_NUM}|Howard.*Stern.*${MAG_DATE_WORD}")
#POSSIBLES=$(echo ${RESULTS} | tidy - 2>/dev/null | egrep -i "${MAG_DATE_LEADING}|${MAG_DATE_LWORD}|${MAG_DATE_NUM}|${MAG_DATE_WORD}" | sed 's/"//g')
POSSIBLES=$(grep magnet: ${TMPFILE} | tidy - 2>/dev/null | egrep -i "${MAG_DATE_LEADING}|${MAG_DATE_LWORD}|${MAG_DATE_NUM}|${MAG_DATE_WORD}" | sed 's/"//g')

#exit

#magstats


#exit

if [ "${POSSIBLES}" ] ; then

	echo -e "\\vShow for ${DATE} available!"

#	findbest
	magstats

	[ ${CHECK} ] ; cleanup

	echo -e "\\vUse this one? [y|N]"
	read DOIT in

	case ${DOIT} in
		[yY])	YES=yes;;
		[nN])	exit;;
		*)	exit;;
	esac

	[ ${DOIT} ] && 	$HOME/Sources/scripts-git/TransManually "${MAG_RAW}" tail

else
	echo -e \\v"Nothing found for ${DATE}."\\v

	[ ${DEBUG} ] && echo "POSSIBLES: $POSSIBLES"
fi

cleanup

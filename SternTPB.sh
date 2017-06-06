#!/bin/sh

#DEBUG="yes"

case $1 in
	[0-9]*-[0-9]*-[0-9]*)
#		echo NUMBERS
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
#		echo nothing
		#DATE="2015-09-08"
		DATE=$(date +%Y-%m-%d)
		;;
esac

MAG_DATE_WORD=$(date -d ${DATE} +%b\+ | tr '[:lower:]' '[:upper:]')
MAG_DATE_WORD+=$(date -d ${DATE} +%-d\+%Y)
MAG_DATE_NUM=$(date -d ${DATE} +%-m-%d-%Y)
MAG_DATE_LWORD=$(date -d ${DATE} +%Y\+%B\+%d)

STERN_DATE=$(date -d "${DATE}" "+%b %d %Y " | tr '[:lower:]' '[:upper:]')
STERN_DATE+=$(date -d "${STERN_DATE}" +%a)
FILE_DATE=$(date -d "${DATE}" +%y%m%d)

BASE="$HOME/Packages/Torrents"

GOING=$(ps ax | grep "$(echo ${STERN_DATE} | sed 's/ /\./g')" | grep -v grep)

if [ "${GOING}" ] ; then
	echo "Already downloading.  Bailing..."
	exit
fi


UA="Mozilla/5.0 (Linux; Android 6.0; XT1585 Build/MCK24.78-13.12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.89 Mobile Safari/537.36"

URL="https://m.thepiratebay.org"

SEARCH_URL="${URL}/search/howard+stern/0/100/0"

[ ${DEBUG} ] && echo -e "\\vcurl -sL \"${SEARCH_URL}\""

RESULTS=$(curl -sL -A "${UA}" "${SEARCH_URL}" | grep magnet:)

MAG_RAW=$(echo ${RESULTS} | tidy - 2>/dev/null | grep -i "Howard+Stern+Show+${MAG_DATE_WORD}" | sed -e 's/"//g')
[ ! "${MAG_RAW}" ] && MAG_RAW=$(echo ${RESULTS} | tidy - 2>/dev/null | grep -i "Howard.*Stern.*${MAG_DATE_LWORD}" | sed -e 's/"//g')
[ ! "${MAG_RAW}" ] && MAG_RAW=$(echo ${RESULTS} | tidy - 2>/dev/null | grep -i "Howard+Stern+Show+${MAG_DATE_NUM}" | sed -e 's/"//g')


if [ ${DEBUG} ] ; then
	echo -e "========="
	echo "MAG_DATE_WORD: $MAG_DATE_WORD"
	echo "MAG_DATE_LWORD: $MAG_DATE_LWORD"
	echo "MAG_DATE_NUM: $MAG_DATE_NUM"
	echo "SEARCH: Howard+Stern+Show+${MAG_DATE_WORD}"
	echo "ACTUAL: Howard+Stern+Show+AUG+9+2016+Tue"
	echo -e "---------\\n${MAG_RAW}\\n---------"
fi


if [ "${MAG_RAW}" ] ; then

	echo -e "\\vShow for ${DATE} available!\\v"

	echo -e "${MAG_RAW}\\n"

	[ ${CHECK} ] && exit 0

	$HOME/Sources/scripts-git/TransManually "${MAG_RAW}" tail

	tail -F /var/log/transmission/transmission

#	if [ -f "${BASE}/Howard Stern Show ${STERN_DATE}/Howard Stern Show ${STERN_DATE}.mp3" ] ; then

#		mv "${BASE}/Howard Stern Show ${STERN_DATE}/Howard Stern Show ${STERN_DATE}.mp3" "${BASE}/Howard Stern Show ${STERN_DATE}/${FILE_DATE}.mp3"
#		Retag "${BASE}/Howard Stern Show ${STERN_DATE}/${FILE_DATE}.mp3"

#		exit
#	else
#		echo -e "\\v\"${BASE}/Howard Stern Show ${STERN_DATE}/Howard Stern Show ${STERN_DATE}.mp3\" not found.  Bailing...\\v"
#		exit 1
#	fi
else
	echo -e \\v"Nothing found for ${DATE}."\\v
fi

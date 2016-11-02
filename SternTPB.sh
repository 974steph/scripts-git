#!/bin/sh

DEBUG="yes"

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
#MAG_DATE_WORD+=$(date -d ${DATE} +%d\+%Y\+%a)
MAG_DATE_WORD+=$(date -d ${DATE} +%-d\+%Y)
MAG_DATE_NUM=$(date -d ${DATE} +%-m-%d-%Y)

STERN_DATE=$(date -d "${DATE}" "+%b %d %Y " | tr '[:lower:]' '[:upper:]')
STERN_DATE+=$(date -d "${STERN_DATE}" +%a)
FILE_DATE=$(date -d "${DATE}" +%y%m%d)
#echo $DATE = $STERN_DATE
#echo $FILE_DATE
#exit

BASE="$HOME/Packages/Torrents"

#MAG_RAW=$(echo ${RESULTS} | egrep -i '${MAG_DATE_WORD}|${MAG_DATE_NUM}')
#MAG_RAW=$(echo ${RESULTS} | xmllint --format --html - | grep -i "Howard+Stern+Show+${MAG_DATE_WORD}")

GOING=$(ps ax | grep "$(echo ${STERN_DATE} | sed 's/ /\./g')" | grep -v grep)

if [ "${GOING}" ] ; then
	echo "Already downloading.  Bailing..."
	exit
fi


UA="Mozilla/5.0 (Linux; Android 6.0; XT1585 Build/MCK24.78-13.12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.89 Mobile Safari/537.36"
#UA=$(curl -sL "https://github.com/gorhill/uMatrix/wiki/Latest-user-agent-strings" | grep -i chrome | head -n3 | tail -n1)
#URL="https://m.thepiratebay.se"
URL="https://m.thepiratebay.org"

SEARCH_URL="${URL}/search/howard+stern/0/100/0"

#[ ${DEBUG} ] && echo -e "\\vcurl -sL -A \"${UA}\" \"${URL}/search/howard+stern/0/100/0\""
#[ ${DEBUG} ] && echo -e "\\vcurl -sL \"${URL}/search/howard+stern/0/100/0\""
[ ${DEBUG} ] && echo -e "\\vcurl -sL \"${SEARCH_URL}\""

#[ ${DEBUG} ] && echo "Howard+Stern+Show+${MAG_DATE_WORD}"

#exit

#RESULTS=$(curl -sL "${SEARCH_URL}" | grep magnet:)
RESULTS=$(curl -sL -A "${UA}" "${SEARCH_URL}" | grep magnet:)
#RESULTS=$(curl -sL -A "${UA}" "${URL}/search/howard+stern/0/100/0" | grep magnet:)
#RESULTS=$(curl -sL -A "${UA}" "${URL}/search/howard+stern/0/100/0" | awk '/SearchResults/,/\/table/')
#RESULTS=$(curl -s "https://thepiratebay.se/search/howard%20stern/0/99/100" | awk '/SearchResults/,/\/table/')
#RESULTS=$(curl -s "https://thepiratebay.org/search/howard%20stern/0/99/100" | awk '/SearchResults/,/\/table/')


#echo $RESULTS


#MAG_RAW=$(echo ${RESULTS} | tidy - 2>/dev/null | grep -i "Howard+Stern+Show+${MAG_DATE_WORD}" | sed -e 's/"//g')
MAG_RAW=$(echo ${RESULTS} | tidy - 2>/dev/null | grep -i "Howard+Stern+Show+${MAG_DATE_WORD}" | sed -e 's/"//g')



if [ ${DEBUG} ] ; then
	echo -e "========="
	echo "MAG_DATE_WORD: $MAG_DATE_WORD"
	echo "MAG_DATE_NUM: $MAG_DATE_NUM"
	echo "SEARCH: Howard+Stern+Show+${MAG_DATE_WORD}"
	echo "ACTUAL: Howard+Stern+Show+AUG+9+2016+Tue"
	echo -e "---------\\n${MAG_RAW}\\n---------"
fi


if [ "${MAG_RAW}" ] ; then

	if [ ${CHECK} ] ; then
		echo -e "\\vShow for ${DATE} available!\\v"
		exit
	fi

	echo -e ${MAG_RAW}

	$HOME/Sources/scripts-git/TransManually "${MAG_RAW}"

	exit $?

	if [ -f "${BASE}/Howard Stern Show ${STERN_DATE}/Howard Stern Show ${STERN_DATE}.mp3" ] ; then

#		mv "${BASE}/Howard Stern Show ${STERN_DATE}/Howard Stern Show ${STERN_DATE}.mp3" "${BASE}/Howard Stern Show ${STERN_DATE}/${FILE_DATE}.mp3"
#		Retag "${BASE}/Howard Stern Show ${STERN_DATE}/${FILE_DATE}.mp3"

		exit
	else
		echo -e "\\v\"${BASE}/Howard Stern Show ${STERN_DATE}/Howard Stern Show ${STERN_DATE}.mp3\" not found.  Bailing...\\v"
		exit 1
	fi
else
	echo -e \\v"Nothing found for ${DATE}."\\v
fi

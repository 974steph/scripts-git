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
MAG_DATE_WORD+=$(date -d ${DATE} +%-d\+%Y)
MAG_DATE_NUM=$(date -d ${DATE} +%-m-%d-%Y)
MAG_DATE_ALL_NUM=$(date -d ${DATE} +%Y%m%d)
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

SEARCH_URL="https://www.limetorrents.cc/searchrss/howard%20stern/"

RESULTS=$(curl -sL -A "${UA}" "${SEARCH_URL}" | xmllint --format - | grep 'enclosure url')

#echo "curl -sL -A \"${UA}\" \"${SEARCH_URL}\" | xmllint --format - | grep 'enclosure url'"
echo "curl -sL \"${SEARCH_URL}\" | xmllint --format - | grep 'enclosure url'"

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
X=0

for R in ${RESULTS} ; do

	if [ ! "${MAG_RAW}" ] ; then

#		echo $R

		MAG_RAW=$(echo ${R} | grep -i "Howard.*Stern.*${MAG_DATE_WORD}")
#		echo "MAG_DATE_WORD: ${MAG_RAW}"

		[ ! "${MAG_RAW}" ] && MAG_RAW=$(echo ${R} | grep -i "Howard.*Stern.*${MAG_DATE_LWORD}")
#		echo "MAG_DATE_LWORD: ${MAG_RAW}"

		[ ! "${MAG_RAW}" ] && MAG_RAW=$(echo ${R} | grep -i "Howard.*Stern.*${MAG_DATE_NUM}")
#		echo "MAG_DATE_NUM: ${MAG_RAW}"

		[ ! "${MAG_RAW}" ] && MAG_RAW=$(echo ${R} | grep -i "Howard.*Stern.*${MAG_DATE_ALL_NUM}")
#		echo "MAG_DATE_ALL_NUM: ${MAG_RAW}"

		[ "${MAG_RAW}" ] && break
#	else
#		echo "$X: $R"
#		X=$(( $X + 1 ))
	fi
done

#exit

MAG_URL=$(echo "${MAG_RAW}" | sed 's/.*url="\(.*\)torrent?title.*/\1torrent/')


if [ ${DEBUG} ] ; then
	echo -e "========="
	echo "MAG_DATE_WORD: $MAG_DATE_WORD"
	echo "MAG_DATE_LWORD: $MAG_DATE_LWORD"
	echo "MAG_DATE_NUM: $MAG_DATE_NUM"
	echo "MAG_DATE_ALL_NUM: $MAG_DATE_ALL_NUM"
#	echo "SEARCH: Howard+Stern+Show+${MAG_DATE_WORD}"
#	echo "ACTUAL: Howard+Stern+Show+AUG+9+2016+Tue"
	echo "MAG_URL: ${MAG_URL}"
#	echo -e "---------\\n${MAG_RAW}\\n---------"
	echo -e "MAG_RAW: ${MAG_RAW}\\n---------"
fi


if [ "${MAG_URL}" ] ; then

	if [ ${CHECK} ] ; then
		echo -e "\\vShow for ${DATE} available!\\v"
		exit
	fi

	echo -e ${MAG_RAW}

	$HOME/Sources/scripts-git/TransManually "${MAG_URL}" tail

	tail -F /var/log/transmission/transmission

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

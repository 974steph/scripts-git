#!/bin/sh

source $HOME/Sources/scripts-git/secret_stuff.sh

DEBUG="YES"


#29402 pts/2    S+     0:00 /bin/sh $HOME/Scripts/TransManually magnet:?xt=urn:btih:B7854487EEB25E5378A25BABC29E725B5B763DF5&dn=Howard+Stern+show+july+20%2C+2015&tr=udp%3A%2F%2Finferno.demonoid.ooo%3A3392%2Fannounce -O /tmp/150720.mp3
#| cut -d: -f4 | cut -d\& -f1

TANK="$HOME/Stern"

# TODAY=$(date "+%B %-d, %Y")
# YESTERDAY=$(date -d "${TODAY} -1 day" "+%B %-d, %Y")

function FindShowMagnet() {

#	BASE_URL="http://www.demonoid.pw/files/?query=howard+stern"
	BASE_URL="http://www.demonoid.pw/rss/2.186.xml"

	WANT_SHOW="$1"

	[ ${DEBUG} ] && echo "FindShowMagnet: \"$WANT_SHOW\""

	M=$(echo $WANT_SHOW | awk '{print $1}')
	D=$(echo $WANT_SHOW | awk '{print $2}')
	Y=$(echo $WANT_SHOW | awk '{print $3}')

	curl -s "http://www.demonoid.pw/rss/2.186.xml" | \
		perl -MHTML::Entities -pe 'decode_entities($_);' | \
		sed "s/&/\&amp\;/g" | xmllint -format - | tr -d \\n | \
		sed "s/<item/\n<item/g;s/> *</></g" | grep ^\<item.*Howard | \
		while read ITEM ; do

		if [ "$(echo $ITEM | egrep -i "${M} ${D}.*${Y}")" ] ; then

			URL=$(echo "$ITEM" | sed "s/.*<link>\(.*\)<\/link>.*/\1/g")

			MAGNET=$(curl -s "${URL}" | grep -i magnet: | sed "s/.*\(magnet:.*announce\)\".*/\1/")

			[ ${DEBUG} ] && echo "MAGNET: $MAGNET"

			$HOME/Scripts/TransManually "${MAGNET}" -O "/tmp/${STERN_FILE}.mp3" ; $HOME/Scripts/Retag "/tmp/${STERN_FILE}.mp3"

		fi

		unset WANT_SHOW MAGNET URL

	done
}


DEMONOID_DATES="$(curl -s "http://www.demonoid.pw/rss/2.186.xml" | \
	perl -MHTML::Entities -pe 'decode_entities($_);' | \
	sed "s/&/\&amp\;/g" | xmllint -format - | tr -d \\n | \
	sed "s/<item/\n<item/g;s/> *</></g" | grep ^\<item.*Howard | \
	sed "s/.*<title>\(.*\)<\/title>.*/\1/;s/[hH]oward [sS]tern show//g;s/^ *//;s/ \+//g;s/,/ /g;s/\([a-zA-Z]\)\([0-9]\)/\1 \2/")"

# 	sed "s/.*<title>\(.*\)<\/title>.*/\1/" | \

IFS='
'

for DATE in ${DEMONOID_DATES} ; do

	STERN_FILE=$(date -d "${DATE}" +%y%m%d 2> /dev/null)

	if [ $? -eq 0 ] ; then

		DATE_PATH=$(date -d ${STERN_FILE} +%Y/%m-%B)

		[ -f "${TANK}/Weekly/${STERN_FILE}.mp3" ] && WEEKLY=YES
		[ -f "${TANK}/${DATE_PATH}/${STERN_FILE}.mp3" ] && ARCHIVE=YES

		MAGNET_DATE=$(date -d ${STERN_FILE} "+%B %-d %Y")


		if [[ ! ${WEEKLY} && ! ${ARCHIVE} ]] ; then

			FindShowMagnet "${MAGNET_DATE}"

		else

			[ ${DEBUG} ] && echo "Have ${STERN_FILE}.mp3"

		fi



	fi

	unset WEEKLY ARCHIVE DATE_PATH STERN_FILE MAGNET_DATE

done

unset DEMONOID_DATES

IFS=''


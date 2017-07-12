#!/usr/bin/env bash

#DEBUG="yes"

URL="http://www.eleafworld.com/istick-tc100w-firmware-upgradable/"
URL_WIN="http://www.eleafworld.com/wp-content/themes/searchlight/rar-files/UpdateEleaf.zip"
URL_MAC="http://www.eleafworld.com/wp-content/themes/searchlight/rar-files/UpdateEleaf.pkg.zip"

TODAY=$(date +%Y-%m-%d)
#TODAY="2016-02-15"

TODAY_EPOCH=$(date -d ${TODAY} +%s)
YESTERDAY=$(date -d "${TODAY} - 24 hours" +%Y-%m-%d)
YESTERDAY_EPOCH=$(date -d "${TODAY} - 24 hours" +%s)

if [ ${DEBUG} ] ; then
	echo "TODAY: $TODAY"
	echo "TODAY_EPOCH: $TODAY_EPOCH"
	echo "YESTERDAY: $YESTERDAY"
	echo "YESTERDAY_EPOCH: $YESTERDAY_EPOCH"
fi

function NotifyUpdate() {

	HTML_RAW=$(curl -s "http://www.eleafworld.com/istick-tc100w-firmware-upgradable/" | grep "Firmware V")

	echo "---------"
	echo "${HTML_RAW}" | head -n1 | sed -e :a -e 's/<[^>]*>//g;/</N;//ba' -e 's/^[ \t]*//;s/[ \t]*$//'
	echo
	echo "${HTML_RAW}" | tail -n1 | sed -e :a -e 's/<[^>]*>//g;/</N;//ba' -e 's/^[ \t]*//;s/[ \t]*$//'
	echo "---------"
}

#exit

eval $(curl -s --head ${URL_WIN} | egrep "Content-Length|Last-Modified" | tr -d \\r | sed "s/Content-Length: \(.*\)$/WIN_SIZE=\"\1\"/;s/.*Last-Modified: \(.*\)$/WIN_DATE=\"\1\"/")

WIN_EPOCH=$(date -d "${WIN_DATE}" +%s)

if [ ${DEBUG} ] ; then
	echo "WIN_DATE: $WIN_DATE"
	echo "WIN_EPOCH: $WIN_EPOCH"
	echo "WIN_SIZE: $WIN_SIZE"
	echo "---------"
fi

eval $(curl -s --head ${URL_MAC} | egrep "Content-Length|Last-Modified" | tr -d \\r | sed "s/Content-Length: \(.*\)$/MAC_SIZE=\"\1\"/;s/.*Last-Modified: \(.*\)$/MAC_DATE=\"\1\"/")

MAC_EPOCH=$(date -d "${MAC_DATE}" +%s)

if [ ${DEBUG} ] ; then
	echo "MAC_DATE: $MAC_DATE"
	echo "MAC_EPOCH: $MAC_EPOCH"
	echo "MAC_SIZE: $MAC_SIZE"
	echo
fi

if [ ${WIN_EPOCH} -gt ${YESTERDAY_EPOCH} ] && [ ${WIN_EPOCH} -lt ${TODAY_EPOCH} ] ; then
	echo "Firmware IS updated"

	if [ ${DEBUG} ] ; then
		echo "Firmware IS updated"
		echo
		echo "TODAY_EPOCH: $TODAY_EPOCH"
		echo "YESTERDAY_EPOCH: $YESTERDAY_EPOCH"
		echo "WIN_EPOCH: $WIN_EPOCH"
		echo "MAC_EPOCH: $MAC_EPOCH"
		date -d "${WIN_DATE}"
	fi

	NotifyUpdate ${WIN_EPOCH}
else
#	echo "Firmware NOT updated"

	if [ ${DEBUG} ] ; then
		echo "Firmware NOT updated"
		echo
		echo "TODAY_EPOCH: $TODAY_EPOCH"
		echo "YESTERDAY_EPOCH: $YESTERDAY_EPOCH"
		echo "WIN_EPOCH: $WIN_EPOCH"
		echo "MAC_EPOCH: $MAC_EPOCH"
		date -d "${WIN_DATE}"
	fi
fi



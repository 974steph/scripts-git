#!/bin/sh

source $HOME/Sources/scripts-git/secret_stuff.sh

#DEBUG="yes"

TODAY=$(date -d $(date +%Y-%m-%d) +%s)
#TODAY=$(date -d 2015-10-16 +%s)

TODAY_UP=$(date -d "$(date -d @${TODAY}) + 1 day" +%s)
TODAY_DOWN=$(date -d "$(date -d @${TODAY}) - 1 day" +%s)

RAW_PAGE=$(curl -s -L "http://www.joyetech.com/mvr-software/?sid=155")

#POSTED=$(date -d "$(echo "${RAW_PAGE}" | grep "Post Date" | cut -d: -f2- |  sed -e 's/<[^>]*>//g;s/^[ \t]*//;s/[ \t]*$//')" +%s)
POSTED=$(date -d "$(echo "${RAW_PAGE}" | grep "Date Updated" | sed -e 's/<[^>]*>//g' | cut -d: -f2)" +%s)

[ ${DEBUG} ] && echo "${RAW_PAGE}" | grep "Date Updated" | sed -e 's/<[^>]*>//g' | cut -d: -f2

if [ ${DEBUG} ] ; then
	echo -e TODAY:\\t\\t\"$TODAY\"
	echo -e TODAY_UP:\\t\"$TODAY_UP\"
	echo -e POSTED\\t\\t\"$POSTED\"
	echo -e TODAY_DOWN:\\t\"$TODAY_DOWN\"
	echo
fi


if [ ${POSTED} -ge ${TODAY_DOWN} -a ${POSTED} -le ${TODAY_UP} ] ; then

	BODY="/tmp/eVIC_Updates.html"

#	FILES=$(curl -s "http://www.joyetech.com/mvr-software/?sid=155" | grep zip -m2 | sed "s/.*href=\"\(.*.zip\)\".*/\1/")
	FILES=$(echo "${RAW_PAGE}" | grep zip -m2 | sed "s/.*href=\"\(.*.zip\)\".*/\1/")
	FILE_WIN=$(echo "${FILES}" | grep win)
	FILE_MAC=$(echo "${FILES}" | grep mac)

	VERSION=$(echo ${FILE_WIN} | sed "s/.*Firmware_V\(.*\).zip/\1/")

	if [ ${DEBUG} ] ; then
		echo -e "UPDATE"
		echo -e \\v"Firmware updated to: ${VERSION} on $(date -d @${POSTED} '+%B %d, %Y')"\\v
		echo -e "Win: http://www.joyetech.com${FILE_WIN}"
		echo -e "Mac: http://www.joyetech.com${FILE_MAC}"
	fi

	echo -e "<p>eVIC Firmware Updated</p>" > "${BODY}"
	echo -e "<p>Firmware updated to: ${VERSION} on $(date -d @${POSTED} '+%B %d, %Y')</p>" >> "${BODY}"
#	echo -e "<hr>" >> "${BODY}"
	echo -e "<p>Windows Download: <a href=\"http://www.joyetech.com${FILE_WIN}\">$(echo ${FILE_WIN} | sed "s/.*Up/Up/")</a></p>" >> "${BODY}"
	echo -e "<p>Mac Download: <a href=\"http://www.joyetech.com${FILE_MAC}\">$(echo ${FILE_MAC} | sed "s/.*Up/Up/")</a></p>" >> "${BODY}"
	echo -e "<p><a href=\"http://www.joyetech.com/mvr-software/?sid=155\">Joytech eVIC VT software page</a>" >> "${BODY}"

#	mutt -s "eVIC Firmware ${VERSION}" -e "set content_type=text/html" -- "${EMAILS}" < "${BODY}"
	mailx -s "eVIC Firmware ${VERSION}" -a "Content-Type: text/html" "${EMAILS}" < ${BODY}

	rm -f "${BODY}"

	exit 0

else
	if [ ${DEBUG} ] ; then
#		FILES=$(curl -s "http://www.joyetech.com/mvr-software/?sid=155" | grep zip -m2 | sed "s/.*href=\"\(.*.zip\)\".*/\1/")
		FILES=$(echo "${RAW_PAGE}" | grep zip -m2 | sed "s/.*href=\"\(.*.zip\)\".*/\1/")
		FILE_WIN=$(echo "${FILES}" | grep win)
		FILE_MAC=$(echo "${FILES}" | grep mac)

		VERSION=$(echo ${FILE_WIN} | sed "s/.*Firmware_V\(.*\).zip/\1/")

		echo -e "NO UPDATE"
		echo -e \\v"Firmware updated to: ${VERSION} on $(date -d @${POSTED})"\\v
	fi
fi

#!/usr/bin/env bash

case $1 in
	debug) DEBUG="YES";;
esac

#DEBUG="YES"

#URL="http://www.smoktech.com/support/upgrade/toolsandfirmware/ispalien"
URL="http://www.smoktech.com/support/upgrade/toolsandfirmware/ispalienv"

TMP_FILE="/tmp/alien_firmware_$(date +%s).tmp"

UA="Mozilla/5.0 (Linux; Android 6.0; XT1585 Build/MCK24.78-13.12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.89 Mobile Safari/537.36"

curl -sL -A "${UA}" "${URL}" | xmllint --nowarning --format --html - 2>/dev/null  > ${TMP_FILE}

if [ ! -f "${TMP_FILE}" ] ; then
	echo "\"${TMP_FILE}\" doesn't exist for some reason.  Bailing..."
	exit 1
fi

# Alien URL
# curl -sL http://www.smoktech.com/support/upgrade/toolsandfirmware | xmllint --nowarning --format --html - 2>/dev/null | grep -i tool.*alien | sed 's/^.*="\(.*\)">.*$/\1/'
#
# ZIP File
# curl -sL "${URL}" | xmllint --nowarning --format --html - 2>/dev/null | grep -i \.zip | sed 's/.*href="\(.*\.zip\).*/\1/'
#
# Name
# curl -sL "${URL}" | xmllint --nowarning --format --html - 2>/dev/null | grep -i \.zip | sed 's/<[^>]\+>/ /g;s/ \+//'
#
# Version
# curl -sL "${URL}" | xmllint --nowarning --format --html - 2>/dev/null | grep -i \.zip | sed 's/<[^>]\+>/ /g;s/ \+//;s/)//g' | cut -d '(' -f2
#
# Date:
# date -d "$(curl -sL --head http://7xjcby.com2.z0.glb.qiniucdn.com/file/14752125965974vmwev5prxto.zip | grep Last-Modified: | cut -d ' ' -f2-)" +%s



#ZIP_FILE=$(curl -sL "${URL}" | xmllint --nowarning --format --html - 2>/dev/null | grep -i \.zip | sed 's/.*href="\(.*\.zip\).*/\1/')
VERSION=$(grep "ALIEN V" ${TMP_FILE} | sed 's/<[^>]\+>/ /g;s/ \+//;s/)//g' | awk '{print $2}' | tail -n1)
#ZIP_FILE=$(xmllint --nowarning --format --html ${TMP_FILE} 2>/dev/null | grep -i ${VERSION}.*\.zip | sed 's/.*href="\(.*\.zip\).*/\1/')
ZIP_FILE=$(grep -i ${VERSION}.*\.zip ${TMP_FILE} | sed 's/.*href="\(.*\.zip\).*/\1/')
BASENAME=$(basename "${ZIP_FILE}")
# BASENAME=$(basename "${ZIP_FILE}" | sed 's/\([0-9]\+\).*/\1/')
BIG_STAMP=$(basename "${ZIP_FILE}" | sed 's/\([0-9]\+\).*/\1/')
FILE_STAMP=$(date -d  @${BASENAME:0:10} +%s)
YESTER_STAMP=$(date -d $(date -d "yesterday" +%Y-%m-%d) +%s)
#YESTER_STAMP="$(date -d 2017-01-01 +%s)"


if [ ${DEBUG} ] ; then
	echo "TMP_FILE: ${TMP_FILE}"
	echo "ZIP_FILE: ${ZIP_FILE}"
	echo "BASENAME: ${BASENAME}"
	echo "BIG_STAMP: ${BIG_STAMP}"
	echo "FILE_STAMP: ${FILE_STAMP} ($(date -d @${FILE_STAMP}))"
	echo "YESTER_STAMP: ${YESTER_STAMP} ($(date -d @${YESTER_STAMP}))"
fi

if [ "${FILE_STAMP}" -gt "${YESTER_STAMP}" ] ; then

#	VERSION=$(xmllint --nowarning --format --html ${TMP_FILE} 2>/dev/null | grep -i \.zip | sed 's/<[^>]\+>/ /g;s/ \+//;s/)//g' | cut -d '(' -f2)

	echo -e "\n\nALIEN FIRMWARE UPDATE AVAILABLE\n\n"
	echo -e "Page: ${URL}"
	echo -e "New version: ${VERSION}"
	echo -e "File date: $(date -d @${FILE_STAMP})"
	echo -e "Zip file: ${ZIP_FILE}\n"
else
	[ ${DEBUG} ] && echo -e "\vNO ALIEN FIRMWARE UPDATE\v"
fi

if [ ! ${DEBUG} ] ; then
	rm -f ${TMP_FILE}
#else
#	rm -fv ${TMP_FILE}
fi


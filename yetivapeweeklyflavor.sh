#!/bin/sh

source $HOME/Sources/scripts-git/secret_stuff.sh

#DEBUG="yes"

BODY="/tmp/yeti_$(date +%s).html"

function doHTML() {
	echo "<html><head><title>${NAME}</title></head>" > ${BODY}
	echo "<body align=\"center\">" >> ${BODY}
	echo "<a href=\"${URL}\" target=\"_blank\"><img src=\"${IMG}\"></a>" >> ${BODY}
	echo "<p><b>${NAME}</b></p>" >> ${BODY}
	echo "<p>${DESC}</p>" >> ${BODY}
	echo "</body></html>" >> ${BODY}
}

function sendMail() {

	mutt -s "${NAME}" -e "set content_type=text/html" -- ${EMAIL_MINE} < "${BODY}"

	rm -f ${BODY}
}



#RAW="$(curl -s "www.yetivape.com/e-liquids/flavor-of-the-week" | awk '/span3 first-in-line/ {p=1}; p; /div class="cart-button"/ {p=0}' | tidy -b -wrap 1000 -q -ascii --tidy-mark false --show-warnings false | awk '/name/,/description/')"
#RAW="$(curl -sL "www.yetivape.com/e-liquids/flavor-of-the-week" | awk '/img alt="Flavor of the Week/','/div class="description/' | tidy -b -wrap 1000 -q -ascii --tidy-mark false --show-warnings false | awk '/data-src/,/description/')"
RAW="$(curl -sL "www.yetivape.com/e-liquids/flavor-of-the-week" | awk '/img.*alt="Flavor of the Week/','/div class="description/' | tidy -b -wrap 1000 -q -ascii --tidy-mark false --show-warnings false | awk '/image/,/description/')"

#IMG=$(echo "${RAW}" | grep class=.image | sed 's/.*src=\"\(.*jpg\).*/\1/')
#IMG=$(echo "${RAW}" | grep class=.img-responsive | sed "s/.*data-src=\"\(.*[jpg|png]\).*/\1/")
IMG=$(echo "${RAW}" | grep image | sed 's/.*src="\(.*jpg\).*/\1/' | head -n1)
NAME=$(echo "${RAW}" | grep class=.name | sed 's/<[^>]\+>//g')
DESC=$(echo "${RAW}" | grep class=.description | sed 's/<[^>]\+>/ /g;s/^ //')
URL=$(echo "${RAW}" | grep class=.name | sed "s/.*href=\"\(.*\)\">.*/\1/")


PREV_FILE="/var/tmp/yetivape.log"

if [ ${DEBUG} ] ; then
	#echo -e "RAW:${RAW}\\n========="
	echo -e "IMG: $IMG\\n========="
	echo -e "NAME: $NAME\\n========="
	echo -e "DESC: $DESC\\n========="
	echo -e "URL: $URL\\n========="
fi

#exit

if [ -f ${PREV_FILE} ] ; then
	PREV_FLAVOR=$( grep -v "^$" ${PREV_FILE} | tail -n1)

	if [ "${NAME}" == "${PREV_FLAVOR}" ] ; then
		[ ${DEBUG} ] && echo "This Week: \"${NAME}\" || Last Week: \"${PREV_FLAVOR}\" - BAILING..."
		exit 0
	else
		[ ${DEBUG} ] && echo "This Week: \"${NAME}\" || Last Week: \"${PREV_FLAVOR}\" - SENDING"
		echo "${NAME}" >> ${PREV_FILE}
		doHTML
		sendMail
	fi
else
	echo ${NAME} > ${PREV_FILE}
	doHTML
	sendMail
fi

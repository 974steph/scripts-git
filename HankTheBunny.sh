#!/bin/sh

if [ ! "$1" ] ; then
	TODAY=$(date +%s)
else
	if [ ! $(echo $1 | grep '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}') ] ; then
		echo -e "\\vFormat dates like this:"
		echo -e "\\v\\t$(date +%Y-%m-%d)\\v"
		exit 1
	else
		TODAY="$(date -d "$1" +%s)"
	fi
fi

#HankTheBunny
RAW=$(curl -sL http://bitbin.it/Z550BXAq/raw/ | grep -A1 THSS.*$(date -d @${TODAY} +%Y-%m-%d))
#RAW=$(curl -sL http://bitbin.it/tvxwQNy1/raw/ | grep -A1 THSS.*$(date -d @${TODAY} +%Y-%m-%d))

#BeetThePimp
#RAW=$(curl -sL "http://paste4btc.com/raw.php?p=LJdPE3Sx" | grep -A1 THSS.*$(date -d @${TODAY} +%Y-%m-%d))

RAW_TITLE=$(echo "${RAW}" | head -n1 | tr -d \\r\\n)
RAW_URL=$(echo "${RAW}" | tail -n1 | tr -d \\r\\n | sed 's/ //g')


if [ ! "${RAW}" ] ; then
	echo -e "\\vNothing found for $(date -d @${TODAY} +%Y-%m-%d).  Bailing...\\v"
	exit
fi


echo -e "\\vRAW_TITLE: \"${RAW_TITLE}\""
echo "RAW_URL: \"${RAW_URL}\""
echo "========="

RAW_NEXT="http://paste4btc.com/raw.php?p=$(basename ${RAW_URL})"

echo "RAW_NEXT: \"${RAW_NEXT}\""
echo "========="

#ROCKFILE=$(curl -sL "${RAW_NEXT}" | grep rockfile | tr -d \\r\\n | sed 's/ //g')

ROCKFILE=$(curl -sL "${RAW_NEXT}" | grep -A1 THSS.*$(date -d @${TODAY} +%Y-%m-%d) | tail -n1 | tr -d \\r\\n | sed 's/ //g')


echo -e "ROCKFILE: \"${ROCKFILE}\"\\v"

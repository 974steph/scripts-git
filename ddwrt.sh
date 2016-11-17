#!/bin/bash

NOW=$(date +%s)
YDAY=$(date -d "$(date -d @${NOW}) - 1 day" +%s)
YEAR=$(date -d @${NOW} +%Y)
MONTH=$(date -d @${NOW} +%b)

MODEL="netgear-r6400"

DEPOT="$HOME/Backups/Router/Netgear_R6400"

echo "NOW:  ${NOW}"
echo "YDAY: ${YDAY}"
echo "YEAR: $YEAR"
echo "MONTH:$MONTH"

URL_BASE="http://download1.dd-wrt.com/dd-wrtv2/downloads/betas"


DD_MONTH=$(curl -sL ${URL_BASE}/${YEAR} | grep ${MONTH}.*${YEAR} | tail -n1)
#DD_MONTH=$(curl -sL ${URL_BASE}/${YEAR} | tail -n1)

echo "curl -sL ${URL_BASE}/${YEAR} | grep ${MONTH}.*${YEAR}"

echo "DD_MONTH: $DD_MONTH"


if [ "${DD_MONTH}" ] ; then

	for M in "${DD_MONTH}" ; do

		echo "M: \"$M\""

		DURL=$(echo "${M}" | awk '{print $2}' | sed "s/^.*=\"\(.*\)\/\".*/\1/")
		DVER=$(echo ${DURL} | cut -d- -f4)
		DDATE=$(echo "${M}" | awk '{print $3}')
		DPOCH=$(date -d ${DDATE} +%s)

		echo "DURL: $DURL"
		echo "DDATE: $DDATE"
		echo "DPOCH: $DPOCH"
		echo "DVER: $DVER"
		echo ${URL_BASE}/${YEAR}/${DURL}/${MODEL}

		echo "========="
		BIN_FACTORY="${URL_BASE}/${YEAR}/${DURL}/${MODEL}/factory-to-dd-wrt.chk"
		BIN_FACTORY_OUT="netgear-r6400-factory-to-ddwrt-${DVER}.bin"
		echo "FACTORY: ${BIN_FACTORY}"
		echo "BIN_FACTORY_OUT: $BIN_FACTORY_OUT"
		curl --head -sL "${BIN_FACTORY}"
		echo "========="
		BIN_WEBFLASH="${URL_BASE}/${YEAR}/${DURL}/${MODEL}/netgear-r6400-webflash.bin"
		BIN_WEBFLASH_OUT="netgear-r6400-webflash-${DVER}.bin"
		echo "WEBFLASH: ${BIN_WEBFLASH}"
		echo "BIN_WEBFLASH_OUT: $BIN_WEBFLASH_OUT"
		curl --head -sL "${BIN_WEBFLASH}"
		echo "========="
	done
else
	echo "Nothing for ${MONTH}/${YEAR}"
fi

if [ ! -d ${DEPOT}/DD-WRT-${DVER} ] ; then
	mkdir -pv ${DEPOT}/DD-WRT-${DVER}
else
	echo "OK - \"${DEPOT}/DD-WRT-${DVER}\""
fi

if [ ! -f ${DEPOT}/DD-WRT-${DVER}/${BIN_FACTORY_OUT} ] ; then
	wget ${BIN_FACTORY} -O ${DEPOT}/DD-WRT-${DVER}/${BIN_FACTORY_OUT}
else
	echo "OK - \"${DEPOT}/DD-WRT-${DVER}/${BIN_FACTORY_OUT}\""
fi

if [ ! -f ${DEPOT}/DD-WRT-${DVER}/${BIN_WEBFLASH_OUT} ] ; then
	wget ${BIN_WEBFLASH} -O ${DEPOT}/DD-WRT-${DVER}/${BIN_WEBFLASH_OUT}
else
	echo "OK - \"${DEPOT}/DD-WRT-${DVER}/${BIN_WEBFLASH_OUT}\""
fi

#!/usr/bin/env bash

#DEBUG="true"

# UNCOMMENT TO ENABLE
GET_WEB_FLASH="YES"

# UNCOMMENT TO ENABLE
GET_FACTORY_FLASH="YES"


case $1 in
	check)	JUST_CHECK=TRUE;;
esac


NOW=$(date +%s)
#NOW=$(date -d 2017-04-25 +%s)
YDAY=$(date -d "$(date -d @${NOW}) - 1 day" +%s)
YEAR=$(date -d @${NOW} +%Y)
MONTH=$(date -d @${NOW} +%b)

MODEL="netgear-r6400"

DEPOT="$HOME/Backups/Router/Netgear_R6400"

if [ ${DEBUG} ] ; then
	echo "NOW:  ${NOW}"
	echo "YDAY: ${YDAY}"
	echo "YEAR: $YEAR"
	echo "MONTH:$MONTH"
fi

URL_BASE="http://download1.dd-wrt.com/dd-wrtv2/downloads/betas"


DD_MONTH=$(curl -sL ${URL_BASE}/${YEAR} | grep ${MONTH}.*${YEAR} | tail -n1)
#DD_MONTH=$(curl -sL ${URL_BASE}/${YEAR} | tail -n1)
DURL=$(echo "${DD_MONTH}" | awk '{print $2}' | sed "s/^.*=\"\(.*\)\/\".*/\1/")

if [ ${DEBUG} ] ; then
	echo "curl -sL ${URL_BASE}/${YEAR} | grep ${MONTH}.*${YEAR}"
	echo "DD_MONTH: \"$DD_MONTH\""
	echo "DURL: \"$DURL\""
fi


if [ "${DD_MONTH}" ] ; then

	echo -e "\\vChecking: ${URL_BASE}/${YEAR}/${DURL}/${MODEL}\\v"

	for M in "${DD_MONTH}" ; do

		[ ${DEBUG} ] && echo "M: \"$M\""

#		DURL=$(echo "${M}" | awk '{print $2}' | sed "s/^.*=\"\(.*\)\/\".*/\1/")
		DVER=$(echo ${DURL} | cut -d- -f4)
		DDATE=$(echo "${M}" | awk '{print $3}')
		DPOCH=$(date -d ${DDATE} +%s)

		if [ ${DEBUG} ] ; then
			echo "DURL: $DURL"
			echo "DDATE: $DDATE"
			echo "DPOCH: $DPOCH"
			echo "DVER: $DVER"
			echo "URL: \"${URL_BASE}/${YEAR}/${DURL}/${MODEL}\""
			echo "========="
		fi

		BIN_FACTORY="${URL_BASE}/${YEAR}/${DURL}/${MODEL}/factory-to-dd-wrt.chk"
		BIN_FACTORY_OUT="netgear-r6400-factory-to-ddwrt-${DVER}.bin"
		BIN_FACTORY_AVAILABLE=TRUE

		if [ ${DEBUG} ] ; then
			echo "FACTORY: ${BIN_FACTORY}"
			echo "BIN_FACTORY_OUT: $BIN_FACTORY_OUT"
			curl --head -sL "${BIN_FACTORY}"
			echo "========="
		fi

		BIN_WEBFLASH="${URL_BASE}/${YEAR}/${DURL}/${MODEL}/netgear-r6400-webflash.bin"
		BIN_WEBFLASH_OUT="netgear-r6400-webflash-${DVER}.bin"
		BIN_WEBFLASH_AVAILABLE=TRUE

		if [ ${DEBUG} ] ; then
			echo "WEBFLASH: ${BIN_WEBFLASH}"
			echo "BIN_WEBFLASH_OUT: $BIN_WEBFLASH_OUT"
			curl --head -sL "${BIN_WEBFLASH}"
			echo "========="
		fi
	done

	echo -e "Update ${DVER} available!\\v"

else
	echo -e "\\vChecked: ${URL_BASE}/${YEAR}"
	echo -e "\\vNo ${MODEL} firmware for ${MONTH}, ${YEAR}\\v"

	exit
fi


if [ ${GET_FACTORY_FLASH} ] ; then
	if [ ! -f ${DEPOT}/DD-WRT-${DVER}/${BIN_FACTORY_OUT} ] ; then

		if [ ${JUST_CHECK} ] ; then
			unset GET_FACTORY_FLASH
			unset GOT_FACTORY

			echo -e "${BIN_FACTORY}"
		else

			[ ! -d ${DEPOT}/DD-WRT-${DVER} ] && mkdir -p ${DEPOT}/DD-WRT-${DVER}

			wget -q --show-progress ${BIN_FACTORY} -O ${DEPOT}/DD-WRT-${DVER}/${BIN_FACTORY_OUT}

			GOT_FACTORY="true"
		fi
	else
		echo "Already have: \"${DEPOT}/DD-WRT-${DVER}/${BIN_FACTORY_OUT}\""
	fi
fi

if [ ${GET_WEB_FLASH} ] ; then
	if [ ! -f ${DEPOT}/DD-WRT-${DVER}/${BIN_WEBFLASH_OUT} ] ; then

		if [ ${JUST_CHECK} ] ; then
			unset GET_WEB_FLASH
			unset GOT_WEB

			echo -e "${BIN_WEBFLASH}"
		else
			[ ! -d ${DEPOT}/DD-WRT-${DVER} ] && mkdir -p ${DEPOT}/DD-WRT-${DVER}

			wget -q --show-progress ${BIN_WEBFLASH} -O ${DEPOT}/DD-WRT-${DVER}/${BIN_WEBFLASH_OUT}

			GOT_WEB="true"
		fi
	else
		echo "Already have: \"${DEPOT}/DD-WRT-${DVER}/${BIN_WEBFLASH_OUT}\""
	fi
fi

if [ ${JUST_CHECK} ] ; then
	echo
	exit 0
fi

if [ ${GOT_FACTORY} -o ${GOT_WEB} ] ; then
	echo -e "\\vFiles saved to: \"${DEPOT}/DD-WRT-${DVER}\"\\v"
fi

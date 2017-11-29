#!/usr/bin/env bash


######################################################
# EDIT THIS STUFF FOR YOUR SYSTEM / SETUP
CURSE_PLUGINS="askmrrobot auc-stat-wowuction auctionator auctioneer altoholic bagnon datastore datastore_achievements datastore_agenda datastore_characters \
	deadly-boss-mods dejacharacterstats farmhud gathermate2 gathermate2_data handynotes \
	handynotes_legionrarestreasures pawn postal scrap scrap-cleaner skada tomtom undermine-journal world-quest-tracker"

#ADDON_DIR="/WoW_2014_11_28/AddOns"
ADDON_DIR="/WoW_2017_11_28/AddOns"
######################################################


######################################################
# DON'T TOUCH *ANYTHING* FROM HERE TO THE END OF THE SCRIPT

source $HOME/Sources/scripts-git/secret_stuff.sh

WGET_TRIES=5
WGET_LOOP=0
WGET_PAUSE=10
CRON_TIME=60

NOW=$(date +%s)
TODAY=$(date -d @${NOW} +%Y-%m-%d)
YESTERDAY_E=$(date -d "${TODAY} - 1 days" +%s)
CRON_TIME_AGO=$(date -d "$(date -d @${NOW}) - ${CRON_TIME} minutes" +%s)
MAILFILE="/tmp/PluginUpdater_${TODAY}.html"

FETCH_COUNTER=0
FETCH_LIMIT=5
LAST_TOUCH=0

UPDATE_LIST="${ADDON_DIR}/plugin_updates.txt"

#UA="Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.79 Safari/537.36"
getUserAgent

#LAST_MODIFIED="Last-Modified"
LAST_MODIFIED="last-modified"
######################################################


###########################
# OUTPUT STUFF
function outputHead() {
#	${DEBUG} ] && PREFIX="outputHead - "
	if [ ${DEBUG} ] ; then
		if [ ${NOTDUMB} ] ; then
			echo "${PREFIX}${BOLD}${BLUE}${PLUGIN}${RESET}"
		else
			echo "${PREFIX}${PLUGIN}"
		fi
		echo "${PREFIX}PLUGIN_INFO_URL: ${PLUGIN_INFO_URL}"
	fi

	[ ! ${DEBUG} ] && OUTPUT+="${PREFIX}Title: ${PLUGIN_TITLE}\\n"
	OUTPUT+="${PREFIX}Update Time: ${PLUGIN_DATE_PRETTY}\\n"
	OUTPUT+="${PREFIX}Current Version: ${PLUGIN_VERSION}\\n"
#	OUTPUT+="${PREFIX}${PLUGIN_FILE_URL}\\n"
	OUTPUT+="${PREFIX}${PLUGIN_INFO_URL}#t1:changes\\n"
}


function outputTail() {
#	 ${DEBUG} ] && PREFIX="outputTail - "

 	if [ "${OUTPUT}" ] ; then

		if [ ${DEBUG} ] ; then
			if [ ${NOTDUMB} ] ; then
				OUTPUT+="${BOLD}${WHITE}=========${RESET}"
			else
				OUTPUT+="========="
			fi
		else
			OUTPUT+="========="
		fi

		[ ! ${DEBUG} ] && echo -e ${OUTPUT}
		[ ${DEBUG} ] && echo -e ${OUTPUT}
	fi

	unset OUTPUT
}
###########################



###########################
# UPDATE STAMP
function UpdateStamp() {

#	1: EPOCH
#	2: VERSION
#	3: PLUGIN_FILE

	TOUCH_TIME=$(date -d @${1} +%Y%m%d%H%M.%S)
	if [ ${DEBUG} ] ; then
		PREFIX="UpdateStamp - "
		echo "${PREFIX}TOUCH_TIME: ${TOUCH_TIME} || NOW: ${NOW}"
		ls -l "${ADDON_DIR}/${PLUGIN_FILE}"
	fi

	echo "$2" > "${STAMP_FILE}"
	unzip -l "${ADDON_DIR}/${PLUGIN_FILE}" | awk '{print $4}' | egrep -v "^$|Name|-+" >> "${STAMP_FILE}"

	[ ${DEBUG} ] && echo "${PREFIX}${STAMP_FILE} || ${PLUGIN_FILE}"

	touch -t "${TOUCH_TIME}" "${STAMP_FILE}"

	for TOP_DIR in $(awk -F/ '/\// {print $1}' "${STAMP_FILE}" | sort -u) ; do
		[ ${DEBUG} ] && echo "${PREFIX}touch -t \"${TOUCH_TIME}\" \"${TOP_DIR}\""
		touch -t "${TOUCH_TIME}" "${TOP_DIR}"
	done
}
###########################



###########################
# GET PLUGIN
function GetPlugin() {

#	1: EPOCH
#	2: NAME
#	3: URL
#	4: VERSION

	URL="$3"

	[ ${DEBUG} ] && PREFIX="GetPlugin - "

	if [ ${DEBUG} ] ; then
		echo "${PREFIX}EPOCH: $1"
		echo "${PREFIX}NAME: $2"
		echo "${PREFIX}URL: $URL"
		echo "${PREFIX}VERSION: $4"
	fi

	PLUGIN_FILE=$(basename "${URL}")
#	PLUGIN_SERVER_SIZE=$(curl -A "${UA}" -sLI "${URL}" | awk '/Content-Length/ {print $2}' | tail -n1 | tr -d "\r\n")
	PLUGIN_SERVER_SIZE=$(curl -A "${UA}" -sLI "${URL}" | awk '/content-length/ {print $2}' | tail -n1 | tr -d "\r\n")

	wget -q "${URL}" -O "${ADDON_DIR}/${PLUGIN_FILE}"

	PLUGIN_LOCAL_SIZE=$(du -b "${ADDON_DIR}/${PLUGIN_FILE}" | awk '{print $1}')

	if [ ${DEBUG} ] ; then
		OUTPUT+="${PREFIX}THIS_URL: ${URL}\\n"
		OUTPUT+="${PREFIX}PLUGIN_FILE: \"${ADDON_DIR}/$PLUGIN_FILE\"\\n"
		echo "${PREFIX}${ADDON_DIR}/${PLUGIN_FILE}"
		echo "${PREFIX}PLUGIN_SERVER_SIZE: ${PLUGIN_SERVER_SIZE}"
		echo "${PREFIX}PLUGIN_LOCAL_SIZE: ${PLUGIN_LOCAL_SIZE}"
	fi

	[[ ! "${PLUGIN_SERVER_SIZE}" || "${PLUGIN_SERVER_SIZE}" =~ .*[a-zA-Z].* ]] && echo "Invalid PLUGIN_SERVER_SIZE: \"$PLUGIN_SERVER_SIZE\".  Bailing..."
	[[ ! "${PLUGIN_LOCAL_SIZE}" || "${PLUGIN_LOCAL_SIZE}" =~ .*[a-zA-Z].* ]] && echo "Invalid PLUGIN_LOCAL_SIZE: \"$PLUGIN_LOCAL_SIZE\".  Bailing..."

	if [ "${PLUGIN_SERVER_SIZE}" -a "${PLUGIN_LOCAL_SIZE}" ] ; then
		if [ "${PLUGIN_SERVER_SIZE}" -eq "${PLUGIN_LOCAL_SIZE}" ] ; then
			OUTPUT+="${PREFIX}GOOD DOWNLOAD: Server: ${PLUGIN_SERVER_SIZE}K Local: ${PLUGIN_LOCAL_SIZE}K\\n"
			cd ${ADDON_DIR}
			unzip -q -o "${PLUGIN_FILE}"

			TRAP=$?

			if [ ${TRAP} -eq 0 ] ; then
				OUTPUT+="${PREFIX}UNZIPPED: $(unzip -l "${PLUGIN_FILE}" | tail -n1 | sed 's/\ \+/ /g' | cut -d' ' -f3-)\\n"
				unset TRAP
				UpdateStamp $1 $4 "${PLUGIN_FILE}"
			else
				OUTPUT+="BAD UNZIP: ${TRAP}"
				unset TRAP
			fi

			[ ! ${KEEP} ] && rm -f "${PLUGIN_FILE}"
		else
			OUTPUT+="${PREFIX}BAD DOWNLOAD: Server: ${PLUGIN_SERVER_SIZE}K Local: ${PLUGIN_LOCAL_SIZE}K\\v"
		fi
	else
		echo "Still missing PLUGIN_SERVER_SIZE ($PLUGIN_SERVER_SIZE) or PLUGIN_LOCAL_SIZE ($PLUGIN_LOCAL_SIZE).  Bailing..."
	fi

	unset PLUGIN_LOCAL_SIZE PLUGIN_SERVER_SIZE
}
###########################



###########################
# FRESHNESS
function Freshness() {

#	1: EPOCH
#	2: NAME
#	3: URL
#	4: VERSION

	[ ${DEBUG} ] && PREFIX="Freshness - "

	ARG_COUNT=$#

	if [ ${ARG_COUNT} -eq 4 ] ; then

		NAME_LOWER=$(echo $2 | tr [:upper:] [:lower:])
		STAMP_FILE="${ADDON_DIR}/.${NAME_LOWER}"

		[ -f ${STAMP_FILE} ] && LAST_TOUCH=$(date -r ${STAMP_FILE} +%s)

		if [ ${DEBUG} ] ; then
			echo "${PREFIX}STAMP_FILE: $STAMP_FILE"
			echo "${PREFIX}LAST_TOUCH: ${LAST_TOUCH} || EPOCH: $1 || NOW: ${NOW}"
		fi

		if [ ${FORCE} ] ;  then
			OUTPUT+="${PREFIX}Forcing update of ${2}\\n"
			GetPlugin $1 $2 $3 $4
#			UPDATES="yes"
		elif [ ${1} -gt ${LAST_TOUCH} ] ; then
			OUTPUT+="${PREFIX}${2} will be updated.\\n"
			GetPlugin $1 $2 $3 $4

#			[[ ! ${NAME_LOWER} =~ .*goingprice.* ]] && UPDATES="yes"
		else
			OUTPUT+="${PREFIX}${2} is up to date.\\n"
			[ ! ${DEBUG} ] && unset OUTPUT
		fi
	else
		echo "${PREFIX}Arg count bad: ${ARG_COUNT} || CMD: $*"
	fi
}
###########################



###########################
# GET PLUGIN PAGE
function GetPluginPage() {

	[ ${DEBUG} ] && PREFIX="GetPluginPage - "

	PLUGIN_PAGE_RAW=$(curl -A "${UA}" -sL "${PLUGIN_INFO_URL}/files")

	PLUGIN_PAGE=$(echo "${PLUGIN_PAGE_RAW}" | awk '/Release/,/download-button/' | egrep "table__content file__name|standard-datetime|download-file" | head -n3)

	if [ ! "${PLUGIN_PAGE}" ] ; then

		if [ ${FETCH_COUNTER} -gt ${FETCH_LIMIT} ] ; then
			echo "${PREFIX}${FETCH_COUNTER} > ${FETCH_LIMIT}: Failed to fetch \"${PLUGIN_INFO_URL}\".  Bailing..."
			exit 1
		else

			if [ ${DEBUG} ] ; then
				echo "${PREFIX}PLUGIN_PAGE: ${PLUGIN_PAGE}"
				echo "${PREFIX}FETCH_COUNTER: ${FETCH_COUNTER}"
			fi

			FETCH_COUNTER=$(( ${FETCH_COUNTER} + 1 ))
			sleep 5
			GetPluginPage
		fi
	fi
}
###########################



###########################
# PLUGINS
function Plugins() {

	[ ${DEBUG} ] && PREFIX="Plugins - "

	for PLUGIN in ${CURSE_PLUGINS} ; do

		PLUGIN_INFO_URL="https://www.curseforge.com/wow/addons/${PLUGIN}"
		[ ${DEBUG} ] && echo "PLUGIN_INFO_URL: ${PLUGIN_INFO_URL}/files"

		GetPluginPage

		PLUGIN_DATE_EPOCH=$(echo "${PLUGIN_PAGE}" | grep data-epoch | sed -e 's/.*data-epoch="//;s/">.*//')
		PLUGIN_DATE_PRETTY=$(date -d @${PLUGIN_DATE_EPOCH} "+%Y-%m-%d %-I:%M:%S %p")
#		PLUGIN_VERSION=$(echo "${PLUGIN_PAGE_RAW}" | awk '/Release/,/download-button/' | grep table__content.*file__name | head -n1 | sed 's/.*full">\(.*\)<.*/\1/' | tr -d "\r\n")
		PLUGIN_VERSION=$(echo "${PLUGIN_PAGE_RAW}" | awk '/table__content.*file__name/ {print $4;exit}' | sed 's/.*full">\(.*\)<.*/\1/')
#		PLUGIN_TITLE=$(echo "${PLUGIN_PAGE_RAW}" | grep "og:title | sed "s/.*content=\"\(.*\)\".*/\1/" | tr -d "\r\n")
		PLUGIN_TITLE=$(echo "${PLUGIN_PAGE_RAW}" | awk '/og:title/ {print $3;exit}' | sed "s/.*content=\"\(.*\)\".*/\1/")
#		PLUGIN_FILE_ID=$(echo "${PLUGIN_PAGE_RAW}" | grep ProjectFileID | sed 's/.*ProjectFileID": \([0-9]\+\),.*/\1/' | head -n1 | tr -d "\r\n"
		PLUGIN_FILE_ID=$(echo "${PLUGIN_PAGE_RAW}" | awk '/ProjectFileID/ {print $9;exit}' | sed 's/,.*//')

#		PLUGIN_FILE_ID_URL=$(echo ${PLUGIN_FILE_ID} | sed 's/\([0-9][0-9][0-9][0-9]\)\([0-9][0-9][0-9]\)/\1\/\2/' | tr -d "\r\n")
		PLUGIN_FILE_ID_URL=$(echo ${PLUGIN_FILE_ID} | sed 's/\([0-9][0-9][0-9][0-9]\)\([0-9][0-9][0-9]\)/\1\/\2/')

#		PLUGIN_FILE_URL=$(curl -A "${UA}" -vv -s ${PLUGIN_INFO_URL}/download/${PLUGIN_FILE_ID}/file 2>&1 | grep zip | sed 's/.*Location: //' | tr -d "\r\n")
		PLUGIN_FILE_URL=$(curl -A "${UA}" -vv -s ${PLUGIN_INFO_URL}/download/${PLUGIN_FILE_ID}/file 2>&1 | awk '/Location.*zip/ {print $3}' | tail -n1 | tr -d "\r\n")

#		echo "@@@@@ ${PLUGIN_INFO_URL}/download/${PLUGIN_FILE_ID}/file"

		if [ ${DEBUG} ] ; then
			echo "${PREFIX}PLUGIN_DATE_EPOCH: \"${PLUGIN_DATE_EPOCH}\""
			echo "${PREFIX}PLUGIN_DATE_PRETTY: \"${PLUGIN_DATE_PRETTY}\""
			echo "${PREFIX}PLUGIN_VERSION: \"${PLUGIN_VERSION}\""
			echo "${PREFIX}PLUGIN_TITLE: \"${PLUGIN_TITLE}\""
			echo "${PREFIX}PLUGIN_FILE_ID: \"${PLUGIN_FILE_ID}\""
			echo "${PREFIX}PLUGIN_FILE_ID_URL: \"${PLUGIN_FILE_ID_URL}\""
			echo "${PREFIX}PLUGIN_FILE_URL: \"${PLUGIN_FILE_URL}\""
		fi

		unset PLUGIN_PAGE

		outputHead

#		Freshness ${PLUGIN_DATE_EPOCH} ${PLUGIN} "${PLUGIN_FILE_URL}#t1:changes" "${PLUGIN_VERSION}"
		Freshness ${PLUGIN_DATE_EPOCH} ${PLUGIN} "${PLUGIN_FILE_URL}" "${PLUGIN_VERSION}"

		outputTail

		FETCH_COUNTER=0
	done

}
###########################



###########################
# GOINGPRICE DAWNBRINGER
function GPDawnbringer() {

	[ ${DEBUG} ] && PREFIX="GPDawnbringer - "

#	curl -A "${UA}" -sL "http://goingpriceaddon.com/client/json.php?region=us?locale=en_US"

	PLUGIN="GoingPrice_US_Dawnbringer"
	PLUGIN_INFO_URL="http://goingpriceaddon.com/news"
	PLUGIN_TITLE="${PLUGIN}"

	PLUGIN_FILE_URL="http://goingpriceaddon.com/download/us.battle.net/symb/GoingPrice_US_Dawnbringer.zip"
	PLUGIN_DATE_EPOCH=$(date -d "$(curl -A "${UA}" --head -sL ${PLUGIN_FILE_URL} | grep ${LAST_MODIFIED} | cut -d ' ' -f2-)" +%s)
	PLUGIN_DATE_PRETTY=$(date -d @${PLUGIN_DATE_EPOCH} "+%Y-%m-%d %-I:%M:%S %p")
	PLUGIN_VERSION=${PLUGIN_DATE_EPOCH}

	outputHead

	Freshness ${PLUGIN_DATE_EPOCH} ${PLUGIN} "${PLUGIN_FILE_URL}" "${PLUGIN_DATE_EPOCH}"

	# unset to disable update notifications
	unset OUTPUT

	outputTail
}
###########################



###########################
# WOW PRO
function WoWPro() {

	[ ${DEBUG} ] && PREFIX="WoWPro - "

	PLUGIN="wowpro"
	PLUGIN_INFO_URL="http://www.wow-pro.com/blog"
	PLUGIN_TITLE="${PLUGIN}"

	PLUGIN_VERSION=$(curl -A "${UA}" -sL "https://raw.githubusercontent.com/Ludovicus/WoW-Pro-Guides/master/WoWPro/WoWPro.toc" | awk '/Version/ {print $3}')
	PLUGIN_FILE_URL="https://s3.amazonaws.com/WoW-Pro/WoWPro+v${PLUGIN_VERSION}.zip"
	PLUGIN_DATE_EPOCH=$(date -d "$(curl -A "${UA}" -sL --head ${PLUGIN_FILE_URL} | grep ${LAST_MODIFIED}: | cut -d ' ' -f2-)" +%s)
	PLUGIN_DATE_PRETTY=$(date -d @${PLUGIN_DATE_EPOCH} "+%Y-%m-%d %-I:%M:%S %p")

	outputHead

	Freshness ${PLUGIN_DATE_EPOCH} ${PLUGIN} "${PLUGIN_FILE_URL}" "${PLUGIN_VERSION}"

	outputTail
}
###########################



###########################
# WOWAUCTION
function WoWAuctionWGet() {

	[ ${DEBUG} ] && echo "WoWAuctionWGet"

	[ ! ${DEBUG} ] && Q="-q"

#	TSV
#	http://www.wowuction.com/us/dawnbringer/alliance/Tools/RealmDataExportGetFileStatic?token=xe7bW9nG3wqdDVYJrrfVcA2

#	CSV
#	http://www.wowuction.com/us/dawnbringer/alliance/Tools/RealmDataExportGetFileStatic?type=csv&token=xe7bW9nG3wqdDVYJrrfVcA2


	wget --user-agent="${UA}" ${Q} -O "${WOWUCTION_LUA_TEMP}" "${WOWUCTION_URL}/Tools/GetTSMDataStatic?dl=true&token=xe7bW9nG3wqdDVYJrrfVcA2"

	TRAP=$?
}

function WoWAuction() {

	[ ${DEBUG} ] && PREFIX="WoWAuction - "

	WOWUCTION_URL="http://www.wowuction.com/us/dawnbringer/alliance"

	WOWUCTION_LUA_LIVE="${ADDON_DIR}/TradeSkillMaster_WoWuction/tsm_wowuction.lua"
	WOWUCTION_LUA_TEMP="${ADDON_DIR}/TradeSkillMaster_WoWuction/tsm_wowuction.lua.tmp"

	[ -f ${WOWUCTION_LUA_TEMP} ] && rm -f ${WOWUCTION_LUA_TEMP}

	WOWUCTION_MINS_AGO="$(curl -A "${UA}" -Ls "${WOWUCTION_URL}" | grep "AH scanned.*ago" | sed "s/.*scanned \(.*\) ago/\1/" | tr -d \\r)"
	WOWUCTION_EPOCH=$(date -d "$(date -d @${NOW}) - ${WOWUCTION_MINS_AGO}" +%s)

	OUTPUT+="${PREFIX}WOWUCTION_EPOCH:    ${WOWUCTION_EPOCH}\\n"
	OUTPUT+="${PREFIX}WOWUCTION_MINS_AGO: ${CRON_TIME_AGO}\\n"

	if [ ${WOWUCTION_EPOCH} -gt ${CRON_TIME_AGO} ] ; then

		WoWAuctionWGet

		[ ${DEBUG} ] && echo "${PREFIX}TRAP WoWAuctionWGet: ${TRAP}"

		[ ${TRAP} -eq 0 ] && if [ -a $(du -b "${WOWUCTION_LUA_TEMP}" | awk '{print $1}') -gt 100 ] ; then

			if [ -f "${WOWUCTION_LUA_TEMP}" -a -f "${WOWUCTION_LUA_LIVE}" ] ; then

				WOWUCTION_LIVE_EPOCH=$(head "${WOWUCTION_LUA_LIVE}" | grep lastUpdate | awk '{print $3}' | sed "s/,//" | tr -d \\r)
				[ ! "${WOWUCTION_LIVE_EPOCH}" ] && WOWUCTION_LIVE_EPOCH=122965200
				WOWUCTION_LIVE_PRETTY=$(date -d @${WOWUCTION_LIVE_EPOCH} "+%Y-%m-%d %-I:%M:%S %p")

				WOWUCTION_TEMP_EPOCH=$(head "${WOWUCTION_LUA_TEMP}" | grep lastUpdate | awk '{print $3}' | sed "s/,//" | tr -d \\r)
				WOWUCTION_TEMP_PRETTY=$(date -d @${WOWUCTION_TEMP_EPOCH} "+%Y-%m-%d %-I:%M:%S %p")

				OUTPUT+="WoWAuction current date: ${WOWUCTION_LIVE_PRETTY}\\n"
				OUTPUT+="WoWAuction server date: ${WOWUCTION_TEMP_PRETTY}\\n"

				if [ ${DEBUG} ] ; then
					echo "${PREFIX}WOWUCTION_TEMP_EPOCH: $WOWUCTION_TEMP_EPOCH"
					echo "${PREFIX}WOWUCTION_LIVE_EPOCH: $WOWUCTION_LIVE_EPOCH"
				fi

				if [ ${WOWUCTION_TEMP_EPOCH} -gt ${WOWUCTION_LIVE_EPOCH} ] ; then

					mv "${WOWUCTION_LUA_TEMP}" "${WOWUCTION_LUA_LIVE}"

					OUTPUT+="${PREFIX}\"WoWAuction\" updated ${WOWUCTION_MINS_AGO} ago\\n"
					OUTPUT+="${PREFIX}${WOWUCTION_URL}\\n"
					OUTPUT+="${PREFIX}UPDATED: WoWAuction is up to date.\\n"

					if [ ${DEBUG} ] ; then
						echo -e "${OUTPUT}========="
					fi
				else
					rm -f "${WOWUCTION_LUA_TEMP}"

					OUTPUT+="${PREFIX}\"WoWAuction\"\\n"
					OUTPUT+="${PREFIX}Update Time: ${WOWUCTION_MINS_AGO} ago\\n"
					OUTPUT+="${PREFIX}${WOWUCTION_URL}\\n"
					OUTPUT+="${PREFIX}CURRENT: WoWAuction is up to date.\\n"

					if [ ${DEBUG} ] ; then
						echo -e "${OUTPUT}========="
					fi
				fi

				unset OUTPUT
			fi
		else
			[ ${DEBUG} ] && echo -n "WoWAuctionWGet exited with ${TRAP}."
			unset TRAP

			WGET_LOOP=$(( ${WGET_LOOP} + 1 ))

			if [ ${WGET_LOOP} -le ${WGET_TRIES} ] ; then
				[ ${DEBUG} ] && echo "${PREFIX}  Pausing.  $(( ${WGET_TRIES} - ${WGET_LOOP} )) more tries... "
				sleep ${WGET_PAUSE}
				WoWAuction
			else
				[ ${DEBUG} ] && echo "${PREFIX}  BAILING after ${WGET_TRIES} tries... "
			fi
		fi
	else
		OUTPUT+="${PREFIX}\"WoWAuction\" updated ${WOWUCTION_MINS_AGO} ago\\n"
		OUTPUT+="${PREFIX}${WOWUCTION_URL}\\n"
		OUTPUT+="${PREFIX}CURRENT: WoWAuction is up to date.\\n"

		if [ ${DEBUG} ] ; then
			echo -e "${OUTPUT}========="
		fi
	fi

	unset OUTPUT
# 	Page
# 	http://www.wowuction.com/us/dawnbringer/alliance/Tools/RealmDataExport#

# 	CSV:
# 	http://www.wowuction.com/us/dawnbringer/alliance/Tools/RealmDataExportGetFileStatic?type=csv&token=xe7bW9nG3wqdDVYJrrfVcA2

# 	Alliance
# 	http://www.wowuction.com/us/dawnbringer/alliance/Tools/GetTSMDataStatic?dl=true&token=xe7bW9nG3wqdDVYJrrfVcA2

# 	Both
# 	http://www.wowuction.com/us/dawnbringer/alliance/Tools/GetTSMDataStatic?dl=true&token=xe7bW9nG3wqdDVYJrrfVcA2&both=true
}
###########################



###########################
# DO IT
function DoIt() {

	[ ${DEBUG} ] && V="v"

	if [ ${SINGLE} ] ; then
		[ ${DEBUG} ] && echo -e "\\n${RED}Single Installing:${RESET} ${BOLD}${BLUE}${CURSE_PLUGINS}${RESET}\\n"
		Plugins
	else
		[ ${DEBUG} ] && echo "ALL - Checking Everything"
		Plugins
#		WoWAuction
		GPDawnbringer
 		WoWPro
	fi
}
###########################



###########################
# MAIN

if [ ! "$TERM" == "dumb" ] ; then

	NOTDUMB="True"

#	echo "TERM: \"$TERM\""
	BOLD=$(tput bold)
	BLUE=$(tput setaf 4)
	RED=$(tput setaf 1)
	PURP=$(tput setaf 6)
	WHITE=$(tput setaf 7)
	RESET=$(tput sgr0)
fi

case $1 in
# 	wa)
# 		DEBUG="yes"
# 		WoWAuction
# 		exit
# 		;;
 	gp)
 		DEBUG="yes"
 		GPDawnbringer
 		exit
 		;;
	keep)
		KEEP="yes"
		FORCE="yes"
		DoIt
		exit
		;;
	force)
		FORCE="yes"
		DEBUG="yes"
#		KEEP="yes"
		DoIt
		exit
		;;
	debug)
		DEBUG="yes"
		DoIt
		;;
	*)
		if [ "$1" ] ; then
			for P in ${CURSE_PLUGINS} ; do
				if [ $1 == $P ] ; then
#					echo "$P == $1 - YES"
					CURSE_PLUGINS=$1
					FORCE="yes"
					DEBUG="yes"
					SINGLE="yes"
				fi
			done
		fi

		DoIt
		;;
esac

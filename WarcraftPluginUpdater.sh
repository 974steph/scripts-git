#!/usr/bin/env bash


######################################################
# USE THIS STUFF
CURSE_PLUGINS="askmrrobot auctionator auctioneer altoholic deadly-boss-mods \
	dejacharacterstats farmhud gathermate2 gathermate2_data handynotes \
	handynotes_legionrarestreasures pawn postal scrap scrap-cleaner skada tomtom world-quest-tracker"

ADDON_DIR="/WoW_2014_11_28/AddOns"

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

UPDATE_LIST="${ADDON_DIR}/plugin_updates.txt"

UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"
######################################################


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

	# [ ! ${DEBUG} ] && OUTPUT+="${PREFIX}Title: ${PLUGIN_TITLE}\\n"
	# [ ${PLUGIN_TITLE} ] && OUTPUT+="${PREFIX}Title: ${PLUGIN_TITLE}\\n"
	# OUTPUT+="${PREFIX}Update Time: ${PLUGIN_DATE_PRETTY}\\n"
	# OUTPUT+="${PREFIX}Current Version: ${PLUGIN_VERSION}\\n"
	# OUTPUT+="${PREFIX}${PLUGIN_INFO_URL}#t1:changes\\n"
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

		echo -e ${OUTPUT}
		[ ${DEBUG} ] && echo -e ${OUTPUT}
	fi

	unset OUTPUT
}

function GetPlugin() {

#	1: EPOCH
#	2: NAME
#	3: URL
#	4: VERSION

	URL="$3"

	[ ${DEBUG} ] && PREFIX="GetPlugin - "

	PLUGIN_FILE=$(basename "${URL}")
	PLUGIN_SERVER_SIZE=$(curl -A "${UA}" -LIs --head "${URL}" | grep Content-Length | awk '{print $2}' | tail -n1 | tr -d "\r\n")
	wget -q "${URL}" -O "${ADDON_DIR}/${PLUGIN_FILE}"

	PLUGIN_LOCAL_SIZE=$(du -b "${ADDON_DIR}/${PLUGIN_FILE}" | awk '{print $1}')

	[ ${DEBUG} ] && OUTPUT+="${PREFIX}THIS_URL: ${URL}\\n"
	[ ${DEBUG} ] && OUTPUT+="${PREFIX}PLUGIN_FILE: \"${ADDON_DIR}/$PLUGIN_FILE\"\\n"

	if [ ${DEBUG} ] ; then
		echo "${PREFIX}${ADDON_DIR}/${PLUGIN_FILE}"
		echo "${PREFIX}PLUGIN_SERVER_SIZE: ${PLUGIN_SERVER_SIZE}"
		echo "${PREFIX}PLUGIN_LOCAL_SIZE: ${PLUGIN_LOCAL_SIZE}"
	fi

	if [ "${PLUGIN_SERVER_SIZE}" -eq "${PLUGIN_LOCAL_SIZE}" ] ; then
		OUTPUT+="${PREFIX}GOOD DOWNLOAD: Server: ${PLUGIN_SERVER_SIZE}K Local: ${PLUGIN_LOCAL_SIZE}K\\n"
		cd ${ADDON_DIR}
		unzip -q -o "${PLUGIN_FILE}"

		TRAP=$?

		if [ ${TRAP} -eq 0 ] ; then
			OUTPUT+="${PREFIX}UNZIPPED: $(unzip -l "${PLUGIN_FILE}" | tail -n1 | sed 's/\ \+/ /g' | cut -d' ' -f3-)\\n"
			unset TRAP

#			UpdateStamp $1 $2 $3 $4
			UpdateStamp $1 $4 "${PLUGIN_FILE}"
		else
			OUTPUT+="BAD UNZIP: ${TRAP}"
			unset TRAP
		fi

		[ ! ${KEEP} ] && rm -f "${PLUGIN_FILE}"
	else
		OUTPUT+="${PREFIX}BAD DOWNLOAD: Server: ${PLUGIN_SERVER_SIZE}K Local: ${PLUGIN_LOCAL_SIZE}K\\v"
	fi

	unset PLUGIN_LOCAL_SIZE PLUGIN_SERVER_SIZE
}


function UpdateGit() {

	cd ${ADDON_DIR}
	git add $(git ls-files -o --exclude-standard)
	git commit -am "$(date +%Y-%m-%d) push updates to git"
	git push
}


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


function Freshness() {

#	1: EPOCH
#	2: NAME
#	3: URL
#	4: VERSION

	ARG_COUNT=$#

	if [ ${ARG_COUNT} -eq 4 ] ; then

		NAME_LOWER=$(echo $2 | tr [:upper:] [:lower:])
		STAMP_FILE="${ADDON_DIR}/.${NAME_LOWER}"

		[ ${DEBUG} ] && PREFIX="Freshness - "

		if [ -f ${STAMP_FILE} ] ; then
			LAST_TOUCH=$(date -r ${STAMP_FILE} +%s)
		else
			LAST_TOUCH=0
		fi

		if [ ${DEBUG} ] ; then
			echo "${PREFIX}STAMP_FILE: $STAMP_FILE"
			echo "${PREFIX}LAST_TOUCH: ${LAST_TOUCH} || EPOCH: $1 || NOW: ${NOW}"
		fi

		if [ ${FORCE} ] ;  then
			OUTPUT+="${PREFIX}Forcing update of ${2}\\n"
			GetPlugin $1 $2 $3 $4
			UPDATES="yes"
		elif [ ${1} -gt ${LAST_TOUCH} ] ; then
			OUTPUT+="${PREFIX}${2} will be updated.\\n"
#			UPDATES="yes"

			[[ ! ${NAME_LOWER} =~ .*goingprice.* ]] && UPDATES="yes"

			[ ! ${SHOW} ] && GetPlugin $1 $2 $3 $4
		else
			OUTPUT+="${PREFIX}${2} is up to date.\\n"
			[ ! ${DEBUG} ] && unset OUTPUT
		fi
	else
		echo "${PREFIX}Arg count bad: ${ARG_COUNT} || CMD: $*"
	fi
}


function GetPluginPage() {

	[ ${DEBUG} ] && PREFIX="GetPluginPage - "

	PLUGIN_PAGE_RAW=$(curl -A "${UA}" -Ls "${PLUGIN_INFO_URL}")

#	PLUGIN_PAGE=$(curl -A "${UA}" -Ls "${PLUGIN_INFO_URL}" | awk '/details-list/,/newest-file/')
	PLUGIN_PAGE=$(echo "${PLUGIN_PAGE_RAW}" | awk '/details-list/,/newest-file/')

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

function Plugins() {

	[ ${DEBUG} ] && PREFIX="Plugins - "

	for PLUGIN in ${CURSE_PLUGINS} ; do

		PLUGIN_INFO_URL="http://www.curse.com/addons/wow/${PLUGIN}"

		# if [ ${DEBUG} ] ; then
		# 	if [ ${NOTDUMB} ] ; then
		# 		echo "${PREFIX}${BOLD}${BLUE}${PLUGIN}${RESET}"
		# 	else
		# 		echo "${PREFIX}${PLUGIN}"
		# 	fi
		# 	echo "${PREFIX}PLUGIN_INFO_URL: ${PLUGIN_INFO_URL}"
		# fi

		outputHead

		GetPluginPage

		PLUGIN_DATE_EPOCH=$(echo "${PLUGIN_PAGE}" | grep Updated.*epoch | sed -e 's/.*data-epoch="//;s/">.*//')
		PLUGIN_DATE_PRETTY=$(date -d @${PLUGIN_DATE_EPOCH} "+%Y-%m-%d %r")
		PLUGIN_VERSION=$(echo "${PLUGIN_PAGE}" | grep newest-file | sed "s/.* \(.*\)<.*/\1/g")
		PLUGIN_TITLE=$(echo "${PLUGIN_PAGE_RAW}" | grep "og:title" | sed "s/.*content=\"\(.*\)\".*/\1/")
		PLUGIN_FILE_URL=$(curl -A "${UA}" -Ls ${PLUGIN_INFO_URL}/download | grep download-link | sed -e 's/.*data-href="//;s/zip" class=".*/zip/;s/ /%20/g')

		# if [ ${DEBUG} ] ; then
		# 	if [ ${NOTDUMB} ] ; then
		# 		echo "${BOLD}${BLUE}${PLUGIN_TITLE}${RESET}"
		# 	else
		# 		echo "${PLUGIN_TITLE}"
		# 	fi
		# fi

		unset PLUGIN_PAGE

#		[ ! ${DEBUG} ] && OUTPUT+="${PREFIX}\"${PLUGIN}\"\\n"
		[ ! ${DEBUG} ] && OUTPUT+="${PREFIX}Title: ${PLUGIN_TITLE}\\n"
		OUTPUT+="${PREFIX}Update Time: ${PLUGIN_DATE_PRETTY}\\n"
		OUTPUT+="${PREFIX}Current Version: ${PLUGIN_VERSION}\\n"
		OUTPUT+="${PREFIX}${PLUGIN_INFO_URL}#t1:changes\\n"

		Freshness ${PLUGIN_DATE_EPOCH} ${PLUGIN} "${PLUGIN_FILE_URL}" "${PLUGIN_VERSION}"

		outputTail

		# if [ "${OUTPUT}" ] ; then
		# 	if [ ${DEBUG} ] ; then
		# 		if [ ${NOTDUMB} ] ; then
		# 			OUTPUT+="${BOLD}${WHITE}=========${RESET}"
		# 		else
		# 			OUTPUT+="========="
		# 		fi
		# 	else
		# 		OUTPUT+="========="
		# 	fi
		# 	echo -e "${OUTPUT}"
		# fi

		# unset OUTPUT

		FETCH_COUNTER=0
	done

}


function GPDawnbringer() {

	[ ${DEBUG} ] && PREFIX="GPDawnbringer - "

#	curl -A "${UA}" -sL "http://goingpriceaddon.com/client/json.php?region=us?locale=en_US"

	PLUGIN="GoingPrice_US_Dawnbringer"
	PLUGIN_INFO_URL="http://goingpriceaddon.com/news"

	outputHead

	PLUGIN_FILE_URL="http://goingpriceaddon.com/download/us.battle.net/symb/GoingPrice_US_Dawnbringer.zip"

#	PLUGIN_DATE_EPOCH=$(basename "${GP_DB_URL}" | awk -F. '{print $3}')
	PLUGIN_DATE_EPOCH=$(date -d "$(curl -A "${UA}" --head -sL ${PLUGIN_FILE_URL} | grep Last-Modified | cut -d ' ' -f2-)" +%s)
	PLUGIN_DATE_PRETTY=$(date -d @${PLUGIN_DATE_EPOCH} "+%Y-%m-%d %r")

	OUTPUT+="${PREFIX}\"${PLUGIN}\"\\n"
	OUTPUT+="${PREFIX}Update Time: ${PLUGIN_DATE_PRETTY}\\n"

	Freshness ${PLUGIN_DATE_EPOCH} ${PLUGIN} "${PLUGIN_FILE_URL}" "${PLUGIN_DATE_EPOCH}"

	outputTail

# 	if [ "${OUTPUT}" ] ; then

# 		if [ ${DEBUG} ] ; then
# 			if [ ${NOTDUMB} ] ; then
# 				OUTPUT+="${BOLD}${WHITE}=========${RESET}"
# 			else
# 				OUTPUT+="========="
# 			fi
# 		else
# 			OUTPUT+="========="
# 		fi

# #		echo -e ${OUTPUT}
# 		[ ${DEBUG} ] && echo -e ${OUTPUT}
# 	fi

# 	unset OUTPUT
}


function WoWPro() {

	###########################
	# WOW-PRO

	[ ${DEBUG} ] && PREFIX="WoWPro - "

	PLUGIN="wowpro"
	PLUGIN_INFO_URL="http://www.wow-pro.com"

	outputHead

	CURRENT_VERSION=$(curl -A "${UA}" -sL "https://raw.githubusercontent.com/Ludovicus/WoW-Pro-Guides/master/WoWPro/WoWPro.toc" | awk '/Version/ {print $3}')

	PLUGIN_FILE_URL="https://s3.amazonaws.com/WoW-Pro/WoWPro+v${CURRENT_VERSION}.zip"

#	PLUGIN_DATE_EPOCH=$(date -d "$(curl -A "${UA}" -sL --head https://s3.amazonaws.com/WoW-Pro/WoWPro+v${CURRENT_VERSION}.zip | grep Last-Modified: | cut -d ' ' -f2-)" +%s)
	PLUGIN_DATE_EPOCH=$(date -d "$(curl -A "${UA}" -sL --head ${PLUGIN_FILE_URL} | grep Last-Modified: | cut -d ' ' -f2-)" +%s)
	PLUGIN_DATE_PRETTY=$(date -d @${PLUGIN_DATE_EPOCH} "+%Y-%m-%d %r")

	# if [ ${DEBUG} ] ; then
	# 	if [ ${NOTDUMB} ] ; then
	# 		OUTPUT+="${BOLD}${WHITE}=========${RESET}"
	# 	else
	# 		OUTPUT+="========="
	# 	fi
	# else
	# 	OUTPUT+="\"wowpro\"\\n"
	# fi
	OUTPUT+="\\n${PREFIX}Update Time: $(date -d @${PLUGIN_DATE_EPOCH})\\n"
	OUTPUT+="${PREFIX}Current Version: ${CURRENT_VERSION}\\n"
	OUTPUT+="${PREFIX}${PLUGIN_INFO_URL}/blog\\n"

	Freshness ${PLUGIN_DATE_EPOCH} ${PLUGIN} "${PLUGIN_FILE_URL}" "${CURRENT_VERSION}"

	outputTail

	# if [ "${OUTPUT}" ] ; then
	# 	if [ ${NOTDUMB} ] ; then
	# 		OUTPUT+="${BOLD}${WHITE}=========${RESET}"
	# 	else
	# 		OUTPUT+="========="
	# 	fi
	# 	echo -e ${OUTPUT}
	# fi

	# unset OUTPUT
}


function WoWAuctionWGet() {

	[ ${DEBUG} ] && echo "WoWAuctionWGet"

	[ ! ${DEBUG} ] && Q="-q"


	wget --user-agent="${UA}" ${Q} -O "${WOWUCTION_LUA_TEMP}" "${WOWUCTION_URL}/Tools/GetTSMDataStatic?dl=true&token=xe7bW9nG3wqdDVYJrrfVcA2"

	TRAP=$?
}

function WoWAuction() {

	[ ${DEBUG} ] && echo WoWAuction
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
				WOWUCTION_LIVE_PRETTY=$(date -d @${WOWUCTION_LIVE_EPOCH} "+%Y-%m-%d %r")

				WOWUCTION_TEMP_EPOCH=$(head "${WOWUCTION_LUA_TEMP}" | grep lastUpdate | awk '{print $3}' | sed "s/,//" | tr -d \\r)
				WOWUCTION_TEMP_PRETTY=$(date -d @${WOWUCTION_TEMP_EPOCH} "+%Y-%m-%d %r")

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

function DoIt() {

	[ ${DEBUG} ] && V="v"

 	WoWPro
	Plugins
#	WoWAuction
	GPDawnbringer

#	if [ ${UPDATES} ] ; then
#		UpdateGit
#		exit 1
#	fi
}

###########################
# MAIN

if [ ! "$TERM" == "dumb" ] ; then

	NOTDUMB="True"

#	echo "TERM: \"$TERM\""
	BOLD=$(tput bold)
	BLUE=$(tput setaf 4)
	RED=$(tput setaf 1)
	WHITE=$(tput setaf 7)
	RESET=$(tput sgr0)
fi

case $1 in
	show)
		DEBUG="yes"
		SHOW="yes"
		DoIt
		exit
		;;
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
		DoIt
		;;
esac

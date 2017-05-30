#!/usr/bin/env bash


#	tradeskill-master tradeskillmaster_accounting tradeskillmaster_apphelper tradeskillmaster_auctioning tradeskillmaster_shopping tradeskillmaster_wowuction
#	master-plan npcscan npcscan-overlay overachiever silver-dragon

######################################################
# USE THIS STUFF
CURSE_PLUGINS="advancedinterfaceoptions archy auctionator auctioneer altoholic dejacharacterstats farmhud \
	gathermate2 gathermate2_data handynotes handynotes_azerothstoptunes handynotes_legionrarestreasures \
	herebedragons pawn postal scrap scrap-cleaner server-hop skada tomtom world-quest-tracker"

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
######################################################


function GetPlugin() {

#	1: EPOCH
#	2: NAME
#	3: URL
#	4: VERSION

#	echo "EPOCH: \"$1\""
#	echo "NAME: \"$2\""
#	echo "URL: \"$3\""
#	echo "VERSION: \"$4\""

	URL="$3"

	PLUGIN_FILE=$(basename "${URL}")
	PLUGIN_SERVER_SIZE=$(curl -LIs --head "${URL}" | grep Content-Length | awk '{print $2}' | tail -n1 | tr -d "\r\n")
	wget -q "${URL}" -O "${ADDON_DIR}/${PLUGIN_FILE}"

	PLUGIN_LOCAL_SIZE=$(du -b "${ADDON_DIR}/${PLUGIN_FILE}" | awk '{print $1}')

	[ ${DEBUG} ] && OUTPUT+="THIS_URL: ${URL}\\n"
	[ ${DEBUG} ] && OUTPUT+="PLUGIN_FILE: \"${ADDON_DIR}/$PLUGIN_FILE\"\\n"

	if [ ${DEBUG} ] ; then
		echo "${ADDON_DIR}/${PLUGIN_FILE}"
		echo "PLUGIN_SERVER_SIZE: ${PLUGIN_SERVER_SIZE}"
		echo "PLUGIN_LOCAL_SIZE: ${PLUGIN_LOCAL_SIZE}"
	fi

	if [ "${PLUGIN_SERVER_SIZE}" -eq "${PLUGIN_LOCAL_SIZE}" ] ; then
		OUTPUT+="GOOD DOWNLOAD: Server: ${PLUGIN_SERVER_SIZE}K Local: ${PLUGIN_LOCAL_SIZE}K\\n"
		cd ${ADDON_DIR}
		unzip -q -o "${PLUGIN_FILE}"

		TRAP=$?

		if [ ${TRAP} -eq 0 ] ; then
			OUTPUT+="UNZIPPED: $(unzip -l "${PLUGIN_FILE}" | tail -n1 | sed 's/\ \+/ /g' | cut -d' ' -f3-)\\n"
			unset TRAP

			UpdateStamp $1 $2 $3 $4
		else
			OUTPUT+="BAD UNZIP: ${TRAP}"
			unset TRAP
		fi

		[ ! ${KEEP} ] && rm -f ${PLUGIN_FILE}
	else
		OUTPUT+="BAD DOWNLOAD: Server: ${PLUGIN_SERVER_SIZE}K Local: ${PLUGIN_LOCAL_SIZE}K\\v"
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
#	2: NAME
#	3: URL
#	4: VERSION

	TOUCH_TIME=$(date -d @${1} +%Y%m%d%H%M.%S)
 	[ ${DEBUG} ] && echo "UpdateStamp: ${TOUCH_TIME} || ${NOW}"

	echo "$4" > "${STAMP_FILE}"
	touch -t "${TOUCH_TIME}" "${STAMP_FILE}"
}


function Freshness() {

#	1: EPOCH
#	2: NAME
#	3: URL
#	4: VERSION


#	if [ $2 == "GoingPrice_Dawnbringer" ] ; then
#		CRON_TIME_AGO=$(date -r ${ADDON_DIR}/GoingPrice_US_Dawnbringer/timestamp +%s)
#	fi

	NAME_LOWER=$(echo $2 | tr [:upper:] [:lower:])
	STAMP_FILE="${ADDON_DIR}/.${NAME_LOWER}"

	if [ -f ${STAMP_FILE} ] ; then
		LAST_TOUCH=$(date -r ${STAMP_FILE} +%s)
	else
		LAST_TOUCH=0
	fi

	if [ ${DEBUG} ] ; then
		echo "STAMP_FILE: $STAMP_FILE"
		echo "LAST_TOUCH: ${LAST_TOUCH} || EPOCH: $1 || NOW: ${NOW}"
	fi

	if [ ${FORCE} ] ;  then
		OUTPUT+="Forcing update of ${2}\\n"
		GetPlugin $1 $2 $3 $4
		UPDATES="yes"
	elif [ ${1} -gt ${LAST_TOUCH} ] ; then
		OUTPUT+="UPDATING: ${2} will be updated.\\n"
#		UPDATES="yes"

		[[ ! ${NAME_LOWER} =~ .*goingprice.* ]] && UPDATES="yes"

		[ ! ${SHOW} ] && GetPlugin $1 $2 $3 $4
	else
		OUTPUT+="CURRENT: ${2} is up to date.\\n"
		[ ! ${DEBUG} ] && unset OUTPUT
	fi
}

function WoWPro() {

	###########################
	# WOW-PRO

	WOWPRO_INFO_URL="http://www.wow-pro.com"

	CURRENT_VERSION=$(curl -sL "https://raw.githubusercontent.com/Ludovicus/WoW-Pro-Guides/master/WoWPro/WoWPro.toc" | grep Version | awk '{print $3}')

# 	CURRENT_DISK_VERSION=$(grep Version ${ADDON_DIR}/WoWPro/WowPro.toc | awk '{print $3}')

	LINK="https://s3.amazonaws.com/WoW-Pro/WoWPro+v${CURRENT_VERSION}.zip"

#	WOWPRO_EPOCH=$(date -d "$(curl -sL --head https://s3.amazonaws.com/WoW-Pro/WoWPro+v${CURRENT_VERSION}.zip | grep Last-Modified: | cut -d ' ' -f2-)" +%s)
	WOWPRO_EPOCH=$(date -d "$(curl -sL --head ${LINK} | grep Last-Modified: | cut -d ' ' -f2-)" +%s)

	if [ ${DEBUG} ] ; then
		if [ ${NOTDUMB} ] ; then
			OUTPUT+="${BOLD}${WHITE}=========${RESET}"
		else
			OUTPUT+="========="
		fi
	else
		OUTPUT+="\"wowpro\"\\n"
	fi
	OUTPUT+="Update Time: $(date -d @${WOWPRO_EPOCH})\\n"
	OUTPUT+="Current Version: ${CURRENT_VERSION}\\n"
	OUTPUT+="${WOWPRO_INFO_URL}/blog\\n"

	Freshness ${WOWPRO_EPOCH} wowpro "${LINK}" "${CURRENT_VERSION}"

	if [ "${OUTPUT}" ] ; then
		if [ ${NOTDUMB} ] ; then
			OUTPUT+="${BOLD}${WHITE}=========${RESET}"
		else
			OUTPUT+="========="
		fi
		echo -e ${OUTPUT}
	fi

	unset OUTPUT
}


function GetPluginPage() {

	PLUGIN_PAGE_RAW=$(curl -Ls "${PLUGIN_INFO_URL}")

#	PLUGIN_PAGE=$(curl -Ls "${PLUGIN_INFO_URL}" | awk '/details-list/,/newest-file/')
	PLUGIN_PAGE=$(echo "${PLUGIN_PAGE_RAW}" | awk '/details-list/,/newest-file/')

	if [ ! "${PLUGIN_PAGE}" ] ; then

		if [ ${FETCH_COUNTER} -gt ${FETCH_LIMIT} ] ; then
			echo "${FETCH_COUNTER} > ${FETCH_LIMIT}: Failed to fetch \"${PLUGIN_INFO_URL}\".  Bailing..."
			exit 1
		else

			if [ ${DEBUG} ] ; then
				echo "PLUGIN_PAGE: ${PLUGIN_PAGE}"
				echo "FETCH_COUNTER: ${FETCH_COUNTER}"
			fi

			FETCH_COUNTER=$(( ${FETCH_COUNTER} + 1 ))
			sleep 5
			GetPluginPage
		fi
	fi
}

function Plugins() {

	for PLUGIN in ${CURSE_PLUGINS} ; do

		PLUGIN_INFO_URL="http://www.curse.com/addons/wow/${PLUGIN}"

		if [ ${DEBUG} ] ; then
			if [ ${NOTDUMB} ] ; then
				echo "${BOLD}${BLUE}${PLUGIN}${RESET}"
			else
				echo "${PLUGIN}"
			fi
			echo "PLUGIN_INFO_URL: ${PLUGIN_INFO_URL}"
		fi

		GetPluginPage

		PLUGIN_EPOCH=$(echo "${PLUGIN_PAGE}" | grep Updated.*epoch | sed -e 's/.*data-epoch="//;s/">.*//')
		PLUGIN_PRETTY=$(date -d @${PLUGIN_EPOCH} "+%Y-%m-%d %r")
		PLUGIN_VERSION=$(echo "${PLUGIN_PAGE}" | grep newest-file | sed "s/.* \(.*\)<.*/\1/g")
		PLUGIN_TITLE=$(echo "${PLUGIN_PAGE_RAW}" | grep "og:title" | sed "s/.*content=\"\(.*\)\".*/\1/")
		PLUGIN_URL=$(curl -Ls ${PLUGIN_INFO_URL}/download | grep download-link | sed -e 's/.*data-href="//;s/zip" class=".*/zip/;s/ /%20/g')

		if [ ${DEBUG} ] ; then
			if [ ${NOTDUMB} ] ; then
				echo "${BOLD}${BLUE}${PLUGIN_TITLE}${RESET}"
			else
				echo "${PLUGIN_TITLE}"
			fi
#		else
#			echo "${PLUGIN_TITLE}"
		fi

		unset PLUGIN_PAGE

		[ ! ${DEBUG} ] && OUTPUT+="\"${PLUGIN}\"\\n"
		[ ! ${DEBUG} ] && OUTPUT+="Title: ${PLUGIN_TITLE}\\n"
		OUTPUT+="Update Time: ${PLUGIN_PRETTY}\\n"
		OUTPUT+="Current Version: ${PLUGIN_VERSION}\\n"
		OUTPUT+="CHANGES: ${PLUGIN_INFO_URL}#t1:changes\\n"

		Freshness ${PLUGIN_EPOCH} ${PLUGIN} "${PLUGIN_URL}" "${PLUGIN_VERSION}"

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
			echo -e "${OUTPUT}"
		fi

		unset OUTPUT
		FETCH_COUNTER=0
	done

}


function GPDawnbringer() {

	GP_URL="http://goingpriceaddon.com/download"

	GP_US_PAGE=$(curl -Ls "${GP_URL}" | grep href.*GoingPrice_US)

	GP_DB_URL="${GP_URL}/$(echo "${GP_US_PAGE}" | grep GoingPrice_US_Dawnbringer.*zip | awk -F\" '{print $4}' | sed 's/\/download\///')"

	GP_DB_EPOCH=$(basename "${GP_DB_URL}" | awk -F. '{print $3}')
	GP_DB_PRETTY=$(date -d @${GP_DB_EPOCH} "+%Y-%m-%d %r")

	OUTPUT+="\"GoingPrice_US_Dawnbringer\"\\n"
	OUTPUT+="Update Time: ${GP_DB_PRETTY}\\n"

	Freshness ${GP_DB_EPOCH} GoingPrice_Dawnbringer "${GP_DB_URL}" "${GP_DB_EPOCH}"

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
	fi

	unset OUTPUT
}


function WoWAuctionWGet() {

	[ ${DEBUG} ] && echo "WoWAuctionWGet"

	[ ! ${DEBUG} ] && Q="-q"


	wget ${Q} -O "${WOWUCTION_LUA_TEMP}" "${WOWUCTION_URL}/Tools/GetTSMDataStatic?dl=true&token=xe7bW9nG3wqdDVYJrrfVcA2"

	TRAP=$?
}

function WoWAuction() {

	[ ${DEBUG} ] && echo WoWAuction

	WOWUCTION_URL="http://www.wowuction.com/us/dawnbringer/alliance"

	WOWUCTION_LUA_LIVE="${ADDON_DIR}/TradeSkillMaster_WoWuction/tsm_wowuction.lua"
	WOWUCTION_LUA_TEMP="${ADDON_DIR}/TradeSkillMaster_WoWuction/tsm_wowuction.lua.tmp"

	[ -f ${WOWUCTION_LUA_TEMP} ] && rm -f ${WOWUCTION_LUA_TEMP}

	WOWUCTION_MINS_AGO="$(curl -Ls "${WOWUCTION_URL}" | grep "AH scanned.*ago" | sed "s/.*scanned \(.*\) ago/\1/" | tr -d \\r)"
	WOWUCTION_EPOCH=$(date -d "$(date -d @${NOW}) - ${WOWUCTION_MINS_AGO}" +%s)

	OUTPUT+="WOWUCTION_EPOCH:    ${WOWUCTION_EPOCH}\\n"
	OUTPUT+="WOWUCTION_MINS_AGO: ${CRON_TIME_AGO}\\n"

	if [ ${WOWUCTION_EPOCH} -gt ${CRON_TIME_AGO} ] ; then

		WoWAuctionWGet

		[ ${DEBUG} ] && echo "TRAP WoWAuctionWGet: ${TRAP}"

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
					echo "WOWUCTION_TEMP_EPOCH: $WOWUCTION_TEMP_EPOCH"
					echo "WOWUCTION_LIVE_EPOCH: $WOWUCTION_LIVE_EPOCH"
				fi

				if [ ${WOWUCTION_TEMP_EPOCH} -gt ${WOWUCTION_LIVE_EPOCH} ] ; then

					mv "${WOWUCTION_LUA_TEMP}" "${WOWUCTION_LUA_LIVE}"

					OUTPUT+="\"WoWAuction\" updated ${WOWUCTION_MINS_AGO} ago\\n"
					OUTPUT+="${WOWUCTION_URL}\\n"
					OUTPUT+="UPDATED: WoWAuction is up to date.\\n"

					if [ ${DEBUG} ] ; then
						echo -e "${OUTPUT}========="
					fi
				else
					rm -f "${WOWUCTION_LUA_TEMP}"

					OUTPUT+="\"WoWAuction\"\\n"
					OUTPUT+="Update Time: ${WOWUCTION_MINS_AGO} ago\\n"
					OUTPUT+="${WOWUCTION_URL}\\n"
					OUTPUT+="CURRENT: WoWAuction is up to date.\\n"

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
				[ ${DEBUG} ] && echo "  Pausing.  $(( ${WGET_TRIES} - ${WGET_LOOP} )) more tries... "
				sleep ${WGET_PAUSE}
				WoWAuction
			else
				[ ${DEBUG} ] && echo "  BAILING after ${WGET_TRIES} tries... "
			fi
		fi
	else
		OUTPUT+="\"WoWAuction\" updated ${WOWUCTION_MINS_AGO} ago\\n"
		OUTPUT+="${WOWUCTION_URL}\\n"
		OUTPUT+="CURRENT: WoWAuction is up to date.\\n"

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

	if [ ${UPDATES} ] ; then
#		UpdateGit
		exit 1
	fi
}

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
# 	wp)
# 		DEBUG="yes"
# 		FORCE="yes"
# 		WoWPro
# 		exit
# 		;;
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

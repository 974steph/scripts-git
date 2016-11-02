#!/bin/sh


function CountTime() {

	TIME_RAW=$1
	TIME_COUNT=0
	TIME_HOURS=0
	TIME_MINUTES=0
	TIME_SECONDS=0

	while [ ! ${TIME_COUNT} -gt ${TIME_RAW} ] ; do
		if [ ! $(( ${TIME_COUNT} + 60 )) -gt ${TIME_RAW} ] ; then
			TIME_COUNT=$(( ${TIME_COUNT} + 60 ))
			TIME_MINUTES=$(( ${TIME_MINUTES} + 1 ))

			if [ ${TIME_MINUTES} -gt 1 ] ; then TIME_MINUTES_S="s" ; fi

			if [ ${TIME_MINUTES} -eq 60 ] ; then
				TIME_HOURS=$(( ${TIME_HOURS} + 1 ))
				TIME_MINUTES=0

				if [ ${TIME_HOURS} -gt 1 ] ; then TIME_HOURS_S="s" ; fi
			fi

			TIME_SECONDS=$(( ${TIME_RAW} - ${TIME_COUNT} ))

			if [ ${TIME_SECONDS} -gt 1 ] ; then TIME_SECONDS_S="s" ; fi
		else
			[ "${TIME_HOURS}" -gt 0 ] && DURATION="${TIME_HOURS} hour${TIME_HOURS_S}"
			[ "${TIME_MINUTES}" -gt 0 ] && DURATION="$( [ "${DURATION}" ] && echo "${DURATION}, ")${TIME_MINUTES} minute${TIME_MINUTES_S}"
			[ "${TIME_SECONDS}" -gt 0 ] && DURATION="$( [ "${DURATION}" ] && echo "${DURATION}, ")${TIME_SECONDS} second${TIME_SECONDS_S}"

			echo "${DURATION}"
			DURATION=""
			break
		fi
	done
}


function HumanizeTime() {

# 	echo HumanizeTime

	S_YMD=$(date -d @${1} +%Y%m%d)
	E_YMD=$(date -d @${2} +%Y%m%d)
	TIME_TYPE=${3}

	D_YEARS="0"
	D_MONTHS="0"
	D_WEEKS="0"
	D_DAYS="0"
	unset DISPLAY

	#########
	# YEARS
	#
	while [ ! ${S_YMD} -gt $(date -d "${E_YMD} -1 years" +%Y%m%d) ] ; do
		if [ ! $(date -d "${S_YMD} +1 years" +%Y%m%d) -gt ${E_YMD} ] ; then
			S_YMD=$(date -d "${S_YMD} +1 years" +%Y%m%d)
			D_YEARS=$(( ${D_YEARS} + 1 ))
		else
			break
		fi

		[ ${D_YEARS} -gt 30 ] && exit

	done

	#########
	# MONTHS
	#
	while [ ! ${S_YMD} -gt $(date -d "${E_YMD} -1 months" +%Y%m%d) ] ; do
		if [ $(date -d "${S_YMD} +1 months" +%Y%m%d) ] ; then
			S_YMD=$(date -d "${S_YMD} +1 months" +%Y%m%d)
			D_MONTHS=$(( ${D_MONTHS} + 1 ))
		else
			break
		fi

		[ ${D_MONTHS} -gt 30 ] && exit
	done

	#########
	# WEEKS
	#
	while [ ! ${S_YMD} -gt $(date -d "${E_YMD} -1 weeks" +%Y%m%d) ] ; do
		if [ $(date -d "${S_YMD} +1 week" +%Y%m%d) ] ; then
			S_YMD=$(date -d "${S_YMD} +1 week" +%Y%m%d)
			D_WEEKS=$(( ${D_WEEKS} + 1 ))
		else
			break
		fi

		[ ${D_WEEKS} -gt 30 ] && exit
	done

	#########
	# DAYS
	#
	while [ ! ${S_YMD} -gt $(date -d "${E_YMD} -1 days" +%Y%m%d) ] ; do
		if [ $(date -d "${S_YMD} +1 days" +%Y%m%d) ] ; then
			S_YMD=$(date -d "${S_YMD} +1 days" +%Y%m%d)
			D_DAYS=$(( ${D_DAYS} + 1 ))
		else
			break
		fi

		[ ${D_DAYS} -gt 30 ] && exit
	done

	#########
	# MAKE PRETTY
	case ${TIME_TYPE} in

	FUZZY)
# 		echo FUZZY

		[ ${D_YEARS} -ne 1 ] && YS="s"
		[ ${D_YEARS} -ge 1 ] && [ ${D_MONTHS} -gt 0 -o ${D_WEEKS} -gt 0 -o ${D_DAYS} -gt 0 ] && DISPLAY="${D_YEARS} year${YS} and "
		[ ${D_YEARS} -ge 1 ] && DISPLAY="${D_YEARS} year${YS}"
		[ ${D_YEARS} -gt 0 ] && AND=" and "

		#########
		# Fuzzy Time Display
		#
		if [ ${D_MONTHS} -gt 0 ] ; then

			case ${D_WEEKS} in
				5)	[ $(( ${D_MONTHS} + 1 )) -gt 1 ] && MS="s"
					DISPLAY+="${AND}just over $(( ${D_MONTHS} + 1 )) month${MS}"
					;;
				4)	[ $(( ${D_MONTHS} + 1 )) -gt 1 ] && MS="s"
					DISPLAY+="${AND}just under $(( ${D_MONTHS} + 1 )) month${MS}"
					;;
				[2-3])	DISPLAY+="${AND}${D_MONTHS} 1/2 months"
					;;
				[0-1])	[ ${D_MONTHS} -gt 1 ] && MS="s"
					DISPLAY+="${AND}just over ${D_MONTHS} month${MS}"
					;;
			esac
		else
			if [ ${D_WEEKS} -gt 0 ] ; then
				[ ! ${D_WEEKS} -eq 1 ] && WS="s"
				if [ "${DISPLAY}" ] ; then DISPLAY+=", ${D_WEEKS} week${WS}" ; else DISPLAY="${D_WEEKS} week${WS}" ; fi
			fi
			if [ ${D_DAYS} -gt 0 ] ; then
				[ ! ${D_DAYS} -eq 1 ] && DS="s"
				if [ "${DISPLAY}" ] ; then DISPLAY+=", ${D_DAYS} day${DS}" ; else DISPLAY="${D_DAYS} day${DS}" ; fi
			fi
		fi
		;;
	EXACT)
# 		echo EXACT

		#########
		# Exact Time Display
		#
		if [ ${D_YEARS} -gt 0 ] ; then
			[ ! ${D_YEARS} -eq 1 ] && YS="s"
			if [ "${DISPLAY}" ] ; then DISPLAY+=", ${D_YEARS} year${YS}" ; else DISPLAY="${D_YEARS} year${YS}" ; fi
		fi
		if [ ${D_MONTHS} -gt 0 ] ; then
			[ ! ${D_MONTHS} -eq 1 ] && MS="s"
			if [ "${DISPLAY}" ] ; then DISPLAY+=", ${D_MONTHS} month${MS}" ; else DISPLAY="${D_MONTHS} month${MS}" ; fi
		fi
		if [ ${D_WEEKS} -gt 0 ] ; then
			[ ! ${D_WEEKS} -eq 1 ] && WS="s"
			if [ "${DISPLAY}" ] ; then DISPLAY+=", ${D_WEEKS} week${WS}" ; else DISPLAY="${D_WEEKS} week${WS}" ; fi
		fi
		if [ ${D_DAYS} -gt 0 ] ; then
			[ ! ${D_DAYS} -eq 1 ] && DS="s"
			if [ "${DISPLAY}" ] ; then DISPLAY+=", and ${D_DAYS} day${DS}" ; else DISPLAY="${D_DAYS} day${DS}" ; fi
		fi
		;;
	*)
		echo -e \\v"${1} || ${2} || ${3} || TELL ME WHAT TO DO"\\v
		exit
		;;
	esac

	echo ${DISPLAY}
}



DISPLAY=" "
# HumanizeTime START NOW

START=$1
NOW=$2
[ ! $NOW ] && NOW=$(date +%s)


# HumanizeTime $1 $2 EXACT
HumanizeTime $START $NOW EXACT

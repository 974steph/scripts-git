#!/usr/bin/env bash

#curl -sL "http://www.yourweatherservice.com/weather/cloudcroft/united-states/usnm0069" | awk '/left_column/,/advertising_content/' | tidy -b -wrap 1000 -q -ascii --tidy-mark false --show-warnings false | grep "forecast_summary_table_.*_column"

###########################
# VARS
TANK="$HOME/Pictures/Cams/Weather"

FETCH_COUNT=0
FETCH_LIMIT=5
###########################


# place, lat, lon
WEATHERS="Albuquerque,35.0853,-106.6056,US/Mountain \
	Bend,44.2595,-121.1712,US/Pacific \
	Prescott,34.5400,-112.4685,US/Mountain \
	SantaFe,35.6870,-105.9378,US/Mountain \
	Sedona,34.858866,-111.794797,US/Mountain \
	Tucson,32.2217,-110.9265,US/Mountain"



###########################
# GET WEATHER
function GetWeather() {

	PLACE=$(echo $1 | cut -d, -f1)
	LAT=$(echo $1 | cut -d, -f2)
	LON=$(echo $1 | cut -d, -f3)
	TZ=$(echo $1 | cut -d, -f4)

	NOW=$(TZ=${TZ} date +%s)
	DATE=$(TZ=${TZ} date -d @${NOW} +%Y-%m-%d)
	TIME=$(TZ=${TZ} date -d @${NOW} +%H:%M:%S)

	FILE_CSV="${TANK}/$(date +%Y)-${PLACE}.csv"

	if [ ${DEBUG} ] ; then
		echo "PLACE: $PLACE"
		echo "LAT: $LAT"
		echo "LON: $LON"
		echo "FILE_CSV: $FILE_CSV"
	fi

	[ ! -d "${TANK}" ] && mkdir - "${TANK}"

# 	WEATHER_FULL=$(curl -s "http://forecast.weather.gov/MapClick.php?lat=44.0583&lon=-121.314&unit=0&lg=english&FcstType=dwml" | xmllint --nowrap --noblanks --format -)

	WEATHER_URL="http://forecast.weather.gov/MapClick.php?lat=${LAT}&lon=${LON}&unit=0&lg=english&FcstType=dwml"

	WEATHER_FULL=$(curl -s "${WEATHER_URL}" | xmllint --nowrap --noblanks --format -)

	[ ${DEBUG} ] && echo "${PLACE}: ${WEATHER_URL}"

	if [ ! "${WEATHER_FULL}" ] ; then
		echo "CURL FAILED"
		echo "LINES IN RETURN: $(echo "${WEATHER_FULL}" | wc -l)"

		FETCH_COUNT=$(( ${FETCH_COUNT} + 1 ))

		if [ ! ${FETCH_COUNT} -gt ${FETCH_LIMIT} ] ; then
			echo "LOOP COUNT: ${FETCH_COUNT} - SLEEPING..."
			sleep 5
			echo "FETCHING..."
			GetWeather
		else
			echo "LOOP COUNT: ${FETCH_COUNT} - BAILING..."
			exit 1
		fi
	fi

#	CURR_COND=$(echo "${WEATHER_FULL}" | sed -n '/data type="current observations"/,$p' | grep "weather-summary" | sed 's/.*"\(.*\)".*/\1/')
	CURR_COND=$(echo "${WEATHER_FULL}" | awk '/data type="current observations"/,/weather-conditions weather-summary/' | tail -n1 | sed 's/^.*="\(.*\)".*/\1/')
	CURR_TEMP=$(echo "${WEATHER_FULL}" | grep -A1 temperature.*appar | tail -n 1 | sed 's/<[^>]\+>//g;s/ *//')
	CURR_HUMID=$(echo "${WEATHER_FULL}" | grep -A1 humidity.type | tail -n 1 | sed 's/<[^>]\+>//g;s/ *//')
	CURR_BARO=$(echo "${WEATHER_FULL}" | grep -A1 pressure.type | tail -n 1 | sed 's/<[^>]\+>//g;s/ *//')
	WIND_SUST=$(echo "${WEATHER_FULL}" | grep -A1 wind.*sustained | tail -n 1 | sed 's/<[^>]\+>//g;s/ *//')
	WIND_GUST=$(echo "${WEATHER_FULL}" | grep -A1 wind.*gust | tail -n 1 | sed 's/<[^>]\+>//g;s/ *//;s/NA/0/')
	WIND_DIRECT=$(echo "${WEATHER_FULL}" | grep -A1 direction.*wind | tail -n 1 | sed 's/<[^>]\+>//g;s/ *//;s/NA/0/')
}
###########################


###########################
# NORMAL
function Normal() {
	TZ=${TZ} date "+%Y-%m-%d %r"
	echo "${CURR_TEMP}°, ${CURR_COND} - ${CURR_HUMID}% - ${CURR_BARO}\""
}
###########################


###########################
# HOURLY
function Hourly() {


#	if [ "${NOW}" -a "${DATE}" -a "${TIME}" -a "${CURR_TEMP}" -a "${CURR_HUMID}" -a "${CURR_BARO}" -a "${CURR_COND}" ] ; then
	[ "${NOW}" ] && [ "${DATE}" ] && [ "${TIME}" ] && [ "${CURR_TEMP}" ] && [ "${CURR_HUMID}" ] && [ "${CURR_BARO}" ] && [ "${CURR_COND}" ] && GOT_EVERYTHING="yes"
	if [ "${GOT_EVERYTHING}" ] ; then
		[ ! -f ${FILE_CSV} ] && echo "Epoch,Date & Time,Temp,Humidity,Pressure,Wind,Gusts,Direction,Conditions" > ${FILE_CSV}
		[ ! ${DEBUG} ] && echo "${NOW},${DATE} ${TIME},${CURR_TEMP},${CURR_HUMID},${CURR_BARO},${WIND_SUST},${WIND_GUST},${WIND_DIRECT},${CURR_COND}" >> ${FILE_CSV}
	else
		if [ ${DEBUG} ] ; then
			echo "Missing info"
			echo "NOW: \"${NOW}\""
			echo "DATE: \"${DATE}\""
			echo "TIME: \"${TIME}\""
			echo "CURR_TEMP: \"${CURR_TEMP}\""
			echo "CURR_HUMID: \"${CURR_HUMID}\""
			echo "CURR_BARO: \"${CURR_BARO}\""
			echo "WIND_SUST: \"${WIND_SUST}\""
			echo "WIND_GUST: \"${WIND_GUST}\""
			echo "WIND_DIRECT: \"${WIND_DIRECT}\""
			echo "CURR_COND: \"${CURR_COND}\""
		fi
	fi

	if [ ${DEBUG} ] ; then
		echo "Epoch,Date & Time,Temp,Humidity,Pressure,Wind,Gusts,Direction,Conditions"
		echo "${NOW},${DATE} ${TIME},${CURR_TEMP},${CURR_HUMID},${CURR_BARO},${WIND_SUST},${WIND_GUST},${WIND_DIRECT},${CURR_COND}"
#		echo "Epoch,Date & Time,Temp,Humidity,Pressure,Conditions"
#		echo "${NOW},${DATE} ${TIME},${CURR_TEMP},${CURR_HUMID},${CURR_BARO},${CURR_COND}"
	fi
}
#########
case $1 in
	hourly)
		for WEATHER in ${WEATHERS} ; do
#			DEBUG="yes"
			GetWeather ${WEATHER}
			Hourly
		done
		;;
	debug)
		DEBUG="yes"
		for WEATHER in ${WEATHERS} ; do
			GetWeather ${WEATHER}
			Normal
			Hourly
			echo -e "\\v---------\\v"
		done
		exit
		;;
	*)
		for WEATHER in ${WEATHERS} ; do
			GetWeather ${WEATHER}
			Normal
		done
		;;
esac

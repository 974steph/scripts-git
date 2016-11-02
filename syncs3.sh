#!/bin/sh


NOW=$(date +%s)
YEAR=$(date -d @${NOW} +%Y)


S3_TANK="$HOME/S3"
IPS="$HOME/Scripts/ips.txt"
GEO_LOC="$HOME/Sources/scripts-git"

case $1 in
	all)
		unset TODAY
		;;
	*)
		TODAY=TRUE
		MONTH=$(date -d @${NOW} +%m)
		DAY=$(date -d @${NOW} +%d)
		;;
esac


# User agents:
# awk '{print substr($0,index($0,$15))}' $HOME/S3/2015/09/17/*log | sed 's/^"\(.*\)".*/\1/' | grep -v '-' | sort -u

#s3cmd --no-check-md5 sync s3://iv-all-in-one-dev-accesslogs/vcs-logs/AWSLogs/935536354681/elasticloadbalancing/us-east-1/${YEAR}/ ${S3_TANK}/${YEAR}/
s3cmd sync s3://iv-all-in-one-dev-accesslogs/vcs-logs/AWSLogs/935536354681/elasticloadbalancing/us-east-1/${YEAR}/ ${S3_TANK}/${YEAR}/

echo -e \\v"==========================="
echo -e "COMPLETED SYNC"
echo -e "==========================="\\v


if [ ${TODAY} ] ; then
	cd ${S3_TANK}/${YEAR}/${MONTH}/${DAY}
else
	cd ${S3_TANK}/${YEAR}/
fi

#grep -rihv " 200 200 " * | egrep -v '72.94.215.42|52.4.28.103|54.174.208.230' | awk '{print $3}' | sed -e 's/:.*//g' | sort -hu > ${IPS}

grep -rihv " [0-9]00 [0-9]00 " * | awk '{print $3}' | sed -e 's/:.*//g' | sort -n | uniq -c > ${IPS}

sed -i "s/^ \+//g" ${IPS}

cd ${GEO_LOC}

echo -e "Count\\tIP\\t\\tLocation"

x=0

while [ $x -le 50 ] ; do
        echo -n "="
        x=$(( $x + 1 ))
done

echo

${GEO_LOC}/geoip.php | sort -k1 -n




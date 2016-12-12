#!/usr/bin/env bash


BASE_URL="http://www.lolsotrue.com"

MAX_PAGE=$(curl -sL ${BASE_URL} | grep page= | sed 's/href/\n/g' | tail -n 2 | head -n1 | sed 's/.*page=\([0-9]\+\).*/\1/')


PAGE=$(( ( RANDOM % ${MAX_PAGE} )  + 1 ))

#echo "PAGE: $PAGE"

QUOTE_URL="${BASE_URL}/?page=${PAGE}"
echo $QUOTE_URL

#QUOTE=$(curl -sL "${QUOTE_URL}" | awk '/thumbnails/,/javascript/' | grep image.*lolsotrue | sed 's/.*alt=\"\(.*\)\"\/>.*/\1/')
QUOTE=$(curl -sL "${QUOTE_URL}" | awk '/thumbnails/,/javascript/' | grep image.*lolsotrue | sed "s/.*alt=\"\(.*\)/\1/;s/\"\/>.*//")

#echo "QUOTE: ${QUOTE}"
echo "${QUOTE}"

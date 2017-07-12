#!/usr/bin/env bash

URL_PB="http://pastebin.com/raw.php?i=tQjbSGrD"

echo -e \\v"URL_PB: ${URL_PB}"\\v

#URL_SHOW=$(curl -s "http://pastebin.com/raw.php?i=P88uHvbC" | grep -A1 THSS | grep -A1 $(date -d "$(date) - 1 day" +%-m-%-d-%Y) | tail -n1)

#URL_SHOW=$(curl -s "${URL_PB}" | grep -A1 THSS | grep -A1 $(date -d "$(date) - 1 day" +%-m-%-d-%Y) | tail -n1)

NOW=$(date +%s)

TODAY=$(date -d @${NOW} "+%-m-%d-%Y")
YESTERDAY=$(date -d "$(date -d @"${NOW}") - 1 day" +%-m-%d-%Y)

echo TODAY: $TODAY
echo YESTERDAY: $YESTERDAY
echo

URL_SHOW_T=$(curl -s "${URL_PB}" | grep -A1 THSS | grep -A1 ${TODAY} | tail -n1)
URL_SHOW_Y=$(curl -s "${URL_PB}" | grep -A1 THSS | grep -A1 ${YESTERDAY} | tail -n1)

echo URL_SHOW_T: $URL_SHOW_T
echo URL_SHOW_Y: $URL_SHOW_Y

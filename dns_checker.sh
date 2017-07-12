#!/usr/bin/env bash


#DEBUG="yes"


function Complain() {

	echo -e \\v"Usage:"\\v
	echo -e "$(basename $0) [DNS] [HOST]"\\v
	exit 1
}

[ ! "$1" -o ! "$2" ] && Complain

DNS="$1"
HOST="$2"

START=$(date +%s.%N)

OUTPUT=$(dig @${DNS} ${HOST})

TRAP=$?

END=$(date +%s.%N)


echo "scale=2;(${END} - ${START})" | bc


if [ ${DEBUG} ] ; then
	echo -e \\v"========="
	echo "$OUTPUT"
	echo "========="
	echo "TRAP: $TRAP"
	echo "========="
	echo "scale=2;${END} - ${START}" | bc
	echo "========="
	echo "START: $START"
	echo "========="
	echo -e "END: $END"\\v
fi

exit ${TRAP}


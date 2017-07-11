#!/bin/bash

TANKS="$HOME/GIT"

#DEBUG=TRUE

NOW=$(date +%s)
UPDATED=0
GIT_COUNTER=1
CHANGED=0
INSERTS=0
DELETES=0

R=$(tput setaf 1)
P=$(tput setaf 5)
LB=$(tput setaf 6)
B=$(tput bold)
N=$(tput sgr0)

case $(uname -s) in
	Darwin) SED=$(which gsed);;
	*) SED=$(which sed);;
esac


for DIR in ${TANKS} ; do
	GITS=$(( ${GITS} + $(find ${DIR} -type d -maxdepth 1 -mindepth 1 | wc -l) ))
done

echo

IFS_SAVE=$IFS
IFS=$'\n'

for GIT in ${TANKS} ; do
	for DIR in $(find ${GIT} -type d -maxdepth 1 -mindepth 1) ; do

		cd "${DIR}"

		echo "${B}$(basename ${DIR})${N} (${GIT_COUNTER} of ${GITS})"

		OUTPUT_FULL=$(git pull 2>&1)
#		echo ${OUTPUT_FULL}

#		OUTPUT=$(git pull 2>&1 | egrep -i "changed.*insertions.*deletions|up-to-date" | ${SED} 's/^\ \+//')
		OUTPUT_CHANGES=$(echo "${OUTPUT_FULL}" | egrep -i "changed.*insertion|changed.*deletion|up-to-date" | ${SED} 's/^\ \+//')


#		if [[ "${OUTPUT_CHANGES}" =~ .*change.*insertion.*deletion.* ]] ; then
		if [ "$(echo ${OUTPUT_CHANGES} | egrep "file.*insertion|file.*deletion")" ] ; then
#			echo "OUTPUT_CHANGES: $OUTPUT_CHANGES"
			echo -e "${LB}${OUTPUT_CHANGES}${N}"

			UPDATED=$(( ${UPDATED} + 1 ))

#			12 files changed, 158 insertions(+), 16 deletions(-)

			[ "$(echo ${OUTPUT_CHANGES} | awk '{print $1}')" ] && CHANGED=$(( ${CHANGED} + $(echo ${OUTPUT_CHANGES} | awk '{print $1}') ))
#			CHANGED=$(( ${CHANGED} + $(echo "${OUTPUT_CHANGES}" | ${SED} 's/.*\([0-9]\+\) file.*changed.*/\1/') ))
			[ ${DEBUG} ] && echo -e "\\tCHANGED: $CHANGED"

			[ "$(echo ${OUTPUT_CHANGES} | awk '{print $4}')" ] && INSERTS=$(( ${INSERTS} + $(echo ${OUTPUT_CHANGES} | awk '{print $4}') ))
#			INSERTS=$(( ${INSERTS} + $(echo "${OUTPUT_CHANGES}" | ${SED} 's/.*\([0-9]\+\) insertion.*/\1/') ))
			[ ${DEBUG} ] && echo -e "\\tINSERTS: $INSERTS"

			[ "$(echo ${OUTPUT_CHANGES} | awk '{print $6}')" ] && DELETES=$(( ${DELETES} + $(echo ${OUTPUT_CHANGES} | awk '{print $6}') ))
#			DELETES=$(( ${DELETES} + $(echo "${OUTPUT_CHANGES}" | ${SED} 's/.*\([0-9]\+\) deletion.*/\1/') ))
			[ ${DEBUG} ] && echo -e "\\tDELETES: $DELETES"
		else
			echo -e "${R}${OUTPUT_FULL}${N}"
		fi

		GIT_COUNTER=$(( ${GIT_COUNTER} + 1 ))

		[ ${GIT_COUNTER} -le ${GITS} ] && echo "---------"
	done
done

if [ ${UPDATED} -gt 0 ] ; then
	echo -e "\\v${B}${P}It took $(( $(date +%s) - ${NOW} )) seconds to update ${UPDATED} of ${GITS} repos.${N}"
#	echo -e "Totals:"
	echo -e "\\tFiles Changed: ${CHANGED}"
	echo -e "\\tInsertions: ${INSERTS}"
	echo -e "\\tDeletions: ${DELETES}"
else
	echo -e "\\v${B}${P}It took $(( $(date +%s) - ${NOW} )) seconds to check ${GITS} repos.${N}\\v"
fi

IFS=$SAVE_IFS

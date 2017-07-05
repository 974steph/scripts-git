#!/bin/bash

TANKS="$HOME/GIT"
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


for DIR in ${TANKS} ; do
	GITS=$(( ${GITS} + $(find ${DIR} -type d -maxdepth 1 -mindepth 1 | wc -l) ))
done

echo

for GIT in ${TANKS} ; do
	for DIR in $(find ${GIT} -type d -maxdepth 1 -mindepth 1) ; do

		cd "${DIR}"

		echo "${B}$(basename ${DIR})${N} (${GIT_COUNTER} of ${GITS})"

		OUTPUT_FULL=$(git pull 2>&1)
#		echo ${OUTPUT_FULL}

#		OUTPUT=$(git pull 2>&1 | egrep -i "changed.*insertions.*deletions|up-to-date" | gsed 's/^\ \+//')
		OUTPUT_CHANGES=$(echo ${OUTPUT_FULL} | egrep -i "changed.*insertions.*deletions|up-to-date" | gsed 's/^\ \+//')

		if [[ "${OUTPUT_CHANGES}" =~ .*changed.*insertions.*deletions.* ]] ; then
			echo -e "${LB}${OUTPUT_CHANGES}${N}"
			UPDATED=$(( ${UPDATED} + 1 ))
			CHANGED=$(( ${CHANGED} + $(echo ${OUTPUT} | awk '{print $1}') ))
			INSERTS=$(( ${INSERTS} + $(echo ${OUTPUT} | awk '{print $4}') ))
			DELETES=$(( ${DELETES} + $(echo ${OUTPUT} | awk '{print $6}') ))
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

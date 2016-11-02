#!/bin/sh

TANKS="$HOME/GIT $HOME/PROJ"

X=1
G=1
GITS=0

for DIR in ${TANKS} ; do
	GITS=$(( $GITS + $(find ${DIR} -type d -maxdepth 1 -mindepth 1 | wc -l) ))
done

echo

for GIT in $TANKS ; do
	for DIR in $(find ${GIT} -type d -maxdepth 1 -mindepth 1) ; do 
		cd "${DIR}"
		echo "$(basename ${DIR}) ($G of $GITS)"
		git pull
		X=$(( ${X} + 1 ))
		if [ ${X} -le ${GITS} ] ; then
			echo "---------"
		else
			echo
		fi

		G=$(( $G + 1 ))
	done
done

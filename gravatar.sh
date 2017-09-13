#!/usr/bin/env bash

# http://www.gravatar.com/avatar/4808425a0ad520365473eb2d0badc397?s=512&r=pg&d=identicon

# Get Image:
# http://en.gravatar.com/site/implement/images/

# Get profile:
# http://en.gravatar.com/site/implement/profiles/

function DumpHelp() {
	echo -e "\\v$0 [EMAIL] [STYLE]\\v"
	echo -e "STYLE is optional.  Choices are:"
	echo -e "\tidenticon"
	echo -e "\tmonsterid"
	echo -e "\tretro"
	echo -e "\twavatar"
	exit 1
}


if [ $# -eq 0 ] ; then
	DumpHelp
else
	EMAIL="$1"
fi

case $2 in
	identicon) STYLE=$2;;
	monsterid) STYLE=$2;;
	retro) STYLE=$2;;
	wavatar) STYLE=$2;;
#	*) DumpHelp;;
esac

HASH=$(echo "${EMAIL}" | tr '[:upper:]' '[:lower:]' | md5)

STYLES="identicon monsterid retro wavatar"
RATINGS="g pg r x"

if [ ${STYLE} ] ; then
#	for RATING in ${RATINGS} ; do
#		wget "http://www.gravatar.com/avatar/${HASH}?s=512&r=${RATING}&d=${STYLE}" -O "${EMAIL}-${STYLE}-${RATING}.jpg"
		wget --quiet --show-progress "http://www.gravatar.com/avatar/${HASH}?s=512&r=x&d=${STYLE}" -O "${EMAIL}-${STYLE}.jpg"
#	done
else
	for STYLE in ${STYLES} ; do
#		for RATING in ${RATINGS} ; do
#			echo "Getting ${STYLE}-${RATING}"
#			wget "http://www.gravatar.com/avatar/${HASH}?s=512&r=${RATING}&d=${STYLE}" -O "${EMAIL}-${STYLE}-${RATING}.jpg"
			echo "Getting ${STYLE}"
			wget --quiet --show-progress "http://www.gravatar.com/avatar/${HASH}?s=512&r=x&d=${STYLE}" -O "${EMAIL}-${STYLE}.jpg"
#		done
	done
fi

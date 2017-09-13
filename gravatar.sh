#!/usr/bin/env bash

# http://www.gravatar.com/avatar/4808425a0ad520365473eb2d0badc397?s=512&r=pg&d=identicon

# Get Image:
# http://en.gravatar.com/site/implement/images/

# Get profile:
# http://en.gravatar.com/site/implement/profiles/

function DumpHelp() {
	echo -e "\\v$0 [EMAIL]\\v"
	exit 1
}


if [ $# -eq 0 ] ; then
	DumpHelp
else
	EMAIL="$1"
fi


HASH=$(echo "${EMAIL}" | tr '[:upper:]' '[:lower:]' | md5)

STYLES="identicon monsterid wavatar retro"
RATINGS="g pg r x"

for STYLE in ${STYLES} ; do
	for RATING in ${RATINGS} ; do
		echo "Getting ${STYLE}-${RATING}"
		wget "http://www.gravatar.com/avatar/${HASH}?s=512&r=${RATING}&d=${STYLE}" -O ${EMAIL}-${STYLE}-${RATING}.jpg
	done
done


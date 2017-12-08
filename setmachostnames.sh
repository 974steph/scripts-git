#!/usr/bin/env bash


if [ $# -ne 1 ] ; then
	echo -e "\\vIf you are trying to set a hostname to something with a space in it,\\nyou need to use double quotes around the name.  Bailing...\\v"
	exit 1
fi

if [ $UID -ne 0 ] ; then
	echo -e "\\vYou need to be root to run this.  Bailing...\\v"
	exit 2
fi

if [ ! "$1" ] ; then
	echo -e "\\vYou must supply a hostname.  Bailing...\\v"
	exit 3
fi

THISNAME="$1"

for I in ComputerName HostName LocalHostName ; do

#	echo I: $I

	if [ $I == "LocalHostName" ] ; then

		THISNAME=$(echo "$1" | sed 's/[. _]/-/g')

		echo -e "$I cannot contain certain characters.  Substituting a dash: \"${THISNAME}\""
	fi

	scutil --set $I "$THISNAME"
	TRAP=$?

	if [ ${TRAP} -eq 0 ] ; then
		echo "Set $I to \"$THISNAME\""
	else
		echo "Failed to set $I to \"$THISNAME\""
	fi

	unset TRAP
done

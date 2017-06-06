#!/usr/bin/env bash

#DEBUG="YES"

SAVEIFS=${IFS}
IFS=$(echo -en "\n\b")

#for HD in $(VBoxManage list hdds | egrep "^UUID|^Location" | gsed 's/: \+/=/') ; do
#	echo HD: $HD
#done
#exit

VDIDIR=$(VBoxManage list systemproperties | grep "Default machine folder:" | cut -d : -f2- | sed 's/^ \+//')
DIRSIZE=$(du -hs "${VDIDIR}" | awk '{print $1}')
echo "Dir size: ${DIRSIZE}"

for HD in $(VBoxManage list hdds | egrep "^UUID|^Location" | gsed 's/: \+/=/') ; do

#	echo HD: $HD
	if [ "$(echo $HD | grep UUID)" ] ; then
		[ ${DEBUG} ] && echo "FOUND UUID"
		eval $HD
		[ ${DEBUG} ] && echo -e "\\tUUID: \"$UUID\""
	fi

	if [ "$(echo $HD | grep Location)" ] ; then
		[ ${DEBUG} ] && echo "FOUND LOCATION"
		HD=$(echo $HD | sed 's/ /\\ /')
		eval "$HD"
		[ ${DEBUG} ] && echo -e "\\tLocation: \"$Location\""
	fi

	if [ "${UUID}" -a "${Location}" ] ; then

		[ ${DEBUG} ] && echo "GOT BOTH"

		basename "${Location}"
#		NAME=$(basename "${Location}")
#		echo -e "\\tNAME: ${NAME}"
#		echo "${NAME}"

		echo "Old Size: $(du -h "${Location}" | awk '{print $1}')"

		VBoxManage modifyhd --compact "${UUID}"

		echo "New Size: $(du -h "${Location}" | awk '{print $1}')"

		unset UUID
		unset Location

		echo "========="
	else

#		[ ${DEBUG} ] && echo "HD: $HD"
		[ ${DEBUG} ] && echo "LOOP"
	fi

#	[ ${DEBUG} ] && echo "========="

done

DIRSIZE=$(du -hs "${VDIDIR}" | awk '{print $1}')
echo "Dir size: ${DIRSIZE}"

IFS=${SAVEIFS}


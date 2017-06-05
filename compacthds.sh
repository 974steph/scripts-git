#!/usr/bin/env bash

#DEBUG="YES"

SAVEIFS=${IFS}
IFS=$(echo -en "\n\b")

for HD in $(VBoxManage list hdds | egrep "^UUID|^Location" | gsed 's/: \+/=/') ; do

	if [ "${UUID}" -a "${Location}" ] ; then

		[ ${DEBUG} ] && echo "GOT BOTH"

		NAME=$(basename "${Location}")
		echo "${NAME}"

		echo "Old Size: $(du -h "${Location}" | awk '{print $1}')"

		VBoxManage modifyhd --compact "${UUID}"

		echo "New Size: $(du -h "${Location}" | awk '{print $1}')"

		unset UUID Location

		echo "========="
	else
		if [ "$(echo $HD | grep UUID)" ] ; then
			[ ${DEBUG} ] && echo "FOUND UUID"
			eval $HD
			[ ${DEBUG} ] && echo "UUID: \"$UUID\""
		fi

		if [ "$(echo $HD | grep Location)" ] ; then
			[ ${DEBUG} ] && echo "FOUND LOCATION"
			HD=$(echo $HD | sed 's/ /\\ /')
			eval "$HD"
			[ ${DEBUG} ] && echo "Location: \"$Location\""
		fi

		[ ${DEBUG} ] && echo "HD: $HD"
	fi

[ ${DEBUG} ] && echo "========="

done

IFS=${SAVEIFS}

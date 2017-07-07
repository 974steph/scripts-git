#!/usr/bin/env bash

#DEBUG="YES"

R=$(tput setaf 1)
P=$(tput setaf 5)
LB=$(tput setaf 6)
B=$(tput bold)
N=$(tput sgr0)

SAVEIFS=${IFS}
IFS=$(echo -en "\n\b")

if [ "${Apple_PubSub_Socket_Render}" ] ; then
	SED=$(which gsed)
else
	SED=$(which sed)
fi

VDIDIR=$(VBoxManage list systemproperties | grep "Default machine folder:" | cut -d : -f2- | ${SED} 's/^[\ \t]\+//g')
DIRSIZE=$(du -hs "${VDIDIR}" | awk '{print $1}')

echo -e "\\v${B}${VDIDIR}: ${DIRSIZE}${N}\\v"

for HD in $(VBoxManage list hdds | egrep "^UUID|^Location|^State" | gsed 's/: \+/=/') ; do

	if [ "$(echo $HD | grep UUID)" ] ; then
		[ ${DEBUG} ] && echo "FOUND UUID"
		eval $HD
		[ ${DEBUG} ] && echo -e "\\tUUID: \"$UUID\""
	fi

	if [ "$(echo $HD | grep Location)" ] ; then
		[ ${DEBUG} ] && echo "FOUND LOCATION"
		HD=$(echo $HD | ${SED} 's/ /\\ /')
		eval "$HD"
		[ ${DEBUG} ] && echo -e "\\tLocation: \"$Location\""
	fi

	if [ "$(echo $HD | grep State)" ] ; then
		[ ${DEBUG} ] && echo "FOUND STATE"
		HD=$(echo $HD | ${SED} 's/ /\\ /')
		eval "$HD"
		[ ${DEBUG} ] && echo -e "\\tState: \"$State\""
	fi

	if [ "${UUID}" -a "${Location}" -a "${State}" ] ; then

		[ ${DEBUG} ] && echo "GOT ALL"

		if [ "${State}" == "created" ] ; then
			echo "${LB}$(basename ${Location})${N} - ${UUID}"

			echo "Size before compact: $(du -h "${Location}" | awk '{print $1}')"

			VBoxManage modifyhd --compact "${UUID}"

			echo "Size after compact: $(du -h "${Location}" | awk '{print $1}')"

		else
			echo "${LB}$(basename ${Location})${N} - ${UUID}"
			echo "Size: $(du -h "${Location}" | awk '{print $1}')"
			echo "${R}$(basename ${Location}) is in use.  Skipping...${N}"
		fi

		unset UUID
		unset Location

		echo
	else

		[ ${DEBUG} ] && echo "LOOP"
	fi
done

DIRSIZE=$(du -hs "${VDIDIR}" | awk '{print $1}')
echo -e "${B}${VDIDIR}: ${DIRSIZE}${N}\\v"

IFS=${SAVEIFS}

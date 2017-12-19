#!/usr/bin/env bash

#DEBUG="YES"

R=$(tput setaf 1)
P=$(tput setaf 5)
LB=$(tput setaf 6)
B=$(tput bold)
N=$(tput sgr0)

SAVEIFS=${IFS}
IFS=$(echo -en "\n\b")

#OSNAME=$(uname -s)
#echo "OSNAME: \"${OSNAME}\""

#case ${OSNAME} in
#	Linux)
#		SED=$(which sed)
#		echo "${OSNAME} uses \"sed\"
#		;;
#	Darwin)
#		SED=$(which gsed)
#		echo "${OSNAME} uses \"gsed\"
#		;;
#	*)	echo -e "\\vYour OS is ${OSNAME}.  I don't know what sed to use.  Bailing...\\v"
#		exit
#		;;
#esac
#exit

if [ "${Apple_PubSub_Socket_Render}" ] ; then
	SED=$(which gsed)
else
	SED=$(which sed)
fi

VDIDIR=$(VBoxManage list systemproperties | grep "Default machine folder:" | cut -d : -f2- | ${SED} 's/^[\ \t]\+//g')
DIRSIZE_BEFORE=$(du -hs "${VDIDIR}" | awk '{print $1}')

echo -e "\\v${B}${VDIDIR}: ${DIRSIZE_BEFORE}${N}\\v"

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

			SIZE_BEFORE=$(du -h "${Location}" | awk '{print $1}')
			echo "Size before compact: ${SIZE_BEFORE}"

			VBoxManage modifyhd --compact "${UUID}"

			SIZE_AFTER=$(du -h "${Location}" | awk '{print $1}')

			if [ "$(echo "$(echo ${SIZE_BEFORE} | sed 's/[a-zA-Z]//') > $(echo ${SIZE_AFTER} | sed 's/[a-zA-Z]//')" | bc)" -eq 1 ] ; then
				SIZE_FREED=$(echo "$(echo ${SIZE_BEFORE} | sed 's/[a-zA-Z]//') - $(echo ${SIZE_AFTER} | sed 's/[a-zA-Z]//')" | bc)

				echo "Size after compact: ${SIZE_AFTER} (${SIZE_FREED}G freed)"
			else
				echo "Size after compact: ${SIZE_AFTER}"
			fi
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

DIRSIZE_AFTER=$(du -hs "${VDIDIR}" | awk '{print $1}')

if [ $(echo "$(echo ${DIRSIZE_BEFORE} | sed 's/[a-zA-Z]//') > $(echo ${DIRSIZE_AFTER} | sed 's/[a-zA-Z]//')" | bc) -eq 1 ] ; then
	DIRSIZE_FREED=$(echo "$(echo ${DIRSIZE_BEFORE} | sed 's/[a-zA-Z]//') - $(echo ${DIRSIZE_AFTER} | sed 's/[a-zA-Z]//')" | bc)
	echo -e "${B}${VDIDIR}: ${DIRSIZE_AFTER} (${DIRSIZE_FREED}G freed)${N}\\v"
else
	echo -e "${B}${VDIDIR}: ${DIRSIZE_AFTER}${N}\\v"
fi

IFS=${SAVEIFS}

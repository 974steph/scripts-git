#!/usr/bin/env bash

#case $(hostname) in
#	aragorn) STOP=YES;;
#	toa-tahu) STOP=YES;;
#esac

#if [ ${STOP} ] ; then
if [[ ! $(hostname) =~ vbox.* ]] ; then
	echo -e "\\vRefusing to run on $(hostname).  Bailing...\\v"
	exit
fi

B=$(tput bold)
W=$(tput setaf 7)
LB=$(tput setaf 153)
N=$(tput sgr0)

function doZero() {

	MOUNT="$1"

	echo -e "${B}${LB}Zeroing ${MOUNT}${N}\\v"

	sudo dd if=/dev/zero of=${MOUNT}/zero bs=1M
	sudo rm -fv ${MOUNT}/zero
}

function BuildCaches() {
	for USER in $(grep ^users: /etc/group | cut -d: -f4- | sed 's/,/ /g') ; do
		HOMECACHE+="$(awk -F: "/^$USER/ {print \$6}" /etc/passwd)/.cache "
	done
}

function cleanCaches() {

	for CACHE in ${CACHES} ; do
		CSIZE=$(du -hs ${HOME}/.cache | awk '{print $1}')

		NAME=$(basename "${CACHE}")
		TOUCHF="/tmp/touchref_${NAME}"

		TYPE=$(file -b "${CACHE}" | sed 's/.*\/\(.*\)\; .*/\1/')

		touch -r "${CACHE}" "${TOUCHF}"
		chmod --reference "${CACHE}" "${TOUCHF}"
		[ -s "${CACHE}" ] && LINK=$(readlink "${CACHE}")

		rm -rf "${CACHE}"

		case ${TYPE} in
			directory)
				mkdir -p "${CACHE}"
				chmod --reference "${TOUCHF}" "${CACHE}"
				touch -r "${TOUCHF}" "${CACHE}"
				;;
			symlink)
				ln -s "${LINK}" "${CACHE}"
				chmod --reference "${TOUCHF}" "${CACHE}"
				touch -r "${TOUCHF}" "${CACHE}"
				;;
			*)
				chmod --reference "${TOUCHF}" "${CACHE}"
				touch -r "${TOUCHF}" "${CACHE}"
				;;
		esac

		rm -f "${TOUCHF}"

		echo -e "${B}${LB}Cleaned ${CSIZE} from ${CACHE}${N}"

		unset CSIZE NAME TOUCHF

	done

	echo -e \\v
}

if [ -f /etc/lsb-release ] ; then
	source /etc/lsb-release

#	echo -e "DISTRIB_ID: \"$DISTRIB_ID\""

	if [[ $DISTRIB_ID =~ .*Gentoo.* ]] ; then
		source /etc/portage/make.conf

		echo -e "${B}${LB}Clean ${DISTDIR}${N}\\v"
		sudo find "${DISTDIR}" -type f -exec rm -f "{}" \;

		echo -e "${B}${LB}Clean ${PORT_LOGDIR}${N}\\v"
		sudo find "${PORT_LOGDIR}" -mtime +14 -type f -exec rm -f "{}" \;

		CACHES="${HOME}/.cache"
		cleanCaches

		MOUNTS="${HOME} /usr/local"
		WORKS=TRUE
	elif [[ $DISTRIB_ID =~ .*Arch.* ]] ; then

		echo -e "${B}${LB}Cleaning${N}\\v"
#		pacaur -Sc --noconfirm
		sudo find /var/cache/pacman/pkg/ -type f -exec rm -f "{}" \;

		BuildCaches

		CACHES="${HOMECACHE}"

		cleanCaches

		MOUNTS="${HOME}"
		WORKS=TRUE
	elif [[ $DISTRIB_ID =~ .*ManjaroLinux.* ]] ; then

		echo -e "${B}${LB}Cleaning${N}\\v"
		pacaur -Sc --noconfirm
		sudo find /var/cache/pacman/pkg/ -type f -exec rm -f "{}" \;

		CACHES="${HOME}/.cache"
		cleanCaches

		MOUNTS="${HOME}"
		WORKS=TRUE
	elif [[ $DISTRIB_ID =~ .*Ubuntu*. ]] ; then

		echo -e "${B}${LB}Autoremoving${N}\\v"
		sudo apt-get -y autoremove

		echo -e "${B}${LB}Purging${N}\\v"
		sudo apt-get -y purge $(dpkg-query -l | awk '/^rc/ {print $2}')

		echo -e "${B}${LB}Cleaning${N}\\v"
		sudo apt-get -y clean all

		BuildCaches

		CACHES="${HOMECACHE}"

		cleanCaches

		MOUNTS="${HOME}"
		WORKS=TRUE
	else
		echo -e "DISTRIB_ID: \"$DISTRIB_ID\".  I dunno.\\v"
		exit
	fi
fi

[ ! $WORKS ] && exit

for MOUNT in $MOUNTS ; do
	doZero ${MOUNT}
done

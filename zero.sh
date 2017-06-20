#!/usr/bin/env bash


B=$(tput bold)
W=$(tput setaf 7)
LB=$(tput setaf 153)
N=$(tput sgr0)

function doZero() {

	MOUNT="$1"

	echo -e "\\v${B}${LB}Zeroing ${MOUNT}${N}\\v"

	sudo dd if=/dev/zero of=${MOUNT}/zero bs=1M
	sudo rm -fv ${MOUNT}/zero
}


if [ -f /etc/lsb-release ] ; then
	source /etc/lsb-release

#	echo -e "DISTRIB_ID: \"$DISTRIB_ID\""

	if [[ $DISTRIB_ID =~ .*Gentoo.* ]] ; then
		source /etc/portage/make.conf

		echo -e "\\v${B}${LB}Clean ${DISTDIR}${N}\\v"
		sudo find "${DISTDIR}" -type f -exec rm -f "{}" \;

		echo -e "\\v${B}${LB}Clean ${PORT_LOGDIR}${N}\\v"
		sudo find "${PORT_LOGDIR}" -mtime +14 -type f -exec rm -f "{}" \;

		echo -e "\\v${B}${LB}Clean Caches${N}\\v"
		rm -rf ${HOME}/.cache

		MOUNTS="${HOME} /usr/local"
		WORKS=TRUE
	elif [[ $DISTRIB_ID =~ .*Arch.* ]] ; then

		echo -e "\\v${B}${LB}Cleaning${N}\\v"
		pacaur -Sc --noconfirm
		sudo find /var/cache/pacman/pkg/ -type f -exec rm -f "{}" \;

		echo -e "\\v${B}${LB}Clean Caches${N}\\v"
		rm -rf ${HOME}/.cache

		MOUNTS="${HOME}"
		WORKS=TRUE
	elif [[ $DISTRIB_ID =~ .*Ubuntu*. ]] ; then

		echo -e "\\v${B}${LB}Autoremoving${N}\\v"
		sudo apt-get -y autoremove

		echo -e "\\v${B}${LB}Purging${N}\\v"
		sudo apt-get -y purge $(dpkg-query -l | awk '/^rc/ {print $2}')

		echo -e "\\v${B}${LB}Cleaning${N}\\v"
		sudo apt-get -y clean

		echo -e "\\v${B}${LB}Clean Caches${N}\\v"
		rm -rf ${HOME}/.cache

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

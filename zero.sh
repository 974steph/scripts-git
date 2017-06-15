#!/usr/bin/env bash


B=$(tput bold)
N=$(tput sgr0)

function doZero() {

	MOUNT="$1"

	echo "Zeroing ${MOUNT}"
	sudo dd if=/dev/zero of=${MOUNT}/zero bs=1M
	sudo rm -fv ${MOUNT}/zero
}


if [ -f /etc/lsb-release ] ; then
	source /etc/lsb-release

	echo -e "DISTRIB_ID: \"$DISTRIB_ID\""

	if [[ $DISTRIB_ID =~ .*Gentoo.* ]] ; then
		source /etc/portage/make.conf

		echo -e "\\v${B}Clean ${DISTDIR}${N}\\v"
		sudo find "${DISTDIR}" -type f -exec rm -f "{}" \;

		echo -e "\\v${B}Clean ${PORT_LOGDIR}${N}\\v"
		sudo find "${PORT_LOGDIR}" -mtime +14 -type f -exec rm -f "{}" \;
		MOUNTS="${HOME} /usr/local"
		WORKS=TRUE
	elif [[ $DISTRIB_ID =~ .*Arch.* ]] ; then
		MOUNTS="${HOME}"
		WORKS=TRUE
	elif [[ $DISTRIB_ID =~ .*Ubuntu*. ]] ; then
		MOUNTS="${HOME}"

		echo -e "\\v${B}AUTOREMOVING${N}\\v"
		sudo apt-get -y autoremove

		echo -e "\\v${B}PURGING${N}\\v"
		sudo apt-get -y purge $(dpkg-query -l | awk '/^rc/ {print $2}')

		echo -e "\\v${B}CLEANING${N}\\v"
		sudo apt-get -y clean

		WORKS=TRUE
	else
		echo -e "DISTRIB_ID: \"$DISTRIB_ID\".  I dunno.\\v"
		exit
	fi
fi

echo "MOUNTS: \"$MOUNTS\""

[ ! $WORKS ] && exit

for MOUNT in $MOUNTS ; do
	doZero ${MOUNT}
done

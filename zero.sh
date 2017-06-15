#!/usr/bin/env bash


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
		sudo find "${DISTDIR}" -type f -exec rm -f "{}" \;
		sudo find "${PORT_LOGDIR}" -mtime +14 -type f -exec rm -f "{}" \;
		MOUNTS="${HOME} /usr/local"
		WORKS=TRUE
	elif [[ $DISTRIB_ID =~ .*Arch.* ]] ; then
		MOUNTS="${HOME}"
		WORKS=TRUE
	elif [[ $DISTRIB_ID =~ .*Ubuntu*. ]] ; then
		MOUNTS="${HOME}"
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

#!/usr/bin/env bash

source /etc/portage/make.conf

find "${DISTDIR}" -type f -exec rm -fv "{}" \;

MOUNTS="${HOME} /usr/local"

for MOUNT in $MOUNTS ; do
	echo "Zeroing ${MOUNT}"
	sudo dd if=/dev/zero of=${MOUNT}/zero bs=1M
	sudo rm -fv ${MOUNT}/zero
done

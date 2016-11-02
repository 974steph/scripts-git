#!/bin/sh

if [ ! $(whoami) == "root" ] ; then
	echo -e "\\vYou are not root.\\v"
#	exit 1
fi

# PHONE: 8C:3A:E3:60:5C:66
# LAPTOP: 88:53:2e:d7:96:64

MACS="8C:3A:E3:60:5C:66 88:53:2e:d7:96:64"

SITES="mythicspoiler.com vid.lsw.redtubefiles.com cdn-tp1.mozu.com \
	www.youtube.com googlevideo.com"

KribriloUp() {

	MAC=$1
	SITE=$2

	RULE="iptables -I FORWARD 1 -p tcp --destination ${SITE} -m mac --mac-source ${MAC} -j DROP"

	${RULE}
	TRAP=$?

	if [ ${TRAP} -eq 0 ] ; then
		echo "ADDED: ${RULE}"
	else
		echo "FAILED: ${RULE}"
	fi

	unset TRAP
}


KribriloDown() {


#	for IP in $(iptables -n -L FORWARD | grep 8C:3A:E3:60:5C:66 | awk '{print $5}') ; do iptables -D FORWARD -p tcp --destination $IP -m mac --mac-source 8C:3A:E3:60:5C:66 -j DROP ; done

	RULE="iptables -D FORWARD -p tcp --destination ${SITE} -m mac --mac-source ${MAC} -j DROP"

	${RULE}
	TRAP=$?

	if [ ${TRAP} -eq 0 ] ; then
		echo "DELETED: ${RULE}"
	else
		echo "FAILED: ${RULE}"
	fi

	unset TRAP
}

case $1 in

	up)
		CMDOK="yes"

		for SITE in ${SITES} ; do

			for MAC in ${MACS} ; do

				KribriloUp ${MAC} ${SITE}
			done
		done
		;;

	down)
		CMDOK="yes"

		for MAC in ${MACS} ; do

			for SITE in ${SITES} ; do

				KribriloDown ${MAC} ${SITE}
			done
		done
		;;
	*)
		echo -e "\\vYou must use $(basename $0) \"up\" or \"down\".\\v"
		exit 2
		;;
esac

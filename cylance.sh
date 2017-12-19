#!/usr/bin/env bash

function DumpHelp() {

	echo $1

	case $1 in
		args)	echo -e "\\vYou need to supply \"on\" or \"off\""
			echo -e "\\v$(basename $0) [on|off]\\v"
			;;
		root)	echo -e "\\vYou need to sudo or be root."
			echo -e "\\v$(basename $0) [on|off]\\v"
			;;
		*)	echo -e "\\v\"$1\" is unknown.  Bailing...\\v"
			;;
	esac

	exit 1
}

[ $# -ne 1 ] && DumpHelp args
[ $UID -ne 0 ] && DumpHelp root

if [ ! "$(find /Library/Launch* -iname '*cylance*')" ] ; then
	echo -e "\\vDidn't find any Cylance files.  Bailing..."
	exit 2
fi


case $1 in
	on)
		mount -u -w /
		mv /Library/LaunchDaemons/com.cylance.agent_service.plist.off /Library/LaunchDaemons/com.cylance.agent_service.plist
		mv /Library/LaunchAgents/com.cylancePROTECT.plist.off /Library/LaunchAgents/com.cylancePROTECT.plist
		mount -u -r /
		;;

	off)
		mount -u -w /
		mv /Library/LaunchDaemons/com.cylance.agent_service.plist /Library/LaunchDaemons/com.cylance.agent_service.plist.off
		mv /Library/LaunchAgents/com.cylancePROTECT.plist /Library/LaunchAgents/com.cylancePROTECT.plist.off
		mount -u -r /
		;;

	*)	DumpHelp;;
esac

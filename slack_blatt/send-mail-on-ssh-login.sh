#!/bin/sh
if [ "$PAM_TYPE" != "open_session" ] ; then
	exit 0
else
	{
	echo "User: $PAM_USER"
	echo "Remote Host: $PAM_RHOST"
	echo "Service: $PAM_SERVICE"
	echo "TTY: $PAM_TTY"
	echo "Date: `date`"
	echo "Server: `uname -a`"
	}
	 | mail -s "$PAM_SERVICE login on `hostname -s` for account $PAM_USER" root
fi
exit 0

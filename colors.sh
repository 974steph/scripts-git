#!/usr/bin/env bash

#http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
SO=$(tput smso)
N=$(tput sgr0)
BOLD=$(tput bold)

for B in $(seq 1 7) ; do
	for F in $(seq 1 7) ; do
		echo -e "${BOLD}\\t$(tput setab $B)$(tput setaf $F) Background: $B || Foreground: $F ${N}"
	done

	echo
done

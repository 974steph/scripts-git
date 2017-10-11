#!/usr/bin/env bash

#http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html
SO=$(tput smso)
N=$(tput sgr0)
BOLD=$(tput bold)

for F in $(seq 1 7) ; do
	for B in $(seq 1 7) ; do
		echo "${BOLD}${SO} $(tput setaf $F) $(tput setab $B)$F $B IJDHKDHKDHKHKJHDGKH ${N}"
	done
done

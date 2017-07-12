#!/usr/bin/env bash

#curl -s http://us.battle.net/wow/en/status | grep -i -B6 Dawnbringer | grep data-raw | awk '{print $3}' | sed -s "s/.*\"\(.*\)\".*/\1/"

curl -sL http://us.battle.net/wow/en/status | grep Dawnbringer | sed "s/.*SortTable-col.*Dawnbringer/Dawnbringer /g;s/United States.*/USA/;s/<[^>]\+>/ /g"

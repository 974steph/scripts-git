#!/bin/sh

curl -s http://us.battle.net/wow/en/status | grep -i -B6 Dawnbringer | grep data-raw | awk '{print $3}' | sed -s "s/.*\"\(.*\)\".*/\1/"

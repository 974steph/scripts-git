#!/usr/bin/env bash

for JAR in $(curl -sL https://hub.spigotmc.org/jenkins/job/Spigot-Essentials/  | grep \.jar | sed 's/jar"/jar\n/g;s/href="lastSuccessfulBuild/\n/g' | grep ^/artifact.*jar$) ; do curl -sL --head https://hub.spigotmc.org/jenkins/job/Spigot-Essentials/19/$JAR ; echo "---------" ; done

#!/usr/bin/env bash

# https://github.com/s3tools/s3cmd

IVTANK="$HOME/MAC/IV_Updates"

PROJECTS="crs vcs"
#PROJECTS="crs"

function doSync() {
	echo -e "\\viv-${PROJ}-bin-stg\\n---------------------------"
	$HOME/Sources/s3cmd/s3cmd --stats -v -r -c ${IVTANK}/s3cfg --rexclude='/*Build2015*/' --rexclude='/*Ops*/' --rexclude='/*AMS*/' sync --no-check-md5 s3://iv-${PROJ}-bin-stg/ ${IVTANK}/iv-${PROJ}-bin-stg/
#	$HOME/Sources/s3cmd/s3cmd --stats -v -r -c ${IVTANK}/s3cfg --rexclude="/*\/Build2015*/" sync s3://iv-${PROJ}-bin-stg/ ${IVTANK}/iv-${PROJ}-bin-stg/
}

#IV_Updates
#s3cmd -c s3cfg --no-check-md5 sync  s3://iv-crs-bin-stg/ ./iv-crs-bin-stg
#s3cmd -c s3cfg --no-check-md5 sync  s3://iv-vcs-bin-stg/ ./iv-vcs-bin-stg

#echo -e "\\viv-crs-bin-stg\\n---------------------------"
#$HOME/Sources/s3cmd/s3cmd --stats -v -r -c ${IVTANK}/s3cfg sync s3://iv-crs-bin-stg/ ${IVTANK}/iv-crs-bin-stg/

#echo -e "\\viv-vcs-bin-stg\\n---------------------------"
#$HOME/Sources/s3cmd/s3cmd --stats -v -r -c ${IVTANK}/s3cfg sync s3://iv-vcs-bin-stg/ ${IVTANK}/iv-vcs-bin-stg/

for PROJ in ${PROJECTS} ; do

	doSync ${PROJ}

done

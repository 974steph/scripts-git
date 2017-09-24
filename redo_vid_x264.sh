#!/usr/bin/env bash

#DEBUG="yes"

trap ctrl_c INT

AUDIO_BITRATE_TARGET=256
PRESET_V="fast"
PRESET_A="medium"
WIDTH_MAX="1080"


if [ ! $# -eq 2 ] ; then
	echo -e "\\vGive me a file and a size.\\v"
	echo -e "$(basename $0) [FILE] [size|auto]\\v"
	exit
else
	INFILE="$1"

	if [ ! -f "${INFILE}" ] ; then
		echo "\"${INFILE}\" doesn't exist.  Bailing..."
		exit 1
	fi


	JUSTNAME="$(echo ${INFILE} | sed 's/\.[a-zA-Z]\+$//')"
	OUTFILE_V="${JUSTNAME}_pass2.mp4"
	OUTFILE_A="${JUSTNAME}.aac"
	OUTFILE_FINAL="${JUSTNAME}.mp4"

	if [ ${DEBUG} ] ; then

		V=v
		TIME=time

		echo "INFILE: $INFILE"
		echo "JUSTNAME: $JUSTNAME"
		echo "OUTFILE_V: $OUTFILE_V"
		echo "OUTFILE_A: $OUTFILE_A"
		echo "OUTFILE_FINAL: $OUTFILE_FINAL"
		echo -e "\\v---------\\v"
	fi
fi

eval $(midentify "${INFILE}" | egrep "ID_VIDEO_WIDTH|ID_VIDEO_HEIGHT|ID_LENGTH")

case $2 in
	auto)
#		WANT_SIZE=$(du -m "${INFILE}" | awk '{print $1}')
		WANT_SIZE=$(du -m "${INFILE}" | awk '{print $1}')
		WIDTH_MAX=${ID_VIDEO_WIDTH}
		;;
	*)
		WANT_SIZE=$2
		;;
esac


[ -f ffmpeg2pass-0.log ] && rm -f${V} ffmpeg2pass-0.log
[ -f ffmpeg2pass-0.log.mbtree ] && rm -f${V} ffmpeg2pass-0.log.mbtree



if [ ${DEBUG} ] ; then
	echo "ID_VIDEO_WIDTH: $ID_VIDEO_WIDTH"
	echo "ID_VIDEO_HEIGHT: $ID_VIDEO_HEIGHT"
	echo "ID_LENGTH: $ID_LENGTH"
fi


if [ "${ID_VIDEO_WIDTH}" -gt ${WIDTH_MAX} ] ; then
	[ ${DEBUG} ] && echo "Resizing to ${WIDTH_MAX}"
	VIDEO_WIDTH_FINAL=${WIDTH_MAX}
else
	[ ${DEBUG} ] && echo "Keeping current width"
	VIDEO_WIDTH_FINAL="${ID_VIDEO_WIDTH}"
fi
[ ${DEBUG} ] && echo "VIDEO_WIDTH_FINAL: ${VIDEO_WIDTH_FINAL}"

WIDTH_CHANGE=$(echo "${WIDTH_MAX} / ${ID_VIDEO_WIDTH}" | bc -l)
[ ${DEBUG} ] && echo "WIDTH_CHANGE: ${WIDTH_CHANGE}"

VIDEO_HEIGHT_FINAL=$(echo "((${ID_VIDEO_HEIGHT} * ${WIDTH_CHANGE}) / 2) * 2" | bc)
[ ${DEBUG} ] && echo "VIDEO_HEIGHT_FINAL: ${VIDEO_HEIGHT_FINAL}"


[ ${DEBUG} ] && echo -e "\\v---------\\v"


function ctrl_c() {
	exit 2
}


function doaudio() {

	echo -e "Writing audio file \"${OUTFILE_A}\""

	[ ${DEBUG} ] && echo "ffmpeg -v 3 -stats -y -i \"${INFILE}\" -vn -c:a libfdk_aac -vbr 5 \"${OUTFILE_A}\""
	ffmpeg -v 3 -stats -y -i "${INFILE}" -vn -c:a libfdk_aac -vbr 5 -threads 0  "${OUTFILE_A}"
	TRAP=$?

	[ ${DEBUG} ] && echo "DOAUDIO: ${TRAP}"

	unset TRAP
}

function dovideo1() {

	echo -e "Encode video - pass 1"

	[ ${DEBUG} ] && echo "ffmpeg -v 3 -stats -y -i \"${INFILE}\" -c:v libx264 -b:v ${BITRATE_FINAL}k -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 1 -threads 0 -f mp4 /dev/null"
	ffmpeg -v 3 -stats -y -i "${INFILE}" -c:v libx264 -b:v ${BITRATE_FINAL}k -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 1 -threads 0 -f mp4 /dev/null
	TRAP=$?

	[ ${DEBUG} ] && echo "DOVIDEO1: ${TRAP}"

	unset TRAP
}

function dovideo2() {

	echo -e "Writing video file \"${OUTFILE_V}\""

	[ ${DEBUG} ] && echo "ffmpeg -v 3 -stats -y -i \"${INFILE}\" -c:v libx264 -b:v ${BITRATE_FINAL}k -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 2 -threads 0 -f mp4 \"${OUTFILE_V}\""
	ffmpeg -v 3 -stats -y -i "${INFILE}" -c:v libx264 -b:v ${BITRATE_FINAL}k -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 2 -threads 0 -f mp4 "${OUTFILE_V}"
	TRAP=$?

	[ ${DEBUG} ] && echo "DOVIDEO1: ${TRAP}"

	unset TRAP
}

function combine() {

	echo -e "Writing final file \"${OUTFILE_FINAL}\""

	[ ${DEBUG} ] && echo "ffmpeg -v 3 -stats -y -i \"${OUTFILE_V}\" -i \"${OUTFILE_A}\" -c:v copy -map 0:v:0 -map 1:a:0 -c:a copy \"${OUTFILE_FINAL}\""
	ffmpeg -v 3 -stats -y -i "${OUTFILE_V}" -i "${OUTFILE_A}" -c:v copy -map 0:v:0 -map 1:a:0 -c:a copy "${OUTFILE_FINAL}"
	TRAP=$?

	[ ${DEBUG} ] && echo "COMBINE: ${TRAP}"

	unset TRAP
}



echo

${TIME} doaudio

echo -e "\\v---------\\v"

#AUDIO_SIZE=$(du -k "${OUTFILE_A}" | awk '{print $1}')
AUDIO_SIZE=$(du -m "${OUTFILE_A}" | awk '{print $1}')
[ ${DEBUG} ] && echo "AUDIO_SIZE: $AUDIO_SIZE"

#BITRATE_VIDEO=$(echo "((${WANT_SIZE} * 8192) - ${AUDIO_SIZE}) / ${ID_LENGTH}" | bc)
BITRATE_VIDEO=$(echo "((${WANT_SIZE} * 8192) - (${AUDIO_SIZE} * 8192)) / ${ID_LENGTH}" | bc)
#BITRATE_VIDEO=$(echo "((${WANT_SIZE} * 1024) - ${AUDIO_SIZE}) / ${ID_LENGTH}" | bc)
[ ${DEBUG} ] && echo "BITRATE_VIDEO: $BITRATE_VIDEO"

#BITRATE_FINAL=$(( ${BITRATE_VIDEO} - ${AUDIO_BITRATE_TARGET}))
BITRATE_FINAL=${BITRATE_VIDEO}
[ ${DEBUG} ] && echo "BITRATE_FINAL: ${BITRATE_FINAL}"

${TIME} dovideo1

echo -e "\\v---------\\v"

${TIME} dovideo2

echo -e "\\v---------\\v"

${TIME} combine

echo -e "\\v---------\\v"

echo "Original: $(du -m "${INFILE}" | sed 's/\t/M - /')"

echo "Temp Video: $(du -m "${OUTFILE_V}" | sed 's/\t/M - /')"

echo "Temp Audio: $(du -m "${OUTFILE_A}" | sed 's/\t/M - /')"

echo "Final File: $(du -m "${OUTFILE_FINAL}" | sed 's/\t/M - /')"

#!/usr/bin/env bash

#DEBUG="yes"

trap ctrl_c INT

###########################
# VARS
PRESET_V="fast"
PRESET_A="fast"
VBR=5
WIDTH_MAX="1080"

DIR_TEMP="TempFiles"
DIR_FINAL="Final"
###########################

###########################
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

	eval $(midentify "${INFILE}" | egrep "ID_VIDEO_WIDTH|ID_VIDEO_HEIGHT|ID_LENGTH")

	JUSTNAME="$(echo ${INFILE} | sed 's/\.[a-zA-Z]\+$//')"
	OUTFILE_V="${DIR_TEMP}/${JUSTNAME}_pass2.mp4"
	OUTFILE_A="${DIR_TEMP}/${JUSTNAME}.aac"
	OUTFILE_FINAL="${DIR_FINAL}/${JUSTNAME}.mp4"

	if [ ${DEBUG} ] ; then

		V=v

		echo "ID_VIDEO_WIDTH: $ID_VIDEO_WIDTH"
		echo "ID_VIDEO_HEIGHT: $ID_VIDEO_HEIGHT"
		echo "ID_LENGTH: $ID_LENGTH"
		echo "---------"
		echo "INFILE: $INFILE"
		echo "JUSTNAME: $JUSTNAME"
		echo "OUTFILE_V: $OUTFILE_V"
		echo "OUTFILE_A: $OUTFILE_A"
		echo "OUTFILE_FINAL: $OUTFILE_FINAL"
		echo -e "\\v---------\\v"
	fi
fi

case $2 in
	auto)
#		WANT_SIZE=$(du -m "${INFILE}" | awk '{print $1}')
		WANT_SIZE=$(du -m "${INFILE}" | awk '{print $1}')
		WIDTH_MAX=${ID_VIDEO_WIDTH}
		;;
	*)
		WANT_SIZE=$2
		VBR=3
		;;
esac
###########################


if [ "${ID_VIDEO_WIDTH}" -gt ${WIDTH_MAX} ] ; then
	VIDEO_WIDTH_FINAL=${WIDTH_MAX}
	echo -e "\\vResizing to ${VIDEO_WIDTH_FINAL}"
else
	VIDEO_WIDTH_FINAL="${ID_VIDEO_WIDTH}"
	[ ${DEBUG} ] && echo "Keeping current width of ${VIDEO_WIDTH_FINAL}"
fi

WIDTH_CHANGE=$(echo "${WIDTH_MAX} / ${ID_VIDEO_WIDTH}" | bc -l)
[ ${DEBUG} ] && echo "WIDTH_CHANGE: ${WIDTH_CHANGE}"

VIDEO_HEIGHT_FINAL=$(echo "((${ID_VIDEO_HEIGHT} * ${WIDTH_CHANGE}) / 2) * 2" | bc)
[ ${DEBUG} ] && echo "VIDEO_HEIGHT_FINAL: ${VIDEO_HEIGHT_FINAL}"

[ ${DEBUG} ] && echo -e "\\v---------\\v"


###########################
# TRAP CTRL+C
function ctrl_c() {
	exit 2
}
###########################


###########################
# ERROR
function errorcode() {

	case $2 in
		0) 	echo -e "\\v$1 exited $2.  Continuing...\\v"
			unset TRAP;;
		*)	echo -e "\\v$1 exited $2.  Bailing...\\v"
			exit $2
	esac
}
###########################


###########################
# DO AUDIO
function doaudio() {

	echo -e "Writing audio file \"${OUTFILE_A}\""

	[ ${DEBUG} ] && echo "ffmpeg -v 3 -stats -y -i \"${INFILE}\" -vn -c:a libfdk_aac -vbr ${VBR} \"${OUTFILE_A}\""
	ffmpeg -v 3 -stats -y -i "${INFILE}" -vn -c:a libfdk_aac -vbr ${VBR} -threads 0 "${OUTFILE_A}"
	TRAP=$?

	[ ${DEBUG} ] && errorcode doaudio $TRAP
}
###########################


###########################
# DO VIDEO 1
function dovideo1() {

	echo -e "\\vGetting pass 1 stats from \"${INFILE}\""

	[ ${DEBUG} ] && echo "ffmpeg -v 3 -stats -y -i \"${INFILE}\" -c:v libx264 -b:v ${BITRATE_VIDEO}k -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 1 -passlogfile \"${DIR_TEMP}/ffmpeg2pass\" -threads 0 -f mp4 /dev/null"
	ffmpeg -v 3 -stats -y -i "${INFILE}" -c:v libx264 -b:v ${BITRATE_VIDEO}k -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 1 -passlogfile "${DIR_TEMP}/ffmpeg2pass" -threads 0 -f mp4 /dev/null
	TRAP=$?

	[ ${DEBUG} ] && errorcode dovideo1 $TRAP
}
###########################


###########################
# DO VIDEO 2
function dovideo2() {

	echo -e "\\vWriting video file \"${OUTFILE_V}\""

	[ ${DEBUG} ] && echo "ffmpeg -v 3 -stats -y -i \"${INFILE}\" -c:v libx264 -b:v ${BITRATE_VIDEO}k -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 2 -passlogfile \"${DIR_TEMP}/ffmpeg2pass\" -threads 0 -f mp4 \"${OUTFILE_V}\""
	ffmpeg -v 3 -stats -y -i "${INFILE}" -c:v libx264 -b:v ${BITRATE_VIDEO}k -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 2 -passlogfile "${DIR_TEMP}/ffmpeg2pass" -threads 0 -f mp4 "${OUTFILE_V}"
	TRAP=$?

	[ ${DEBUG} ] && errorcode dovideo2 $TRAP
}
###########################


###########################
# COMBINE PARTS
function combine() {

	echo -e "\\vWriting final file \"${OUTFILE_FINAL}\""

	[ ! -d "${DIR_FINAL}" ] && mkdir -p "${DIR_FINAL}"

	[ ${DEBUG} ] && echo "ffmpeg -v 3 -stats -y -i \"${OUTFILE_V}\" -i \"${OUTFILE_A}\" -c:v copy -map 0:v:0 -map 1:a:0 -c:a copy \"${OUTFILE_FINAL}\""
	ffmpeg -v 3 -stats -y -i "${OUTFILE_V}" -i "${OUTFILE_A}" -c:v copy -map 0:v:0 -map 1:a:0 -c:a copy "${OUTFILE_FINAL}"
	TRAP=$?

	[ ${DEBUG} ] && errorcode combine $TRAP
}
###########################


[ ! -d "${DIR_TEMP}" ] && mkdir -p "${DIR_TEMP}"
[ -f "${DIR_TEMP}/ffmpeg2pass-0.log" ] && rm -f${V} "${DIR_TEMP}/ffmpeg2pass-0.log"
[ -f "${DIR_TEMP}/ffmpeg2pass-0.log.mbtree" ] && rm -f${V} "${DIR_TEMP}/ffmpeg2pass-0.log.mbtree"

echo

doaudio

[ ${DEBUG} ] && echo -e "\\v---------\\v"

AUDIO_SIZE=$(du -m "${OUTFILE_A}" | awk '{print $1}')
[ ${DEBUG} ] && echo "AUDIO_SIZE: $AUDIO_SIZE"

#BITRATE_VIDEO=$(echo "((${WANT_SIZE} * 8192) - (${AUDIO_SIZE} * 8192)) / ${ID_LENGTH}" | bc)
BITRATE_VIDEO=$(echo "((${WANT_SIZE} - ${AUDIO_SIZE}) * 8192) / ${ID_LENGTH}" | bc)
[ ${DEBUG} ] && echo "BITRATE_VIDEO: $BITRATE_VIDEO"

dovideo1

[ ${DEBUG} ] && echo -e "\\v---------\\v"

dovideo2

[ ${DEBUG} ] && echo -e "\\v---------\\v"

combine

[ ${DEBUG} ] && echo -e "\\v---------\\v"


echo "Original: $(du -m "${INFILE}" | sed 's/\t/M - /')"
echo "Temp Video: $(du -m "${OUTFILE_V}" | sed 's/\t/M - /')"
echo "Temp Audio: $(du -m "${OUTFILE_A}" | sed 's/\t/M - /')"
echo "Final File: $(du -m "${OUTFILE_FINAL}" | sed 's/\t/M - /')"

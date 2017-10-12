#!/usr/bin/env bash

DEBUG="yes"

trap ctrl_c INT

###########################
# VARS
#PRESET_V="slow"
PRESET_V="fast"
PRESET_A="fast"
#VBR=5
VBR=3
WIDTH_MAX="1080"

THREADS=0
#THREADS=15

#ENCODER_V="libopenh264"
#ENCODER_V="libx264"
ENCODER_V="h264_nvenc"

#ENCODER_A="aac"
ENCODER_A="libfdk_aac"

DIR_TEMP="TempFiles"
DIR_FINAL="Final"

B=$(tput bold)
R=$(tput setaf 1)
LB=$(tput setaf 6)
REV=$(tput rev)
N=$(tput sgr0)
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

#	eval $(midentify "${INFILE}" | egrep "ID_VIDEO_WIDTH|ID_VIDEO_HEIGHT|ID_LENGTH")
#	eval $(mplayer -vo null -ao null -frames 0 -identify "${INFILE}" | egrep "ID_VIDEO_WIDTH|ID_VIDEO_HEIGHT|ID_LENGTH" 2>/dev/null)

	eval $(ffprobe -v 0 -show_streams -select_streams a "${INFILE}" | egrep "channels|sample_rate" | sed 's/channels/ID_AUDIO_NCH/;s/sample_rate/ID_AUDIO_RATE/')
	eval $(ffprobe -v 0 -show_streams -select_streams v "${INFILE}" | egrep -i "^width|^height|TAG:DURATION" | sed 's/width/ID_VIDEO_WIDTH/;s/height/ID_VIDEO_HEIGHT/;s/TAG:\(.*\)\..*/\1/')

	DURH=$(echo ${DURATION} | awk -F: '{print $1}')
	DURM=$(echo ${DURATION} | awk -F: '{print $2}')
	DURS=$(echo ${DURATION} | awk -F: '{print $3}')

	ID_LENGTH=$(( ((${DURH} * 60) * 60 ) + ( ${DURM} * 60 ) + ${DURS} ))

	JUSTNAME="$(echo ${INFILE} | sed 's/\.[a-zA-Z]\+$//')"
	OUTFILE_V="${DIR_TEMP}/${JUSTNAME}_temp.mp4"
	OUTFILE_A="${DIR_TEMP}/${JUSTNAME}.aac"
	OUTFILE_FINAL="${DIR_FINAL}/${JUSTNAME}.mkv"

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
		ACTION=auto
		WANT_SIZE=$(du -k "${INFILE}" | awk '{print $1}')
#		WANT_SIZE=$(du -m "${INFILE}" | awk '{print $1}')
		WIDTH_MAX=${ID_VIDEO_WIDTH}
		;;
	*)
		ACTION=redo
		WANT_SIZE=$(( $2 * 1024 ))
#		WANT_SIZE=$2
#		VBR=3
		VBR=2
		;;
esac
[ ${DEBUG} ] && echo "WANT_SIZE: ${WANT_SIZE}"
###########################


if [ "${ID_VIDEO_WIDTH}" -gt ${WIDTH_MAX} ] ; then
	VIDEO_WIDTH_FINAL=${WIDTH_MAX}
	echo -e "\\vResizing to ${VIDEO_WIDTH_FINAL}"
else
	VIDEO_WIDTH_FINAL="${ID_VIDEO_WIDTH}"
	[ ${DEBUG} ] && echo "Keeping current width of ${VIDEO_WIDTH_FINAL}"
fi

[ ${DEBUG} ] && echo "VIDEO_WIDTH_FINAL: ${VIDEO_WIDTH_FINAL}"

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
		0) 	[ ${DEBUG} ] && echo -e "\\v${REV} $1 exited $2.  Continuing... ${N}\\v"
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

	[ ${DEBUG} ] && echo "ffmpeg -v 3 -stats -y -i \"${INFILE}\" -vn -c:a ${ENCODER_A} -vbr ${VBR} \"${OUTFILE_A}\""
#	ffmpeg -v 3 -stats -y -i "${INFILE}" -vn -c:a ${ENCODER_A} -vbr ${VBR} -crf 0 -threads ${THREADS} "${OUTFILE_A}"
	ffmpeg -v 3 -stats -y -i "${INFILE}" -vn -c:a ${ENCODER_A} -vbr ${VBR} -threads ${THREADS} "${OUTFILE_A}"
	TRAP=$?

	errorcode doaudio $TRAP
}
###########################


###########################
# DO VIDEO 1
function dovideo1() {

	echo -e "\\vGetting pass 1 stats from \"${INFILE}\""

#	[ ${DEBUG} ] && echo "ffmpeg -v 3 -stats -y -i \"${INFILE}\" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO}k -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 1 -passlogfile \"${DIR_TEMP}/ffmpeg2pass\" -threads ${THREADS} -f mp4 /dev/null"
#	ffmpeg -v 3 -stats -y -i "${INFILE}" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO}k -preset:v ${PRESET_V} -crf 0 -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 1 -passlogfile "${DIR_TEMP}/ffmpeg2pass" -threads ${THREADS} -f mp4 /dev/null
#	[ ${DEBUG} ] &&  echo "ffmpeg -v 3 -stats -y -i \"${INFILE}\" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO}k -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 1 -passlogfile \"${DIR_TEMP}/ffmpeg2pass\" -threads ${THREADS} -f mp4 /dev/null"
#	ffmpeg -v 3 -stats -y -i "${INFILE}" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO}k -preset:v ${PRESET_V} -cq 0 -rc vbr -zerolatency 1 -crf 0 -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 1 -passlogfile "${DIR_TEMP}/ffmpeg2pass" -threads ${THREADS} -f mp4 /dev/null
#	[ ${DEBUG} ] &&  echo "ffmpeg -v 3 -stats -y -i \"${INFILE}\" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO} -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -cq 0 -an -pass 1 -passlogfile \"${DIR_TEMP}/ffmpeg2pass\" -threads ${THREADS} -f mp4 /dev/null"
#	ffmpeg -v 3 -stats -y -i "${INFILE}" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO} -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -cq 0 -an -pass 1 -passlogfile "${DIR_TEMP}/ffmpeg2pass" -threads ${THREADS} -f mp4 /dev/null

	[ ${DEBUG} ] &&  echo "ffmpeg -y -i \"${INFILE}\" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO} -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 1 -passlogfile \"${DIR_TEMP}/ffmpeg2pass\" -threads ${THREADS} -f mp4 /dev/null"
	ffmpeg -v 3 -stats -y -i "${INFILE}" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO} -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -cbr 1 -an -pass 1 -passlogfile "${DIR_TEMP}/ffmpeg2pass" -threads ${THREADS} -f mp4 /dev/null

	TRAP=$?

	errorcode dovideo1 $TRAP
}
###########################


###########################
# DO VIDEO 2
function dovideo2() {

	echo -e "\\vWriting video file \"${OUTFILE_V}\""

#	[ ${DEBUG} ] && echo "ffmpeg -v 3 -stats -y -i \"${INFILE}\" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO}k -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 2 -passlogfile \"${DIR_TEMP}/ffmpeg2pass\" -threads ${THREADS} -f mp4 \"${OUTFILE_V}\""
#	ffmpeg -v 3 -stats -y -i "${INFILE}" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO}k -preset:v ${PRESET_V} -crf 0 -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 2 -passlogfile "${DIR_TEMP}/ffmpeg2pass" -threads ${THREADS} -f mp4 "${OUTFILE_V}"
#	[ ${DEBUG} ] && echo "ffmpeg -v 3 -stats -y -i \"${INFILE}\" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO}k -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 2 -passlogfile \"${DIR_TEMP}/ffmpeg2pass\" -threads ${THREADS} -f mp4 \"${OUTFILE_V}\""
#	ffmpeg -v 3 -stats -y -i "${INFILE}" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO}k -preset:v ${PRESET_V} -cq 0 -rc vbr -zerolatency 1 -crf 0 -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 2 -passlogfile "${DIR_TEMP}/ffmpeg2pass" -threads ${THREADS} -f mp4 "${OUTFILE_V}"
#	[ ${DEBUG} ] && echo "ffmpeg -v 3 -stats -y -i \"${INFILE}\" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO} -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -cq 0 -an -pass 2 -passlogfile \"${DIR_TEMP}/ffmpeg2pass\" -threads ${THREADS} -f mp4 \"${OUTFILE_V}\""
#	ffmpeg -v 3 -stats -y -i "${INFILE}" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO} -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -cq 0 -an -pass 2 -passlogfile "${DIR_TEMP}/ffmpeg2pass" -threads ${THREADS} -f mp4 "${OUTFILE_V}"

	[ ${DEBUG} ] && echo "ffmpeg -y -i \"${INFILE}\" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO} -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -an -pass 2 -passlogfile \"${DIR_TEMP}/ffmpeg2pass\" -threads ${THREADS} -f mp4 \"${OUTFILE_V}\""
	ffmpeg -v 3 -stats -y -i "${INFILE}" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO} -preset:v ${PRESET_V} -s ${VIDEO_WIDTH_FINAL}:${VIDEO_HEIGHT_FINAL} -cbr 1 -an -pass 2 -passlogfile "${DIR_TEMP}/ffmpeg2pass" -threads ${THREADS} -f mp4 "${OUTFILE_V}"

	TRAP=$?

	errorcode dovideo2 $TRAP
}
###########################


###########################
# ALL IN ONE
function allinone() {

	echo -e "\\vAll in one: \"${OUTFILE_FINAL}\""

	[ ! -d "${DIR_FINAL}" ] && mkdir -p "${DIR_FINAL}"

	[ ${DEBUG} ] && echo "ffmpeg -y -i \"${INFILE}\" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO} -cbr 1 -c:a ${ENCODER_A} -vbr ${VBR} -threads ${THREADS} -an -f mp4 \"${OUTFILE_V}\""
	ffmpeg -v 3 -stats -y -i "${INFILE}" -c:v ${ENCODER_V} -b:v ${BITRATE_VIDEO} -cbr 1 -c:a ${ENCODER_A} -vbr ${VBR} -threads ${THREADS} "${OUTFILE_FINAL}"

	TRAP=$?

	errorcode allinone $TRAP
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

	errorcode combine $TRAP
}
###########################


###########################
# STATS
function dumpstats() {
	[ -f "${INFILE}" ] && echo "Original: $(du -m "${INFILE}" | sed 's/\t/M - /')"
	[ -f "${OUTFILE_V}" ] && echo "Temp Video: $(du -m "${OUTFILE_V}" | sed 's/\t/M - /')"
	[ -f "${OUTFILE_A}" ] && echo "Temp Audio: $(du -m "${OUTFILE_A}" | sed 's/\t/M - /')"
	[ -f "${OUTFILE_FINAL}" ] && echo "Final File: $(du -m "${OUTFILE_FINAL}" | sed 's/\t/M - /')"
}
###########################


#echo

if [ ${ACTION} == "auto" ] ; then
#	BITRATE_VIDEO=$(echo "(${WANT_SIZE} * 8192) / ${ID_LENGTH}" | bc)
	BITRATE_VIDEO=$(echo "${WANT_SIZE} / ${ID_LENGTH}" | bc)
	[ ${DEBUG} ] && echo "BITRATE_VIDEO: $BITRATE_VIDEO"

	time allinone

	[ ${DEBUG} ] && echo -e "\\v---------\\v"

else

	[ ! -d "${DIR_TEMP}" ] && mkdir -p "${DIR_TEMP}"
	[ -f "${DIR_TEMP}/ffmpeg2pass-0.log" ] && rm -f${V} "${DIR_TEMP}/ffmpeg2pass-0.log"
	[ -f "${DIR_TEMP}/ffmpeg2pass-0.log.mbtree" ] && rm -f${V} "${DIR_TEMP}/ffmpeg2pass-0.log.mbtree"

	if [ ! -f "${OUTFILE_A}" ] ; then
		time doaudio
		[ ${DEBUG} ] && echo -e "\\v---------\\v"
	fi

#	AUDIO_SIZE=$(du -m "${OUTFILE_A}" | awk '{print $1}')
	AUDIO_SIZE=$(du -k "${OUTFILE_A}" | awk '{print $1}')
	[ ${DEBUG} ] && echo "AUDIO_SIZE: $AUDIO_SIZE"

#	BITRATE_VIDEO=$(echo "((${WANT_SIZE} * 8192) - (${AUDIO_SIZE} * 8192)) / ${ID_LENGTH}" | bc)
#	BITRATE_VIDEO=$(echo "((${WANT_SIZE} - ${AUDIO_SIZE}) / ${ID_LENGTH}) * 1024" | bc)
	BITRATE_VIDEO=$(echo "(${WANT_SIZE} - ${AUDIO_SIZE}) / ${ID_LENGTH}" | bc)
#	BITRATE_VIDEO=$(echo "((${WANT_SIZE} - ${AUDIO_SIZE}) * 8192) / ${ID_LENGTH}" | bc)
	[ ${DEBUG} ] && echo "BITRATE_VIDEO: $BITRATE_VIDEO"

	time dovideo1
	[ ${DEBUG} ] && echo -e "\\v---------\\v"

	time dovideo2
	[ ${DEBUG} ] && echo -e "\\v---------\\v"

	time combine
	[ ${DEBUG} ] && echo -e "\\v---------\\v"
fi

dumpstats

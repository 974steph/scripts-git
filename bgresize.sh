#!/bin/sh


# ORDER="VBOX1 VBOX0 VBOX2"
# 
# for DISPLAY in ${ORDER} ; do 
# # 	echo ${DISPLAY}
# 	xrandr | grep ${DISPLAY} | sed -e "s/primary //" | awk '{print $3}'
# done
# 
# exit

ORIG="$1"
JUST_NAME=$(echo ${ORIG} | sed -e 's/\(.*\)\..*/\1/g')
NEW="${JUST_NAME}_NEW.jpg"

#WHERE="$HOME/.kde/share/wallpapers"
#WHERE="$HOME/Pictures"
WHERE="./"
#WHERE="$(dirname "${ORIG}")"


X_LEFT="1920"
Y_LEFT="1080"

X_MIDDLE="2560"
Y_MIDDLE="1600"

X_RIGHT="1920"
Y_RIGHT="1080"

RESIZE_WIDTH=$(( ${X_LEFT} + ${X_MIDDLE} + ${X_RIGHT} ))
#echo "RESIZE_WIDTH: $RESIZE_WIDTH"

SMALL_HEIGHT=1080
LARGE_HEIGHT=1600

RESIZE_HEIGHT=1080

convert -resize ${RESIZE_WIDTH}x${RESIZE_HEIGHT}! -quality 100 "${ORIG}" "${NEW}"
echo "Scaled $(basename "${ORIG}") to ${RESIZE_WIDTH}x${RESIZE_HEIGHT}"

# convert -crop 1680x1050+0+0 -quality 100 "${NEW}" "00_Left.jpg"
# convert -crop 1366x768+1680+282 -quality 100 "${NEW}" "00_Middle.jpg"
# convert -crop 1680x1050+3046+0 -quality 100 "${NEW}" "00_Right.jpg"


#HOME@MattsMBP-2 ~ $ system_profiler SPDisplaysDataType | grep Resolution
#          Resolution: 1920 x 1080 @ 60Hz (1080p)
#          Resolution: 2560 x 1600 Retina
#          Resolution: 1920 x 1080 @ 60Hz (1080p)




CROP_LEFT="${X_LEFT}x${RESIZE_HEIGHT}+0+0"
#convert -crop 1920x1080+0+0 -quality 100 "${NEW}" "${WHERE}/00_Left.jpg"
convert -crop ${CROP_LEFT} -quality 100 "${NEW}" "${WHERE}/00_Left.jpg"
echo "Wrote 00_Left.jpg: ${CROP_LEFT}"


CROP_MIDDLE="${X_MIDDLE}x${RESIZE_HEIGHT}+${X_LEFT}+0"
#convert -crop 2560x1050+1920+30 -quality 100 "${NEW}" "${WHERE}/00_Middle.jpg"
convert -crop ${CROP_MIDDLE} -quality 100 "${NEW}" "${WHERE}/00_Middle.jpg"
echo "Wrote 00_Middle.jpg: ${CROP_MIDDLE}"


CROP_RIGHT="${X_RIGHT}x${RESIZE_HEIGHT}+$(( ${X_LEFT} + ${X_MIDDLE} ))+0"
#convert -crop 1920x1080+4480+0 -quality 100 "${NEW}" "${WHERE}/00_Right.jpg"
convert -crop ${CROP_RIGHT} -quality 100 "${NEW}" "${WHERE}/00_Right.jpg"
echo "Wrote 00_Right.jpg: ${CROP_RIGHT}"

exit

rm -f "${NEW}"

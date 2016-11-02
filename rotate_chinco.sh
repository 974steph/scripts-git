#!/bin/sh

# DEBUG="yes"

TANK="$HOME/Pictures/Cams/CurrentChinco"

cd ${TANK}

PICS=$(find ${TANK} -maxdepth 1 -type f -iname '*jpg' -printf %f\\n | sort)
PIC_COUNT=$(echo "${PICS}" | wc -l)
LINK=$(find ${TANK} -type l -printf %f\\n)
DUMMY="now.jpg"

if [ ${DEBUG} ] ; then
	echo "PICS: ${PICS}"
	echo "PIC_COUNT: ${PIC_COUNT}"
	echo "LINK: ${LINK}"
fi

X=1

#echo "$(identify -ping -verbose River.jpg | grep kurtosis: | awk '{print $2}' | tr \\n " " | sed "s/ / + /g" | sed 's/ + $//')" | bc -l

for FILE in ${PICS} ; do

	if [ ${FILE} == $(readlink ${DUMMY}) ] ; then

		[ ${DEBUG} ] && echo "$X: \"${FILE}\" <== \"$(readlink ${DUMMY})\""
		FOUND=TRUE
		X=$(( ${X} + 1 ))
	else
		if [ ${FOUND} ] ; then

			for K in $(identify -ping -verbose ${FILE} | grep kurtosis: | awk '{print $2}') ; do
				if [[ ! $K =~ ^- ]]; then
					EXPRE+=" + $K"
				else
					EXPRE+=" $K"
				fi

				[ ${DEBUG} ] && echo "EXPRE: ${EXPRE}"

			done

			EXPRE=$(echo $EXPRE | sed "s/^+ //")

			[ ${DEBUG} ] && echo "EXPRE: ${EXPRE}"

			KURTOSIS=$(echo "${EXPRE}" | bc)

			[ ! "${KURTOSIS}" ] && KURTOSIS=0

			[ ${DEBUG} ] && echo "KURTOSIS: $KURTOSIS"

			BC=$(echo "${KURTOSIS} > 50" | bc)

			[ ${DEBUG} ] && echo "BC: $BC"

			if [ ${BC} -eq 1 ] ; then
				X=$(( ${X} + 1 ))
			else
				ln -sf ${FILE} ${DUMMY}
				[ ${DEBUG} ] && echo "${X}: \"${FILE}\" ==> \"${DUMMY}\""
				exit
			fi
		else
			[ ${DEBUG} ] && echo "${X}: \"${FILE}\""
			X=$(( ${X} + 1 ))
		fi
	fi
done


# IT ONLY GETS HERE IF SOMETHING
# WASN'T LINKED ABOVE
[ ${DEBUG} ] && echo "LOOPED"
ln -sf $(echo "${PICS}" | head -n 1) ${DUMMY}
[ ${DEBUG} ] && echo "1: \"${FILE}\" ==> \"${DUMMY}\""

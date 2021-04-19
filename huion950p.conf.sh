#!/bin/bash

RATIO=1
NUMERO_DE_MONITORES=$(xrandr --listactivemonitors | grep Monitors | cut -d " " -f 2)

select monitor in $(xrandr --listactivemonitors | grep -v Monitors | cut -d " " -f 6)
do
if [ 1 -le "$REPLY" ] && [ "$REPLY" -le ${NUMERO_DE_MONITORES} ];
then
echo "Configurando Huion 950p para el monitor ${monitor}"
break;
else
echo "Escoja entre las opciones: 1-${NUMERO_DE_MONITORES}"
fi
done


STYLUS_ID=$(xsetwacom --list | grep STYLUS | cut -f 2 | cut -d " " -f 2)
PAD_ID=$(xsetwacom --list | grep "Pad pad" | cut -f 2 | cut -d " " -f 2)

# Reseteamos el area de trabajo de la tableta
xsetwacom --set ${STYLUS_ID} ResetArea

SCREEN_WIDTH=$(xrandr --listactivemonitors | grep "\b${monitor}\b" | cut -d " " -f 4 | cut -d "/" -f 1)
SCREEN_HEIGHT=$(xrandr --listactivemonitors | grep "\b${monitor}\b" | cut -d " " -f 4 | cut -d "/" -f 2 | cut -d "x" -f 2)
TABLET_WIDTH=$(xsetwacom --get ${STYLUS_ID} Area | cut -d " " -f 3)
TABLET_HEIGHT=$(xsetwacom --get ${STYLUS_ID} Area | cut -d " " -f 4)

echo "SCREEN_WIDTH: ${SCREEN_WIDTH}"
echo "SCREEN_HEIGHT: ${SCREEN_HEIGHT}"
echo "TABLET_WIDTH: ${TABLET_WIDTH}"
echo "TABLET_HEIGHT: ${TABLET_HEIGHT}"

#NEW_TABLET_HEIGHT=$(echo "scale=0; ${TABLET_HEIGHT}*(${TABLET_WIDTH}/${SCREEN_WIDTH})" | bc)
#NEW_TABLET_HEIGHT=$(echo "scale=0; ${TABLET_HEIGHT}*${TABLET_WIDTH}/${SCREEN_WIDTH}" | bc)
NEW_TABLET_HEIGHT=$(echo "scale=0; ${SCREEN_HEIGHT}*${TABLET_WIDTH}/${SCREEN_WIDTH}*${RATIO}" | bc)
NEW_TABLET_WIDTH=$(echo "scale=0; ${TABLET_WIDTH}*${RATIO}" | bc)

OFFSET_X=$(echo "scale=0;(${TABLET_WIDTH}-${NEW_TABLET_WIDTH})/2" | bc)
OFFSET_Y=$(echo "scale=0; (${TABLET_HEIGHT}-${NEW_TABLET_HEIGHT})/2" | bc)

X2=$(echo "scale=0; $NEW_TABLET_WIDTH+$OFFSET_X" | bc)
Y2=$(echo "scale=0; $NEW_TABLET_HEIGHT+$OFFSET_Y" | bc)


echo "NEW_TABLET_HEIGHT: ${NEW_TABLET_HEIGHT}"
echo "NEW_TABLET_WIDTH: ${NEW_TABLET_WIDTH}"
echo "OFFSET_X: ${OFFSET_X}"
echo "OFFSET_Y: ${OFFSET_Y}"



xsetwacom --set ${PAD_ID} RawSample 4
#xsetwacom --set ${STYLUS_ID} Area 0 0 ${TABLET_WIDTH} ${TABLET_HEIGHT}
xsetwacom --set $STYLUS_ID Area $OFFSET_X $OFFSET_Y $X2 $Y2
xsetwacom --set ${STYLUS_ID} MapToOutput ${monitor}

echo -e "Tablet ID:$STYLUS_ID\nArea coords: ($OFFSET_X,$OFFSET_Y) ($X2,$Y2)\nArea sides: $NEW_TABLET_WIDTH x $NEW_TABLET_HEIGHT"

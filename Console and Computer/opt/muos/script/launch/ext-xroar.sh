#!/bin/sh

. /opt/muos/script/var/func.sh

NAME=$1
CORE=$2
FILE=${3%/}

(
	LOG_INFO "$0" 0 "Content Launch" "DETAIL"
	LOG_INFO "$0" 0 "NAME" "$NAME"
	LOG_INFO "$0" 0 "CORE" "$CORE"
	LOG_INFO "$0" 0 "FILE" "$FILE"
) &


GPTOKEYB="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/gptokeyb/gptokeyb2"
XROAR_DIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/xroar"
# Get the games's basename without the path
GAME_BASENAME=$(basename "${FILE%.*}")
# Construct the gptkfile by appending .gptk
GPTK_FILE="${GAME_BASENAME}.gptk"
export LD_LIBRARY_PATH="$XROAR_DIR/libs:$LD_LIBRARY_PATH"

HOME="$(GET_VAR "device" "board/home")"
export HOME

SETUP_SDL_ENVIRONMENT

export SDL_GAMECONTROLLERCONFIG_FILE="/usr/lib/gamecontrollerdb.txt"

SET_VAR "system" "foreground_process" "xroar"

#set emulator machine model, default to coco2 if selecting xroar profile
MACHINE="-default-machine coco2bus"
if [[ $CORE != "xroar" && $CORE != "ext-xroar" ]]; then
	MACHINE="-default-machine $CORE"
fi

/opt/muos/script/mux/track.sh "$NAME" "$CORE" "$FILE" start

	if [ -f "$XROAR_DIR/gptk/${GPTK_FILE}" ]; then
		$GPTOKEYB "xroar" -c "$XROAR_DIR/gptk/${GPTK_FILE}" &
	else
		$GPTOKEYB "xroar" -c "$XROAR_DIR/gptk/xroar.gptk" &
	fi
	$XROAR_DIR/xroar -c "$XROAR_DIR/xroar.conf" $MACHINE "$FILE"

killall -q gptokeyb2

/opt/muos/script/mux/track.sh "$NAME" "$CORE" "$FILE" stop

unset SDL_HQ_SCALER SDL_ROTATION SDL_BLITTER_DISABLED

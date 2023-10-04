#!/usr/bin/bash
# Script for showing mic status queried using `pacmd` and `pactl` commands in `i3blocks`.
#
# Does not work as of 04.10.2023
#
set -e
set -u

echo "long: "
echo "short:"
echo "#A8FF00"
exit 0

function usage {
	echo "ERROR: Wrong number of arguments!"
	echo "Usage: $(basename $0) <volume|mute> <up/down|on/off/toggle>"
	exit 1
}

if ! hash pacmd 2>/dev/null || ! hash pactl 2>/dev/null; then
	echo "ERROR: 'pacmd' and/or 'pactl' not found!"
	exit 1
fi
if (( $# != 2 )); then
	usage
fi

# Current active sink is marked with `*`, e.g:
#  * index: 6
#    name: <bluez_sink.04_52_C7_31_D5_52.a2dp_sink>
# For things like BT headsets, the index will increase with each new connection
ACTIVE_SINK=$(pacmd list-sinks | sed -n 's/^\s*\*\s*index:\s*\([0-9]*\)$/\1/p')

function mute {
	case "$1" in
		"on")  pactl set-sink-mute $ACTIVE_SINK 1 ;;
		"off") pactl set-sink-mute $ACTIVE_SINK 0 ;;
		*)     pactl set-sink-mute $ACTIVE_SINK toggle ;;
	esac
}

function volume {
	local mute=$(pactl get-sink-mute $ACTIVE_SINK | grep -Eo 'yes|no')
	if [[ "$mute" == "yes" ]]; then
		pactl set-sink-mute $ACTIVE_SINK 0
	else
		pactl set-sink-volume $ACTIVE_SINK "${1}"
	fi
}

case "$1" in
	"volume") volume $2;;
	"mute")   mute $2;;
	*) usage;;
esac

exit 0


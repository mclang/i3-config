#!/usr/bin/bash
# Simple script for showing the status of Feral's gamemode in i3block bar.
# https://github.com/FeralInteractive/gamemode
#
# NOTE: Symbols need Awesome terminal fonts.
#
set -e
set -u

if ! hash gamemoded 2>/dev/null; then
	echo "ERROR: 'gamemoded' not found!"
	echo "error"
	echo "#FF0000"
	exit 1
fi

OUTPUT=$(gamemoded -s)
if [[ "$OUTPUT" =~ "is active" ]]; then
	echo ""
	echo "on"
	echo "#A8FF00"
fi
exit 0

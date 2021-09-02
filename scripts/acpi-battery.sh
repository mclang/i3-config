#!/usr/bin/bash
# Script for collecting battery information for `i3blocks` using output from `acpi` command.
# Made by combining things from:
# `battery.sh` (Licensed under the terms of the GNU GPL v3, or any later version)
#   - Copyright 2014 Pierre Mavro <deimos@deimos.fr>
#   - Copyright 2014 Vivien Didelot <vivien@didelot.org>
# `battery-pinebook-pro.sh`
#   - 05012020 geri123@gmx.net Gerhard S.
#
# NOTE: Battery symbols need Awesome terminal fonts.
#
# set -e
# set -u NOTE: cannot be used due to `$BLOCK_INSTANCE` usually NOT being defined
#
if ! hash acpi 2>/dev/null; then
	echo "ERROR: 'acpi' not found!"
	echo "error"
	echo "#FF0000"
	exit 1
fi
if [[ -z "$BLOCK_INSTANCE" ]]; then
	BATNUM="0"
else
	BATNUM="$BLOCK_INSTANCE"
fi

# Valid outputs from `acpi -b` call are:
#declare -a ACPI_OUTPUT_TEST=(
#	"Battery 0: Not charging, 58%"
#	"Battery 0: Discharging, 58%, 10:02:17 remaining"
#	"Battery 0: Charging, 29%, 01:00:49 until charged"
#	"Battery 0: Charging, 58%, charging at zero rate - will never fully charge."
#)
IFS=', ' read -ra ACPI_OUTPUT <<< $(acpi -b | grep "Battery $BATNUM")
# for LINE in "${ACPI_OUTPUT_TEST[@]}"; do
for LINE in "${ACPI_OUTPUT[@]}"; do
	if [[ "$LINE" =~ ((Not )?(Dis)?[cC]harging) ]]; then
		STATUS="${BASH_REMATCH[1]}"
	fi
	if [[ "$LINE" =~ ([0-9]{2})% ]]; then
		PERCENT="${BASH_REMATCH[1]}"
	fi
	if [[ "$LINE" =~ ([0-9]{2}:[0-9]{2}):[0-9]{2} ]]; then
		REMAINING="${BASH_REMATCH[1]}"
	fi
done

if (( 0 <= PERCENT && PERCENT <= 20 )); then
	echo -n ""
	COLOR="#FF0000"
elif (( 20 <= PERCENT && PERCENT <= 40 )); then
	echo -n ""
	COLOR="#FFAE00"
elif (( 40 <= PERCENT && PERCENT <= 60 )); then
	echo -n ""
	COLOR="#FFF600"
elif (( 60 <= PERCENT && PERCENT <= 80 )); then
	echo -n ""
	COLOR="#A8FF00"
elif (( 80 <= PERCENT && PERCENT <= 100 )); then
	echo -n ""
	# COLOR="#00F600"
else
	echo -n ""
	COLOR="#F02C2C"
fi
echo -n " ${PERCENT}%"

case "$STATUS" in
	"Charging")    echo -n ' ';;
	"Discharging") echo -n ' ';;
	*)             echo -n ' ';;
esac

if [[ -n "$REMAINING" ]]; then
	echo -n " ($REMAINING)"
fi

echo -e "\n${PERCENT}%"
echo "$COLOR"

exit 0


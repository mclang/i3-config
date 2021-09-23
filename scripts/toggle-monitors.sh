#!/usr/bin/bash
# Script for toggling external monitor on/off using `xrandr`.
# Example commands from using ARandR:
# ```
# $ xrandr --output eDP --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-A-0 --off --output DP-1-0 --off --output DP-1-1 --off
# $ xrandr --output eDP --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-A-0 --mode 2560x1080 --pos 1920x0 --rotate normal --output DP-1-0 --off --output DP-1-1 --off
# ```
#
# NOTES:
# - Using `--right-of `simplifies things b/c no need to know resolution for `--pos` calculation.
# - Using `--auto` is not possible if `--rate` is used b/c the latter works only with `--mode`.
set -e
set -u

if ! hash xrandr 2>/dev/null; then
	echo "ERROR: 'xrandr' not found!"
	exit 1
fi

# Returns the largest number from `xrandr` input like '59.95 + 143.91'.
function parse_refresh_rate {
	local maxrt=0
	# echo "rates: '$1'" >&2
	IFS=' +*' read -ra rates <<< "$1"
	for rate in ${rates[@]}; do
		local rt="${rate%.*}"       # '144.00' -> '144'
		((rt > maxrt)) && maxrt=$rt
	done
	unset rates
	echo "$maxrt"
}

# Array for `xrandr` output parameters
XRANDR_PARAMETERS=()

# https://mywiki.wooledge.org/BashFAQ/001
# https://www.gnu.org/software/sed/manual/html_node/Text-search-across-multiple-lines.html

# Example results from `xrandr`
# eDP:primary:1920x1080:144.00*+  60.00
# HDMI-A-0::2560x1440:59.95 + 143.91
while read -r LINE; do
	IFS=':' read -ra PARTS <<< "$LINE"
	OUTPUT="${PARTS[0]}"
	if [[ "${PARTS[1]}" == "primary" ]]; then
		POSITION="--primary"
	else
		POSITION="--right-of $PREVIOUS"
	fi
	RESOLUTION="${PARTS[2]}"
	REFRESHRATE=$(parse_refresh_rate "${PARTS[3]}")
	XRANDR_PARAMETERS+=("--output $OUTPUT --mode $RESOLUTION --rate $REFRESHRATE $POSITION")
	PREVIOUS="$OUTPUT"
done < <(xrandr -q | sed -En '{N; s/(\w+)\s+connected\s+(primary)?[^\n]+\n\s+([0-9]{4}x[0-9]{4})\s+([0-9 .+*]+)/\1:\2:\3:\4/p ; D}')


# Using `--auto` sets disconnected outputs off
while read -r OUTPUT; do
	XRANDR_PARAMETERS+=("--output $OUTPUT --auto")
done < <(xrandr -q | sed -En 's/(\w+)\s+disconnected.+/\1/p')


xrandr ${XRANDR_PARAMETERS[@]}
exit 0


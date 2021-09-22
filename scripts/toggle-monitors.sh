#!/usr/bin/bash
# Script for toggling external monitor on/off using `xrandr`.
# Example commands from using ARandR:
# ```
# $ xrandr --output eDP --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-A-0 --off --output DP-1-0 --off --output DP-1-1 --off
# $ xrandr --output eDP --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-A-0 --mode 2560x1080 --pos 1920x0 --rotate normal --output DP-1-0 --off --output DP-1-1 --off
# ```
#
# NOTES:
# - Using `--auto` and `--right-of `simplifies things, no need to know resolution for `--pos` calculation.
# - Leaving `sed` into multiline format b/c resolution or refresh rates might be needed later!
#
set -e
set -u

if ! hash xrandr 2>/dev/null; then
	echo "ERROR: 'xrandr' not found!"
	exit 1
fi

# https://www.gnu.org/software/sed/manual/html_node/Text-search-across-multiple-lines.html
CONNECTED=$(xrandr -q | sed -En '{N; s/(\w+)\s+connected\s+(primary)?[^\n]+\n\s+([0-9]{4}x[0-9]{4}).+/\1:\3:\2/p ; D}')
DISCONNECTED=$(xrandr -q | sed -En 's/(\w+)\s+disconnected.+/\1/p')
XRANDR_PARAMETERS=()

for LINE in ${CONNECTED[@]}; do
	IFS=':' read -ra PARTS <<< "$LINE"
	PORT="${PARTS[0]}"
	# RESO="${PARTS[1]}"
	if (( ${#PARTS[@]} == 3 )); then
		POSITION="--primary"
	else
		POSITION="--right-of $PREVIOUS"
	fi
	XRANDR_PARAMETERS+=("--output $PORT --auto $POSITION")
	PREVIOUS="$PORT"
done

# Do NOT use `"${DISCONNECTED[@]}"` b/c it preservers also linebreaks between ports
for LINE in ${DISCONNECTED[@]}; do
	XRANDR_PARAMETERS+=("--output $LINE --auto")
done

xrandr ${XRANDR_PARAMETERS[@]}

exit 0


#!/usr/bin/bash
# Script for applying saved layout and starting some programs in specified workspace
# https://i3wm.org/docs/layout-saving.html
#
set -e
set -u

# Parse the workspace name used in the i3 config.
# NOTE: Line might end in comment, so don't use '$' anchor!
WSNAME=$(sed -n 's/^set\s*$ws4\s*"\(.*\)"/\1/p' ~/.config/i3/config)

# Apply layout:
i3-msg "workspace $WSNAME; append_layout ~/.config/i3/layouts/workspace-4.json"

# Start apps in the background:
nohup /var/lib/flatpak/exports/bin/com.slack.Slack > /dev/null 2>&1 &
nohup /usr/bin/discord                             > /dev/null 2>&1 &
nohup /usr/bin/signal-desktop                      > /dev/null 2>&1 &


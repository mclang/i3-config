#!/bin/sh
# Utility to toggle through keyboard backlight modes via `asusctl -k`.
# Needed untill `-n`/`-p` functionality is implemented in `asusctl`.
# Original version by sarumont (sarumont#7313):
# https://discord.com/channels/725125934759411753/740598035725418576/862727467982127166
#
current=$(asusctl -k | cut -d\  -f5)
case $1 in
	up)
		case $current in
		48) next=low ;;
		49) next=med ;;
		50) next=high ;;
		51) next=off ;;
		esac
	;;
	down)
		case $current in
		48) next=high ;;
		49) next=off ;;
		50) next=low ;;
		51) next=med ;;
		esac
	;;
	*)
		echo "Unknown command: '$1'"
		echo "Usage: $0 <up|down>"
		exit 1
esac
asusctl -k $next


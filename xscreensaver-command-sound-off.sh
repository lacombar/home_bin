#!/bin/sh

xscreensaver-command -watch |
	while read cmd timestamp; do
		case "${cmd}" in
		"BLANK")
			amixer set Master mute
			;;
		"UNBLANK")
			amixer set Master unmute
			;;
		esac
	done

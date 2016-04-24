#!/bin/sh

case "$1" in
	"start")
		killall -CONT chrome
		killall -CONT firefox
		;;
	stop)
		killall -STOP chrome
		killall -STOP firefox
		;;
esac

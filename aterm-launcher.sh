#!/bin/sh

. "$(dirname "$0")/_common.sh"

load_host_configuration

PATH=/home/al/bin:/bin:/sbin:/usr/bin:/usr/sbin

ATERM=$(which aterm)

ATERM_OPTS=""

if [ -n "${ATERM_GEOM:=}" ]; then
	ATERM_OPTS="${ATERM_OPTS} -geometry ${ATERM_GEOM}"
fi

ATERM_OPTS="${ATERM_OPTS} +sb"
ATERM_OPTS="${ATERM_OPTS} -bl"
ATERM_OPTS="${ATERM_OPTS} -fade 80"
#ATERM_OPTS="${ATERM_OPTS} -ib 7 -sh 95"
ATERM_OPTS="${ATERM_OPTS} -color0 Black"
ATERM_OPTS="${ATERM_OPTS} -color1 Sienna3"
ATERM_OPTS="${ATERM_OPTS} -color2 Sienna4"
ATERM_OPTS="${ATERM_OPTS} -color3 ForestGreen"
ATERM_OPTS="${ATERM_OPTS} -color4 RoyalBlue3"
ATERM_OPTS="${ATERM_OPTS} -color5 RoyalBlue4"
ATERM_OPTS="${ATERM_OPTS} -color6 Wheat"
ATERM_OPTS="${ATERM_OPTS} -color7 WhiteSmoke"
ATERM_OPTS="${ATERM_OPTS} -fg black"
ATERM_OPTS="${ATERM_OPTS} -bg whitesmoke"
ATERM_OPTS="${ATERM_OPTS} -fn -misc-fixed-medium-r-semicondensed--13-120-75-75-c-60-iso8859-15"

export THEME_STYLE=bright
${ATERM} ${ATERM_OPTS}


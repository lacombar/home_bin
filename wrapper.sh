#!/bin/sh

MACHINE=$(uname -m)
SYSTEM=$(uname -s)

# relative and absolute calling mode
if [ -z "${0##/*}" -o -z "${0##\./*}" ]; then
	b="${0}"
else # direct call
	b="$(which $0)"
fi

basename=$(basename "${b}")
dirname=$(dirname "${b}")

exec_cmd="${dirname}/${SYSTEM}/${MACHINE}/${basename}"

${exec_cmd} $*

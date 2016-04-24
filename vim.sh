#!/bin/sh

is_linux_kernel_root()
{
	test -d arch		\
	    -a -d arch/um	\
	    -a -d crypto	\
	    -a -d kernel	\
	    -a -d init		\
	    -a -f Makefile	\
	    -a -f MAINTAINERS	\
	    -a -f REPORTING-BUGS
}

set -e

is_freebsd_sys_root()
{
	test -d i386		\
	    -a -d amd64		\
	    -a -d netatalk	\
	    -a -d netgraph	\
	    -a -d netinet	\
	    -a -d netinet6	\
	    -a -d opencrypto	\
	    -a -f sys/param.h	\
	    -a -f Makefile
}

VIM=$(which vim)

#TAG="v$(head -3 Makefile | tr -d '\n' | sed 's/VERSION = //; s/[A-Z]*LEVEL = /./g')";
if is_linux_kernel_root; then
	eval $(head -3 Makefile | tr '\n' ';' | tr -d ' ');
	CSCOPE_DIR="${HOME}/.cscope/cache/linux"
	CSCOPE_TMPL='${CSCOPE_DIR}/v${VERSION}.${PATCHLEVEL}${SUBLEVEL}.cscope';
	SUBLEVEL=${SUBLEVEL:=0}
	if [ "${VERSION}" = "3" ]; then
		SUBLEVEL=
		eval CSCOPE_CACHE=${CSCOPE_TMPL}
		while test "$PATCHLEVEL" != "0" -a ! -f "${CSCOPE_CACHE}"; do
			PATCHLEVEL=$(($PATCHLEVEL-1));
			eval CSCOPE_CACHE=${CSCOPE_TMPL}
		done
	else
		eval CSCOPE_CACHE=${CSCOPE_TMPL}
		while test "$SUBLEVEL" != "0" -a ! -f "${CSCOPE_CACHE}"; do
			SUBLEVEL=".$(($SUBLEVEL-1))"
			eval CSCOPE_CACHE=${CSCOPE_TMPL}
		done
	fi
	test -f "${CSCOPE_CACHE}" && export CSCOPE_DB="${CSCOPE_CACHE}"
elif is_freebsd_sys_root; then
	__FreeBSD_version=$(
	{
		echo '#include "sys/param.h"';
		echo '__FreeBSD_version';
	} |
	cc -I. -E - |
	tail -1)

	CSCOPE_DIR="${HOME}/.cscope/cache/"

	CSCOPE_DIST="freebsd"
	[ -e netinet/tcp_scps.c ] && CSCOPE_DIST="xiplink"

	if [ -d "${CSCOPE_DIR}/${CSCOPE_DIST}" ]; then
		for _cscope_db in "${CSCOPE_DIR}/${CSCOPE_DIST}"/sys.*.cscope; do
			_cscope_db_vers=${_cscope_db##*/sys.}
			_cscope_db_vers=${_cscope_db_vers%%.cscope}
			if [ ${__FreeBSD_version} -ge ${_cscope_db_vers} ]; then
				CSCOPE_DB=${_cscope_db}
			fi
		done
		export CSCOPE_DB
	fi
fi

for _arg in $@; do
	[ "${_arg}" = "--" ] && break
	[ -n "${_arg%%-*}" ] && break
	shift
	VIM_OPTS="${VIM_OPTS} ${_arg}"
done

[ $# -gt 1 -a -z "${VIM_OPTS}" \
  -o $# -gt 1 -a -n "${VIM_OPTS%%* -p*}" ] && VIM_OPTS="${VIM_OPTS}"

${VIM} ${VIM_OPTS} "$@"


#!/bin/sh
#

set -e

die()
{
	echo "$@"
	exit
}

__git()
{
	git --git-dir="${PWD}/$_repo" "$@"
}

_git()
{
	__git "$@"
}

list_remote()
{
	local remotes

	remotes=$(__git remote show)
	if [ -z "${remotes}" ]; then
		return
	fi

	echo origin
	if [ "${remotes}" != "origin" ]; then
		echo ${remotes# *} | \
		    sed 's/ *\<origin\> *//' | \
		    tr ' ' '\n'
	fi
}

for_each_repo()
{
	local _cb="$1"
	local _name
	local _repo

	for _repo in ${ALL_REPOSITORIES}; do
		${_cb} ${_repo}
	done
}

update()
{

	echo
	echo Updating ${_repo}...

	list_remote | \
	    while read _remote; do
		_git remote prune ${_remote} || true
		_git --bare fetch ${_remote} || true
	done
}

repack()
{
	echo
	echo Repacking ${_repo}...

	_git repack -adl
	_git gc --aggressive
}

list()
{
	echo ${_repo}
}

#
#
#
resolve_dependencies()
{
	local _alternate
	local _alternates="$1/objects/info/alternates"

	[ -e "${_alternates}" ] || \
	    return 0

	cat "${_alternates}" | while read _alternate; do
		_alternate=${_alternate%%/objects}
		_alternate="./${_alternate##${PWD}/}"
		resolve_dependencies ${_alternate}
		echo -n "${_alternate} "
	done
}

check_duplicate_repository()
{
	local _dep=$1
	local _r

	for _r in ${ALL_REPOSITORIES}; do
		[ "${_dep}" = "${_r}" ] && \
		    return 1
	done

	return 0
}

append_repository()
{
	local _repo=$1

	ALL_REPOSITORIES="${ALL_REPOSITORIES} ${_repo}"
}

resolve_dependencies_and_append_repository()
{
	local _repo="$1"
	local _deps
	local _r

	_deps=$(resolve_dependencies ${_repo})
	for _r in ${_deps} ${_repo}; do
		check_duplicate_repository "${_r}" || \
		    continue;

		append_repository ${_r}
	done
}

load_repositories()
{
	local _name
	local _repos
	local _r

	_name=${_repo_override:=*.git}

	_repos=$(find . -mindepth 1 -maxdepth 1 -name "${_name}" | sort)

	for _r in ${_repos}; do
		resolve_dependencies_and_append_repository ${_r}
	done
}
ALL_REPOSITORIES=

#
#
#

_repos_dir="/data/Repositories"
_repo_override=""

while getopts d:r:p: f; do
        case $f in
	d)
		_repos_dir="${OPTARG}"
		[ -d "${_repos_dir}" ] || \
			die "${_repos_dir}: no such directory"
		;;
        r)
                _repo_override="$OPTARG"
		[ -d "${_repo_override}" ] || \
		    die "${_repo_override}: no such directory"
		;;
	p)
		_repo_override="$OPTARG"
                ;;
        esac
done
shift $(($OPTIND - 1))

cd "${_repos_dir}"

_action=$1

case ${_action} in
"update")
	THIS_ACTION=update
	;;
"repack")
	THIS_ACTION=repack
	;;
"list")
	THIS_ACTION=list
	;;
*)
	die "$0: unknown action"
	;;
esac

load_repositories

for_each_repo ${THIS_ACTION}


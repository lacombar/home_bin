#
#
#

set -eu

warn()
{
	>&2 echo $@
}

die()
{
	warn $@
	exit 1
}

load_host_configuration()
{
	local _host=$(hostname)
	local _config=~/.${_host}.conf

	[ -e "${_config}" ] || \
	    die "No configuration found for ${_host}"

	. "${_config}"
}

#!/bin/bash

# echo "$0 $@ [$$] START" >&2
# set -euE

### version 2018-03-06
# --help Info: библиотека вспомогательных функций для работы в стиле opencarbon7
# --help Usage:
# --help . /opt/crab/crab_utils/bin/crab_sys.sh
# --help source /opt/crab/crab_utils/bin/crab_sys.sh
# --help Example:
# --help #!/bin/bash
# --help set -ue
# --help . /opt/crab/crab_utils/bin/crab_sys.sh
# --help sys::usage "$@"
# --help ### --help Info: Usage: Example:
# --help sys::arg_parse "$@"

if [ "${0##*/}" = "crab_sys.sh" -a "${1:-}" = "--help" ]; then
	grep "# [-]-help" "$0"
	exit 0
fi
set -euE
__ARGV=

# revers argv
for __ARG in ${BASH_ARGV[@]:1}; do
	__ARGV="$__ARG $__ARGV"
done

__BASH_SOURCE=${BASH_SOURCE[1]}

[ "${__SILENT:-}" = "" ] && echo "START ${__BASH_SOURCE} $__ARGV [$$]" >&2

# skip strongbash021_5
trap '__exit $? CMD=${BASH_COMMAND// /%%%%%} $@' ERR
__exit(){
	set +eux
	local status=$1
	local cmd=
	local argv=
	shift
	if [[ "${1}" == "CMD="* ]]; then
		cmd=${1//CMD=/}
		cmd=${cmd//%%%%%/ }
		shift
		argv="$@"
	else
		echo ""
		echo "__exit $status $@"
		cmd="__exit"
		argv=
	fi
	echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
	echo "    ERROR_PROG=$__BASH_SOURCE  $__ARGV"
	echo "    ERROR_STACK=${BASH_SOURCE[@]:1}"
	echo "    ERROR_SOURCE=${BASH_SOURCE[@]:1:1} $argv"
	echo "    ERROR_CMD=\"${cmd}\"\
 ERROR_STATUS=$status LINENO=${BASH_LINENO[@]:0:${#BASH_LINENO[@]}-1}\
 FUNC: ${FUNCNAME[@]:1}"
	echo ""
	# echo grep -n "${cmd}" ${BASH_SOURCE[@]:1:1} -B 5 -A 5 grep "^${BASH_LINENO[@]:0:1}:" -B 5 -A 5
	# grep -n "${cmd}" ${BASH_SOURCE[@]:1:1} -B 5 -A 5 | grep "^${BASH_LINENO[@]:0:1}:" -B 5 -A 5
	grep -n  . "${BASH_SOURCE[@]:1:1}" -B 5 -A 5 | grep "^${BASH_LINENO[@]:0:1}:" -B 5 -A 5 --color
	exit ${status:-0}
}

trap '__trapexit $?' EXIT
__trapexit(){
	set +eux
	if [ $1 = 0 ]; then
		[ "${__SILENT:-}" = "" ] && echo "SUCCESS ${__BASH_SOURCE} $__ARGV [$$]" >&2
	else
		echo "FAILED ${__BASH_SOURCE} $__ARGV [$$]" >&2
	fi
	exit $1
}

sys::usage(){
	[ "${1:---help}" != "--help" ] && return 0
	(
		set +e
		echo
		grep -H '# [-][-]help' ${__BASH_SOURCE} \
			| sed -n 's/^.*[/]\(.*\)[ ]*[ #]*--help[ ]*\(.*\)/\1 \2/p'
		echo
		exit 0
	)
	[ "${1:-}" = "--help" ] && exit 0 || exit 255
}

### --help Example: sys::arg_parse "$@"
### --help Example: sys::arg_parse "vm create name1 --ram=4gb --disksize=10gb --force -t 1 -y
### --help Example: return ARG_0=vm ARG_1=create ARG_2=name1
### --help Example: or return ARGV[0]=vm ARGV[1]=create ARGV[2]=name1 ARGC=3
### --help Example: for var in ${!ARG_@}; do echo $var ${!var}; done
### --help Example: ARG_RAM=4gb ARG_DISKSIZE=10gb ARG_FORCE=TRUE ARG_T=1 ARG_Y=TRUE
sys::arg_parse() {
	ARGC=0
	ARGV[$ARGC]="$0"
	ARG_0="$0"

	local i=
	local _i=
	local _arg_name= _arg_value=
	local params=( "$@" )
	local n=
	for ((n=0; n<${#params[@]}; n++)); do
		i="${params[$n]}"
		case $i in
		--*)
			_i=${i#--}
			if [[ "$_i" == *"="* ]]; then
				_arg_name="${_i%%=*}"
				_arg_name=${_arg_name//-/_}
				_arg_value="${_i#*=}"
				eval export -n '"ARG_${_arg_name^^}"="${_arg_value}"'

			else
				_arg_name="${_i}"
				_arg_name=${_arg_name//-/_}
				eval export -n '"ARG_${_arg_name^^}"=TRUE'
			fi
			;;
		-[^-]*)
			_arg_name="${i:1:1}"
			_arg_value="${i:2}"
			if [[ -n "${_arg_value}" ]]; then
				eval export -n '"ARG_${_arg_name^^}"="${_arg_value}"'
			else
				eval export -n '"ARG_${_arg_name^^}"=TRUE'
			fi
			;;
		*)
			ARGC=$((ARGC+1))
			ARGV[$ARGC]="$i"
			eval export -n '"ARG_$ARGC"="$i"'
			;;
		esac
	done
	return 0
}
# echo "$0 $@ [$$] SUCCESS"
# exit 0

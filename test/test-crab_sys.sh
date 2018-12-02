#!/bin/bash

set -eu
. /opt/crab/crab_utils/bin/crab_sys.sh

[ "${1:-}" = "--help" ] && sys::usage "$@"
### --help Info: тестирование crab_sys.sh
### --help Usage:
### --help Example: test-crab_sys.sh

failed=FALSE

### sys::usage
$0 --help &>/tmp/test-crab_sys.sh.$$
for word in 'Example: test-crab_sys.sh' '^START' '^SUCCESS'; do
	if ! grep -qm1 "$word" /tmp/test-crab_sys.sh.$$; then
		echo "TEST $0 grep $word [ FAILED ]"
		failed=TRUE
	fi
done
rm -f /tmp/test-crab_sys.sh.$$

### sys::arg_parse
sys::arg_parse "arg1" "arg2" "--named1=a1" "--named2=a2" "--forced"
if [ ${ARGV[0]} != "$0" ]\
	|| [ ${ARGV[1]} != "arg1" ]\
	|| [ ${ARGV[2]} != "arg2" ]\
	|| [ ${ARG_NAMED1} != "a1" ]\
	|| [ ${ARG_NAMED2} != "a2" ]\
	|| [ ${ARG_FORCED} != "TRUE" ] ; then
	echo "TEST $0 sys::arg_parse [ FAILED ]"
	failed=TRUE
fi

### __trapexit
### __exit
if [ "${1:-}" = "testexit" ]; then
	myerror
	exit 1
fi

if [ "${1:-}" != "testexit" ]; then
	$0 testexit &>/tmp/test-crab_sys.sh.$$ || true
	if ! grep -qm1 'ERROR_SOURCE' /tmp/test-crab_sys.sh.$$; then
		echo "TEST $0 grep ERROR_SOURCE [ FAILED ]"
		failed=TRUE
	fi
	rm -f /tmp/test-crab_sys.sh.$$
fi

check_funcs=$( cat /opt/crab/crab_utils/bin/crab_sys.sh \
	| grep '^.*()' \
	| sed -n  's/^\(.*\)().*{/\1/p' ) # '

for func in $check_funcs; do
	if ! grep -qm1 "### $func" $0; then
		echo "TEST $0 $func not found in $0"
		failed=TRUE
	fi
done


if [ $failed = TRUE ]; then
	exit 1
fi

exit 0

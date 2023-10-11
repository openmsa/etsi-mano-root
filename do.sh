#!/bin/bash
#
for d in $(find . -maxdepth 1 -type d -name 'etsi*')
do
	echo -e "======================================== \033[32;1;1m$d\033[0m ========================================"
	pushd $d
	$@
	popd
done

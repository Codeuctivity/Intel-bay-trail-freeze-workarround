#!/bin/sh

#title:       c6off+c7on.sh
#description: Disables all C6 and enables all C7 core states for Baytrail CPUs
#author:      Wolfgang Reimer <linuxball (at) gmail.com>
#date:        2016014
#version:     1.0    
#usage:       sudo <path>/c6off+c7on.sh
#notes:       Intended as test script to verify whether erratum VLP52 (see
#             [1]) is the root cause for kernel bug 109051 (see [2]). In order
#             for this to work you must _NOT_ use boot parameter
#             intel_idle.max_cstate=<number>.
#
# [1] http://www.intel.com/content/dam/www/public/us/en/documents/specification-updates/pentium-n3520-j2850-celeron-n2920-n2820-n2815-n2806-j1850-j1750-spec-update.pdf
# [2] https://bugzilla.kernel.org/show_bug.cgi?id=109051

# Disable ($1 == 1) or enable ($1 == 0) core state, if not yet done.
disable() {
	local action
	read disabled <disable
	test "$disabled" = $1 && return
	echo $1 >disable || return
	action=ENABLED; test "$1" = 0 || action=DISABLED
	printf "%-8s state %7s for %s.\n" $action "$name" $cpu  
}

# Iterate through each core state and for Baytrail (BYT) disable all C6
# and enable all C7 states.
cd /sys/devices/system/cpu
for cpu in cpu[0-9]*; do
	for dir in $cpu/cpuidle/state*; do
		cd "$dir"
		read name <name
		case $name in
			C6*) disable 1;;
			C6*-BYT) disable 1;;
			C7*) disable 0;;
			C7*-BYT) disable 0;;
		esac
		cd ../../..
	done
done

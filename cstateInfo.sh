#!/bin/sh

#title:       cstateInfo.sh
#description: Shows all core states + some related info as a formatted table
#author:      Wolfgang Reimer <linuxball (at) gmail.com>
#date:        2016014
#version:     1.0    
#usage:       <path>/cstateInfo.sh
#notes:       The intel_idle.max_cstate boot parameter refers to enumeration
#             done by the linux kernel (number in column State) and not to
#             the Intel notation of core states C0, C1, C2, C3, C6, C7, etc.
#             Latency, Residency, and Time units are microseconds.

ns=State nn=Name nd=Disabled nl=Latency nr=Residency nt=Time nu=Usage
lc=3 ls=${#ns} ln=${#nn} ld=${#nd} ll=${#nl} lr=${#nr} lt=${#nt} lu=${#nu}

# set l<$1> to max of $l<$1> and string length of $<$1>
max () { eval test \${#$1} -gt \$l$1 && eval l$1=\${#$1}; }

get () {
	cd /sys/devices/system/cpu
	for c in cpu[0-9]*; do
		cd $c/cpuidle
		max c
		printf "$1" "$c" "$ns" "$nn" "$nd" "$nl" "$nr" "$nt" "$nu"
		for i in state*; do
			cd $i
			s=${i#state}; max s
			read n <name; max n
			read d <disable; max d
			read l <latency; max l
			read r <residency; max r
			read t <time; max t
			read u <usage; max u
			printf "$1" "" "$s" "$n" "$d" "$l" "$r" "$t" "$u"
			cd ..
		done
		cd ../..
	done
}

get ''		# 1st run with empty output to set string lengths.
max () { :; }	# We don't need max for the 2nd run.
get "%-${lc}s %${ls}s  %-${ln}s  %${ld}s  %${ll}s  %${lr}s  %${lt}s  %${lu}s\n"

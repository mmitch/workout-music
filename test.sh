#!/bin/bash
set -e

DIR=`mktemp -d --tmpdir workout-music-unittest-XXXXXXXX`

# setup colors
if tput sgr0 >/dev/null 2>&1; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    WHITE=$(tput setaf 7)
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    RED=
    GREEN=
    YELLOW=
    WHITE=
    BOLD=
    RESET=
fi

status()
{
    echo "${BOLD}${YELLOW}>> ${@}${RESET}"
}

error_out()
{
    status "${RED}test script was interrupted"
    status "${RED}temporary directory \`$DIR' was not cleaned"
    status "${RED}investigate and delete at your leisure"
    trap '' ERR
    exit 1
}

trap error_out ERR

do_assertion()
{
    local TEXT="$1" STATE="$2"

    if [ "$STATE" = OK ]; then
	printf "${BOLD}${GREEN}%s${WHITE} : %s${RESET}\n" 'OK' "$TEXT"
    else
	printf "${BOLD}${RED}%s${WHITE} : %s : ${RED}%s${RESET}\n" '!!' "$TEXT" "$STATE"
	error_out
    fi

}

assert_dir()
{
    local TESTDIR STATE
    for TESTDIR in "$@"; do
	if [ -d "$TESTDIR" ]; then
	    STATE="OK"
	else
	    if [ -e "$TESTDIR" ]; then
		STATE="file exists, but is no directory"
	    else
		STATE="missing directory"
	    fi
	fi
	do_assertion "checking directory \`…${TESTDIR/$DIR}'" "$STATE"
    done
}

assert_nofile()
{
    local TESTFILE STATE
    for TESTFILE in "$@"; do
	if [ ! -e "$TESTFILE" ]; then
	    STATE='OK'
	else
	    if [ -d "$TESTDIR" ]; then
		STATE='unwanted file exists (directory)'
	    else
		STATE='unwanted file exists'
	    fi
	fi
	do_assertion "checking missing file \`…${TESTFILE/$DIR}'" "$STATE"
    done
}

assert_content()
{
    local TESTFILE="$1" EXPECTED="$2"

    local STATE
    if [ -e "$TESTFILE" ]; then
	ACTUAL="$(cat "$TESTFILE")"
	if [ "$ACTUAL" = "$EXPECTED" ]; then
	    STATE='OK'
	else
	    printf -v STATE "expected content = \`%s', actual content = \`%s'" "$EXPECTED" "$ACTUAL"
	fi
    else
	STATE='missing file'
    fi
    
    do_assertion "checking file content \`…${TESTFILE/$DIR}'" "$STATE"
}

assert_contains()
{
    local TESTFILE="$1" EXPECTED="$2"

    local STATE
    if [ -e "$TESTFILE" ]; then
	if grep -q "$EXPECTED" "$TESTFILE"; then
	    STATE='OK'
	else
	    printf -v STATE "regexp \`%s' not found in file" "$EXPECTED"
	fi
    else
	STATE='missing file'
    fi
    
    do_assertion "checking file content \`…${TESTFILE/$DIR}' for \`$EXPECTED'" "$STATE"
}

#################################################################

status "tempdir is \`$DIR'"
status 'setting up test'
BIN=./workout-music
SYSOUT="$DIR/sysout"
SYSERR="$DIR/syserr"

status 'TEST: check total calculations with default values'
"$BIN" -n >| "$SYSOUT" 2>| "$SYSERR"
assert_content "$SYSERR" ''
assert_contains "$SYSOUT" '00:30:00 end'
assert_contains "$SYSOUT" '00:06:45 total slow time'
assert_contains "$SYSOUT" '00:23:15 total fast time'

status 'TEST: check help text'
"$BIN" -h >| "$SYSOUT" 2>| "$SYSERR"
assert_content "$SYSERR" ''
assert_contains "$SYSOUT" 'usage:'
assert_contains "$SYSOUT" 'workout-music'
assert_contains "$SYSOUT" 'arguments:'
assert_contains "$SYSOUT" 'options:'


status 'TEST: check default output file'
"$BIN" -n >| "$SYSOUT" 2>| "$SYSERR"
assert_content "$SYSERR" ''
assert_contains "$SYSOUT" 'output file: /tmp/workout.mp3'

status 'TEST: check changed output file'
"$BIN" -n -o dir/file >| "$SYSOUT" 2>| "$SYSERR"
assert_content "$SYSERR" ''
assert_contains "$SYSOUT" 'output file: dir/file'


status 'TEST: check default total time'
"$BIN" -n >| "$SYSOUT" 2>| "$SYSERR"
assert_content "$SYSERR" ''
assert_contains "$SYSOUT" '00:30:00 end'

status 'TEST: check changed total time'
"$BIN" -n -t 100 >| "$SYSOUT" 2>| "$SYSERR"
assert_content "$SYSERR" ''
assert_contains "$SYSOUT" '00:01:40 end'


status 'TEST: check default slow time'
"$BIN" -n >| "$SYSOUT" 2>| "$SYSERR"
assert_content "$SYSERR" ''
assert_contains "$SYSOUT" '00:00:55 speedup'

status 'TEST: check changed slow time'
"$BIN" -n -s 180 >| "$SYSOUT" 2>| "$SYSERR"
assert_content "$SYSERR" ''
assert_contains "$SYSOUT" '00:03:00 speedup'


status 'TEST: check default fast time'
"$BIN" -n >| "$SYSOUT" 2>| "$SYSERR"
assert_content "$SYSERR" ''
assert_contains "$SYSOUT" '00:03:30 slowdown'

status 'TEST: check changed fast time'
"$BIN" -n -f 5 >| "$SYSOUT" 2>| "$SYSERR"
assert_content "$SYSERR" ''
assert_contains "$SYSOUT" '00:01:00 slowdown'


status 'TEST: check default speedup sound'
"$BIN" -n >| "$SYSOUT" 2>| "$SYSERR"
assert_content "$SYSERR" ''
assert_contains "$SYSOUT" "speedup sound: $HOME/rampup.wav"

status 'TEST: check changed speedup sound'
"$BIN" -n -F dir/fast >| "$SYSOUT" 2>| "$SYSERR"
assert_content "$SYSERR" ''
assert_contains "$SYSOUT" "speedup sound: dir/fast"



#################################################################

status 'removing temporary directory'
rm -rf "$DIR"

status 'successful exit'
exit 0

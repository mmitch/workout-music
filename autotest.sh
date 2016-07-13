#!/bin/bash
#
# automatically run test when files are changed
# cleans up temporary files when everything is done

cleanup() {
    BASEDIR=${TMPDIR:-/tmp}/workout-music-unittest
    set -- $BASEDIR-*
    if [ "$1" != "$BASEDIR-*" ]; then
	echo
	echo $CYAN cleaning up test directories $RESET
	rm -vr $BASEDIR-*
    fi
}

trap cleanup ERR
trap cleanup SIGTERM
trap cleanup EXIT
trap cleanup RETURN

# setup colors
if tput sgr0 >/dev/null 2>&1; then
    CYAN=$(tput setaf 6)
    RESET=$(tput sgr0)
else
    CYAN=
    RESET=
fi

# TODO: switch to inotify-tools

WATCHED_FILES="workout-music test.sh"
MD5SUMS=""
TIMER=2

while true; do
    CHANGED=no

    MD5=$(md5sum $WATCHED_FILES)
    if [ "$MD5" != "$MD5SUMS" ]; then
	CHANGED=yes
	MD5SUMS="$MD5"
    fi

    if [ $CHANGED = yes ]; then
	clear
	echo -n $CYAN
	date
	echo $RESET
	./test.sh || true
    fi

    sleep $TIMER
done

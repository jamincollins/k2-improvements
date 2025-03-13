#!/bin/sh

set -e

FULLPATH=$(readlink -f ${1})
rm -fr ${FULLPATH}
rm -fr /overlay/upper${FULLPATH}
mount -o remount /

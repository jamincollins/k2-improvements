#!/bin/sh
set -e

CONF=$(awk -F= '/CONF=/ {print $2}' /etc/init.d/moonraker)
LOG=$(awk -F= '/LOG=/ {print $2}' /etc/init.d/moonraker)

/usr/share/moonraker-env/bin/python \
    /usr/share/moonraker/moonraker.py \
    -v \
    -c ${CONF} \
    -l ${LOG}

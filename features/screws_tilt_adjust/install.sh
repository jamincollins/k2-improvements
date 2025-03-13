#!/bin/ash
set -e

SCRIPT_DIR=$(readlink -f $(dirname ${0}))

ln -sf ${SCRIPT_DIR}/screws_tilt_adjust.py \
    ~/klipper/klippy/extras/screws_tilt_adjust.py

test -d ~/printer_data/config/custom || mkdir -p ~/printer_data/config/custom

ln -sf ${SCRIPT_DIR}/screws_tilt_adjust.cfg \
    ~/printer_data/config/custom/screws_tilt_adjust.cfg
python ${SCRIPT_DIR}/../../scripts/ensure_included.py \
    ~/printer_data/config/custom/main.cfg \
    screws_tilt_adjust.cfg

/etc/init.d/klipper restart

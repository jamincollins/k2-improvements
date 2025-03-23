#!/bin/ash

set -e

SCRIPT_DIR="$(readlink -f $(dirname $0))"

test -d ~/printer_data/config || mkdir -p ~/printer_data/config

# add the main.cfg to printer.cfg
python ${SCRIPT_DIR}/../../../scripts/ensure_included.py \
    ~/printer_data/config/printer.cfg custom/main.cfg
# add the gcode_macro.cfg
ln -sf ${SCRIPT_DIR}/start_print.cfg \
    ~/printer_data/config/gcode_macro.cfg
python ${SCRIPT_DIR}/../../../scripts/ensure_included.py \
    ~/printer_data/config/custom/main.cfg gcode_macro.cfg

/etc/init.d/klipper restart

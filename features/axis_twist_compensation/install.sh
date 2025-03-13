#!/bin/ash
set -e

SCRIPT_DIR="$(readlink -f $(dirname $0))"

cd ${SCRIPT_DIR}

echo "Installing axis_twist_compensation"
rm -f /usr/share/klipper/klippy/extras/probe.py*

# symlink these so the user automatlically gets updates
ln -sf ${SCRIPT_DIR}/probe.py /usr/share/klipper/klippy/extras
ln -sf ${SCRIPT_DIR}/axis_twist_compensation.py /usr/share/klipper/klippy/extras

# install the configuration
ln -sf ${SCRIPT_DIR}/axis_twist_compensation.cfg \
    ~/printer_data/config/custom/axis_twist_compensation.cfg
python ${SCRIPT_DIR}/../../scripts/ensure_included.py \
    ~/printer_data/config/custom/main.cfg axis_twist_compensation.cfg

echo "Installed axis_twist_compensation"

/etc/init.d/klipper restart

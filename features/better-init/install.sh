#!/bin/ash
set -e

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# these are replacing the default init scripts and MUST be copied
cp -f ${SCRIPT_DIR}/klipper_mcu.init /etc/init.d/klipper_mcu
/etc/init.d/klipper_mcu restart
cp -f ${SCRIPT_DIR}/klipper.init /etc/init.d/klipper
/etc/init.d/klipper restart
cp -f ${SCRIPT_DIR}/webrtc.init /etc/init.d/webrtc
/etc/init.d/webrtc restart

# need to link wrapper scripts in place
# linking so they get updates
test -d /mnt/UDISK/bin || mkdir -p /mnt/UDISK/bin

ln -sf ${SCRIPT_DIR}/bin/sudo /mnt/UDISK/bin/
ln -sf ${SCRIPT_DIR}/bin/supervisorctl /mnt/UDISK/bin/
ln -sf ${SCRIPT_DIR}/bin/systemctl /mnt/UDISK/bin/

# update the path
echo 'export PATH=/mnt/UDISK/bin:$PATH' > /etc/profile.d/better-init.sh

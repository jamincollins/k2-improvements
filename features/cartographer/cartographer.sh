#!/bin/ash
set -e

ACTION=${1}
PATCH=~/k2-improvements/features/cartographer/homing.patch

usage() {
    echo ""
    echo "${0} ACTION"
    echo ""
    echo "ACTION:"
    echo "  enable -- enables the cartographer probe, disabling the prtouch"
    echo "  disable -- disables the cartogrpher probe, enabling the prtouch"
    echo "  restart -- restarts the cartographer serial bridge"
    echo ""
}

case ${ACTION} in
    enable)
        ln -sf ~/cartographer-klipper/scanner.py ~/klipper/klippy/extras
        ln -sf ~/cartographer-klipper/cartographer.py ~/klipper/klippy/extras
        ln -sf ~/cartographer-klipper/idm.py ~/klipper/klippy/extras
        cd ~/klipper/klippy/extras
        patch < "${PATCH}"
        rm -f homing.pyc
        rm -f bed_mesh.py*
        ln -sf ~/k2-improvements/features/cartographer/bed_mesh.py .
        sed -E \
            -i \
            -e 's/(.*prtouch.*)/#\1/' \
            -e 's/#(.*carto.*)/\1/' \
            ~/printer_data/config/custom/main.cfg
        /etc/init.d/klipper restart
        ;;
    disable)
        rm -f ~/klipper/klippy/extras/scanner.py*
        rm -f ~/klipper/klippy/extras/cartographer.py*
        rm -f ~/klipper/klippy/extras/idm.py*
        sed -E \
            -i \
            -e 's/#(.*prtouch.*)/\1/' \
            -e 's/(.*carto.*)/#\1/' \
            ~/printer_data/config/custom/main.cfg
        ~/k2-improvements/scripts/restore-path.sh ~/klipper/klippy/extras/homing.py
        ~/k2-improvements/scripts/restore-path.sh ~/klipper/klippy/extras/homing.pyc
        ~/k2-improvements/scripts/restore-path.sh ~/klipper/klippy/extras/bed_mesh.py
        ~/k2-improvements/scripts/restore-path.sh ~/klipper/klippy/extras/bed_mesh.pyc
        /etc/init.d/klipper restart
        ;;
    restart)
        /etc/init.d/cartographer restart
        ;;
    *)
        usage
        ;;
esac

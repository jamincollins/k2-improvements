#!/bin/bash
set -e

WORKDIR=$(mktemp -d)

trap "sudo rm -rf $WORKDIR" EXIT

prereqs() {
    # install the needed packages
    case $(lsb_release -si) in
        "Ubuntu" | "Debian")
            sudo apt-get update
            sudo apt-get install -y \
                virtualenv python3-dev python3-pip libffi-dev \
                build-essential git dfu-util
            ;;
        "Arch")
            sudo pacman -Sy --noconfirm \
                python-virtualenv python-pip libffi git dfu-util \
                base-devel
            ;;
        *)
            echo "W: your distribution $(lsb_release -si) is not yet supported!"
            exit 1
            ;;
    esac
}

gather_repositories() {
    git clone "https://github.com/Klipper3d/klipper" $WORKDIR/klipper
    git clone "https://github.com/Cartographer3D/cartographer-klipper.git" $WORKDIR/cartographer-klipper
}

update_repository() {
    cd $WORKDIR/cartographer-klipper
    git fetch
    git switch master
    git reset --hard origin/master
}

setup_ven() {
    virtualenv --system-site-packages $WORKDIR/klippy-env
    $WORKDIR/klippy-env/bin/pip3 install -r $WORKDIR/klipper/scripts/klippy-requirements.txt
}

enable_bootloader() {
    #TODO check if device is already in bootloader?
    CARTO_DEV=$(ls /dev/serial/by-id/usb-Cartographer*)
    cd $WORKDIR/klipper/scripts
    sudo $WORKDIR/klippy-env/bin/python -c "import flash_usb as u; u.enter_bootloader('$CARTO_DEV')"
}

flash_cartographer() {
    CATAPULT_DEV=$(ls /dev/serial/by-id/usb-katapult*)
    sudo $WORKDIR/klippy-env/bin/python $WORKDIR/klipper/lib/canboot/flash_can.py -f $WORKDIR/cartographer-klipper/firmware/v2-v3/survey/5.1.0/Survey_Cartographer_K1_USB_8kib_offset.bin -d $CATAPULT_DEV
}

prereqs
gather_repositories
update_repository
setup_ven
enable_bootloader
# gotta give it time to show up
sleep 5
flash_cartographer

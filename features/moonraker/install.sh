#!/bin/ash

set -e

SCRIPT_DIR=$(readlink -f $(dirname ${0}))

cd ${HOME}

export TMPDIR=/mnt/UDISK/tmp
mkdir -p "${TMPDIR}"

# MUST have Entware installed
if [ ! -f /opt/bin/opkg ]; then
    echo "E: you must have entware installed!"
    exit 1
fi

# handle entware being installed in the current login
if [ -f /etc/profile.d/entware.sh ]; then
    echo ${PATH} | grep -q /opt || source /etc/profile.d/entware.sh
fi

if ! type -p git > /dev/null; then
    opkg install git
fi

progress() {
    echo "#### ${1}"
}

install_virtualenv() {
    progress "Installing virtualenv ..."
    type -p virtualenv > /dev/null || pip install virtualenv

    # update pip to pull pre-built wheels
    if ! grep -qE '^extra-index-url=https://www.piwheels.org/simple$' /etc/pip.conf; then
        echo 'extra-index-url=https://www.piwheels.org/simple' >> /etc/pip.conf
    fi
}

remove_legacy_symlinks() {
    progress "Removing legacy symlinks ..."
    for ENTRY in moonraker moonraker-env; do
        if [ -L ${ENTRY} ]; then
            rm -f ${ENTRY}
        fi
    done
}

fetch_moonraker() {
    progress "Fetching mooonraker ..."
    # clone my mooonraker fork
    if [ -d moonraker/.git ]; then
        git -C moonraker pull
    else
        git clone https://github.com/jamincollins/moonraker.git
    fi
    # ensure we are on the k2 branch
    git -C moonraker checkout k2
}

create_moonraker_venv() {
    progress "Creating mooonraker venv..."
    # python 3.9.12
    test -d moonraker-env || virtualenv -p /usr/bin/python3 ~/moonraker-env

    ./moonraker-env/bin/pip \
        install \
        --upgrade \
        --find-links=${SCRIPT_DIR}/wheels \
        --requirement moonraker/scripts/moonraker-requirements.txt

    ./moonraker-env/bin/pip \
        install \
        lmdb

    python3 ${SCRIPT_DIR}/../../scripts/fix_venv.py ~/moonraker-env
}

replace_moonraker() {
    progress "Stopping legacy mooonraker ..."
    /etc/init.d/moonraker stop

    progress "Replacing legacy mooonraker with mainline ..."

    # update init script location for new config file location
    rm -f /etc/rc.d/S*moonraker
    ln -sf ${SCRIPT_DIR}/moonraker.init /etc/init.d/moonraker
    ln -sf ${SCRIPT_DIR}/moonraker.init /opt/etc/init.d/S56moonraker

    # full copy not symlink here
    cp ${SCRIPT_DIR}/moonraker.conf /mnt/UDISK/printer_data/config/moonraker.conf

    progress "Starting mooonraker ..."
    /etc/init.d/moonraker start
}

modify_moonraker_asvc() {
    progress "Modifying moonraker.asvc ..."
    MOONRAKER_ASVC=/mnt/UDISK/printer_data/moonraker.asvc
    for SERVICE in webrtc cartographer klipper; do
        if ! grep -qE "${SERVICE}" ${MOONRAKER_ASVC}; then
            echo "${SERVICE}" >> ${MOONRAKER_ASVC}
        fi
    done
}

wait_for_moonraker() {
    progress "Waiting for moonraker to start ..."
    count=0
    while ! nc -z 127.0.0.1 7125; do
        if [ $count -gt 60 ]; then
            echo "E: moonraker failed to start!"
            exit 1
        fi
        count=$((count + 1))
        sleep 1
    done
}

install_virtualenv
remove_legacy_symlinks
fetch_moonraker
create_moonraker_venv
modify_moonraker_asvc
replace_moonraker
wait_for_moonraker

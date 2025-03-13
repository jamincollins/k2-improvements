#!/bin/ash

set -xe

SCRIPT_DIR=$(readlink -f $(dirname ${0}))

install_feature() {
    FEATURE=${1}
    if [ ! -f /tmp/${FEATURE} ]; then
        ${SCRIPT_DIR}/features/${FEATURE}/install.sh
        touch /tmp/${FEATURE}
    fi
}

install_feature better-init
install_feature skip-setup
install_feature moonraker
install_feature fluidd
install_feature screws_tilt_adjust
install_feature cartographer
mkdir -p /tmp/macros
install_feature macros/bed_mesh
install_feature macros/m191
install_feature macros/start_print
install_feature macros/overrides

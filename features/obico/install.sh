#!/bin/ash

set -e

SCRIPT_DIR="$(readlink -f $(dirname $0))"

cd ${HOME}

git clone https://github.com/jamincollins/moonraker-obico.git
cd moonraker-obico
git checkout k2

export CREALITY_VARIANT=k2

sh ./scripts/install_creality.sh

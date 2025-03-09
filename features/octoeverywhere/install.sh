#!/bin/ash

set -e

cd ${HOME}

# Only pull the repo if it doesn't exist.
[ -d "./octoeverywhere" ] && echo "OctoEverywhere repo already exists, skipping clone." || git clone https://github.com/QuinnDamerell/OctoPrint-OctoEverywhere.git octoeverywhere
cd octoeverywhere

# Ensure we have the most recent bits.
git fetch --all
git reset --hard origin/master
git pull

# Run the installer, it will handle all of the K2 special logic.
sh ./install.sh

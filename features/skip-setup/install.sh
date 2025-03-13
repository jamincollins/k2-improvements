#!/bin/ash

set -e

TMPFILE=$(mktemp)
jq \
    '.user_info.self_test_sw = 0 | .user_info.screensaver = 120' \
    /mnt/UDISK/creality/userdata/config/system_config.json \
    > $TMPFILE
mv $TMPFILE /mnt/UDISK/creality/userdata/config/system_config.json
jq . /mnt/UDISK/creality/userdata/config/system_config.json

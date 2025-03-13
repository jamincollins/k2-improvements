#!/bin/ash

# the "all" on wipe.sock does NOT fully remove everything
# yes, I know... WHY?!?!?!

UDISK_DIRS=$(find /mnt/UDISK/ -maxdepth 1 -type d)

echo "Removing UDISK directories ..."
for DIR in ${UDISK_DIRS}; do
    if [ "${DIR}" == "/mnt/UDISK/" ]; then
        continue
    elif [ "${DIR}" == "/mnt/UDISK/root" ]; then
        continue
    elif [ "${DIR}" == "/mnt/UDISK/bin" ]; then
        continue
    fi
    rm -rf ${DIR}
done

echo "Begin factory reset..."
echo "all" | /usr/bin/nc -U /var/run/wipe.sock

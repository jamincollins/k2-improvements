#!/bin/ash

SCRIPT_DIR="$(readlink -f $(dirname $0))"

if grep -c '^ssh' /etc/dropbear/authorized_keys -eq 0; then
    echo "No authorized keys found in /etc/dropbear/authorized_keys"
    exit 1
fi

echo "Updating dropbear init script to disable password authentication ..."
cp -f "${SCRIPT_DIR}/dropbear.init" /etc/init.d/dropbear
chmod +x /etc/init.d/dropbear

echo "Restarting dropbear..."
/etc/init.d/dropbear restart

echo "Done"

echo "I: you need to log back in for changes to take effect!"
echo "I: logging you out now!"
echo "I: please reconnect to continue"
# terminate the SSH session
pgrep dropbear | grep -v "^$(pgrep -o dropbear)$" | xargs kill -9

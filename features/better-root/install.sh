#!/bin/sh
set -e

move_homedir() {
    # only want to do this once
    if ! grep -qE 'root.*UDISK' /etc/passwd; then
        if [ ! -d /mnt/UDISK/root ]; then
            mkdir /mnt/UDISK/root
        fi
        rsync --remove-source-files -a /root/ /mnt/UDISK/root/
        # just remove any overlays for the original root location
        rm -fr /overlay/upper/root/*
        # change root homedir
        sed -i 's,/root,/mnt/UDISK/root,' /etc/passwd
        sync
    fi
}

link_up() {
    cd /mnt/UDISK/root
    # link up the various printer bits in their normal location
    ln -s /usr/share/klipper .
    ln -s /usr/share/klippy-env/ .
    ln -s /mnt/UDISK/printer_data/ .
    ln -s /usr/share/moonraker .
    ln -s /usr/share/moonraker-env .
}

aliases() {
    # update aliases
    cat > /etc/profile.d/aliases << EOF
alias grep='grep --color=always'
EOF
}

if grep -qE 'root.*UDISK' /etc/passwd; then
    exit 0
fi
move_homedir
link_up
#aliases

echo "I: you need to log back in for changes to take effect!"
echo "I: logging you out now!"
echo "I: please reconnect to continue"
# terminate the SSH session
pgrep dropbear | grep -v "^$(pgrep -o dropbear)$" | xargs kill -9

#!/bin/bash
set -e

# Replace these placeholders with your actual VID:PID strings.
# For example: NORMAL_VIDPID="1234:abcd" and BOOTLOADER_VIDPID="5678:ef01"
NORMAL_VIDPID="1d50:614e"
BOOTLOADER_VIDPID="1d50:6177"

# Full path to the usbipd executable in Windows.
USBIPD_PATH='C:\Program Files\usbipd-win\usbipd.exe'

WORKDIR=$(mktemp -d)
trap "sudo rm -rf $WORKDIR" EXIT

# This function looks for a USB device in the usbipd-win list matching the given VID:PID.
# Once found, it first binds the device, then attaches it to WSL using the updated syntax.
bind_and_attach_usb_device() {
    local vidpid="$1"
    echo "Attempting to bind and attach device with VID:PID $vidpid..."
    local busid=""
    # Wait up to 30 seconds for the device to show up in the usbipd list.
    for i in {1..30}; do
        busid=$(powershell.exe -Command "& '$USBIPD_PATH' list" | tr -d '\r' | grep -i "$vidpid" | awk '{print $1}')
        if [ -n "$busid" ]; then
            echo "Found device with bus ID $busid for VID:PID $vidpid"
            break
        fi
        sleep 1
    done

    if [ -z "$busid" ]; then
        echo "Error: Could not find device with VID:PID $vidpid in usbipd list."
        exit 1
    fi

    # Bind the device (make it available for WSL).
    echo "Binding device on bus ID $busid..."
    powershell.exe -Command "& '$USBIPD_PATH' bind --busid $busid"

    # Attach the device using the new syntax with --wsl.
    echo "Attaching device on bus ID $busid..."
    powershell.exe -Command "& '$USBIPD_PATH' attach --busid $busid --wsl"
}

prereqs() {
    # Install the needed packages
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
    git clone "https://github.com/Klipper3d/klipper" "$WORKDIR/klipper"
    git clone "https://github.com/Cartographer3D/cartographer-klipper.git" "$WORKDIR/cartographer-klipper"
}

update_repository() {
    cd "$WORKDIR/cartographer-klipper"
    git fetch
    git switch master
    git reset --hard origin/master
}

setup_ven() {
    virtualenv --system-site-packages "$WORKDIR/klippy-env"
    "$WORKDIR/klippy-env/bin/pip3" install -r "$WORKDIR/klipper/scripts/klippy-requirements.txt"
}

enable_bootloader() {
    # Locate the device (by its "Cartographer" label) and command it to enter bootloader mode.
    CARTO_DEV=$(ls /dev/serial/by-id/usb-Cartographer* 2>/dev/null || true)
    if [ -z "$CARTO_DEV" ]; then
        echo "Error: Could not find normal device (/dev/serial/by-id/usb-Cartographer*)."
        exit 1
    fi
    cd "$WORKDIR/klipper/scripts"
    echo "Entering bootloader on $CARTO_DEV"
    sudo "$WORKDIR/klippy-env/bin/python" -c "import flash_usb as u; u.enter_bootloader('$CARTO_DEV')"
}

flash_cartographer() {
    local CATAPULT_DEV=""
    # Wait up to 30 seconds for the bootloader device to appear.
    for i in {1..30}; do
        CATAPULT_DEV=$(ls /dev/serial/by-id/usb-katapult* 2>/dev/null || true)
        if [ -n "$CATAPULT_DEV" ]; then
            echo "Found bootloader device: $CATAPULT_DEV"
            break
        fi
        sleep 1
    done

    if [ -z "$CATAPULT_DEV" ]; then
        echo "Error: Bootloader device did not appear."
        exit 1
    fi

    sudo "$WORKDIR/klippy-env/bin/python" "$WORKDIR/klipper/lib/canboot/flash_can.py" \
        -f "$WORKDIR/cartographer-klipper/firmware/v2-v3/survey/5.1.0/Survey_Cartographer_K1_USB_8kib_offset.bin" \
        -d "$CATAPULT_DEV"
}

# === Main Script Flow ===

prereqs

# Step 1: Bind and attach the normal (pre‑bootloader) device to WSL.
bind_and_attach_usb_device "$NORMAL_VIDPID"

gather_repositories
update_repository
setup_ven

# Step 2: Put the device into bootloader mode.
enable_bootloader

# Allow time for the device to disconnect/reconnect.
sleep 5

# Step 3: Bind and attach the bootloader-mode device to WSL.
bind_and_attach_usb_device "$BOOTLOADER_VIDPID"

# Step 4: Flash the firmware.
flash_cartographer
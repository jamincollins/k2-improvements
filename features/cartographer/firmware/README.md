# Cartographer Firmware

## NOTE

It is best if you only have one Cartographer (or similar USB 3d printer accessory) attached to the system you are using for flashing.  As the VID:PID combination for the Cartographer is not unique, as indicated from this `lsusb` output:

```raw
Bus 001 Device 017: ID 1d50:614e OpenMoko, Inc. stm32f446xx
Bus 001 Device 016: ID 1d50:614e OpenMoko, Inc. stm32g0b1xx
Bus 001 Device 015: ID 1d50:614e OpenMoko, Inc.
```

## Linux

The linux flash script is provided by JaminCollins and is suitable to run on Debian and Ubuntu OS's, this can be a bootable live usb if necessary.

1. Connect the Cartographer via the supplied USB cable
2. Open terminal and download the script by running the following in a terminal:

    ```bash
    wget https://raw.githubusercontent.com/jamincollins/k2-improvements/refs/heads/main/features/cartographer/firmware/flash.sh
    ```

3. Run script by entering `bash ./flash.sh` in the terminal and hitting enter

The script should automatically do everything and leave you with a flashed Cartographer.

## Windows Install

The Windows installation is a modified version of the above provided by bigadz and can be run on Windows using WSL2 Ubuntu and usbipd-win. This was tested using Ubuntu 20.04 under WSL2 and usbipd-win 4.4.0 however latest version should be fine.

1. Install [Ubuntu WSL2](https://documentation.ubuntu.com/wsl/en/latest/howto/install-ubuntu-wsl2/)
2. Install [usbipd-win msi installer](https://github.com/dorssel/usbipd-win/releases)
3. Connect the Cartographer via the supplied USB cable
4. Open Ubuntu WSL (as Administrator) and download the flash script by entering

    ```bash
    wget https://raw.githubusercontent.com/jamincollins/k2-improvements/refs/heads/main/features/cartographer/firmware/WSLFlash.sh
    ```

5. Run the script by entering `bash ./WSLFlash.sh` in the terminal and hitting enter

The script should automatically do everything and leave you with a flashed Cartographer.

## Mac Install
The Mac process is utilizes the Linux method with a Virtual Machine in order to prevent poluting the local environment. VMWare Fusion is [now free for personal use](https://blogs.vmware.com/teamfusion/2024/05/fusion-pro-now-available-free-for-personal-use.html) so this guide utilizes that.

Setup:
1. [Install VMWare Fusion](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion) (you will need to create an account)
2. Download and install a arm64 [Ubuntu Server image](https://ubuntu.com/download/server/arm) as a VMWare Guest
3. Power off the guest when finished.

When flashing the Cartographer, the Cartographer will reboot and re-connect to USB. The scripts try to account for this with sleep commands but in my case the sleep commands were not enough. Modify the USB settings for the VM so that all newly connected USB devices get automatically connected to the VM:
1. VM Guest Settings > USB > Advanced USB Options
2. Set the "When a new USB device is plugged into this Mac while this virtual machine is running, VMWare" dropdown to `Connect to this virtual machine`

Cartographer Flashing:
1. Power up the VM and login.
2. Connect the Cartographer to USB
3. Verify that an `OpenMoko` device is present when running `lsusb`
4. Download the script by running the following in the terminal:

    ```bash
    wget https://raw.githubusercontent.com/jamincollins/k2-improvements/refs/heads/main/features/cartographer/firmware/flash.sh
    ```

5. Run script by entering `bash ./flash.sh` in the terminal and hitting enter

The script should automatically do everything and leave you with a flashed Cartographer.

If the script fails due to not being able to find the Cartographer, etc, you can unplug the Cartographer, wait a few moments, plug it back in and try again. You may need to increase the duration for or add more sleep statements to the bottom of the script.

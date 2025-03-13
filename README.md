# K2 Improvements

## DISCLAIMER

Use at your own risk, I'm not responsible for fires or broken dreams.  But you do get to keep both halves if something breaks.

## Warning

As a _heads up_ these improvements are not compatible with Creality's _auto-calibration_.  In our experience we get better results through manual tuning.

## Start Here at Bootstrap

The Bootstrap is a requirement for the improvements to install properly, so this must be accomplished first. Of note, it will install entware tools necessary to accomplish the installs. Additionally, root is enabled by default with the password: 'creality_2024'. At some point, we recommend running command 'passwd' in the terminal to change the defualt password to something secure. 

1. Enable root access on the K2 Plus by going to Settings, General tab and root on the physical screen. Take note of the password.
2. Download bootstrap [https://github.com/jamincollins/k2-improvements/releases/tag/bootstrap](https://github.com/jamincollins/k2-improvements/releases/tag/bootstrap) and extract the folder.
3. To install the bootstrap, connect to your K2 Plus's Fluid interface via browser **http://PrinterIP:4408**
4. Unzip the downloaded bootstrap folder and upload the extracted bootstrap folder by going to Configuration **{...}**, **+**, **Upload Folder**, and selecting the extracted bootstrap folder.
    ![image](https://github.com/user-attachments/assets/3d242efc-4cf8-412d-b4b0-59507720f5ad)
5. SSH to the K2 Plus using any terminal tool (e.g. PuTTy) using the printers ip adress, port 22, user "root" and the password noted in step 1.
6. Recommend performing a wipe prior to install due to potential conflicts with previous mods enter the command 'echo "all" | /usr/bin/nc -U /var/run/wipe.sock' into your terminal.
7. If you execute a wipe, you will need to go through setup on the K2 screen and complete all the way through creality cloud connection. This will give you the wifi/network connection that you will need and connect appropriately to creality cloud. Stop at the calibration, you can do this later.
8. To start the boostrap install paste into the terminal `sh /mnt/UDISK/printer_data/config/bootstrap/bootstrap.sh` and hit enter.
9. Once the setup completes, it will log you out of your terminal and you will need to log back in.

## Installers

A unified installation menu is _planned_.  For now each feature can be found under the [features](./features/) directory.  A `README.md` and installation script `install.sh` are provided for each option.

The unified installer will understand inter option dependencies and ensure they are met.

For now, there are two default installations:   **Note either option will take some time and seem to hang at times. Be patient as it is moving lots of files and creating venvs for klipper and moonraker full installs

* Option 1: `gimme-the-jamin.sh` - Used to install carto **NOTE MUST HAVE CARTO FLASHED AND PLUGGED IN AND READY TO GO by following instructions [here](https://github.com/jamincollins/k2-improvements/blob/main/features/cartographer/firmware/README.md)

    To run use the terminal command `sh /mnt/UDISK/root/k2-improvements/gimme-the-jamin.sh` 

    After install you will need to calibrate the carto by following instructions [here](https://github.com/jamincollins/k2-improvements/blob/main/features/cartographer/SETUP.md)**

* Option 2: `no-carto.sh` - Use this if you aren't going to use a carto, or don't have your carto yet.

    To run use the terminal command `sh /mnt/UDISK/root/k2-improvements/no-carto.sh`

They both install the same set of features (those that I use).  The only difference is whether or not the cartographer bits are installed. If you start with no-carto.sh and later get a carto, you can then run the gimme-the-jamin.sh script and it will install all of the necessary carto items appropriately.

You are still welcome to hand pick which features you want to install.

## Donations

Donations are definitely _not required_, they are appreciated.  If you'd like to donate you can do so [here](https://ko-fi.com/jamincollins).

## Features

* [axis_twist_compensation](./features/axis_twist_compensation/README.md)
* [better init](./features/better-init/README.md)
* [better root](./features/better-root/README.md) home directory
* [Cartographer](./features/cartographer/README.md) support
* installs [Entware](https://github.com/Entware/Entware)
* updated [Fluidd](./features/fluidd/README.md)
* updated [Moonraker](./features/moonraker/README.md)
* [Obico](./features/obico/README.md) - _WIP_
* implements [SCREWS_TILT_CALCULATE](https://www.klipper3d.org/Manual_Level.html#adjusting-bed-leveling-screws-using-the-bed-probe)

And a few quality of life improvement macros

* [MESH_IF_NEEDED](./features/macros/bed_mesh/README.md)
* [START_PRINT](./features/macros/start_print/README.md)
* [M191](./features/macros/m191/README.md)

### Bed Leveling

Sadly, many of the K2 beds resemble a taco or valley.  In the [bed_leveling](bed_leveling) folder you will find a python based script and short writeup on how to apply aluminium tape to shim the bed.

## Credits

* [@Guilouz](https://github.com/Guilouz) - standing on the shoulders of giants
* [@stranula](https://github.com/stranula)
* [@juliosueiras](https://github.com/juliosueiras)

* Moonraker - [https://github.com/Arksine/moonraker](https://github.com/Arksine/moonraker)
* Klipper - [https://github.com/Klipper3d/klipper](https://github.com/Klipper3d/klipper)
* Fluidd - [https://github.com/fluidd-core/fluidd](https://github.com/fluidd-core/fluidd)
* Entware - [https://github.com/Entware/Entware](https://github.com/Entware/Entware)
* Obico - [https://www.obico.io/](https://www.obico.io/)
* SimplyPrint - [https://simplyprint.io/](https://simplyprint.io/)

## FAQ

See the [FAQ](./FAQ.md)

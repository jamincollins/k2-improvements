# Donations

While donations are definitely _not required_, they are appreciated.  I you'd like to donate you can do so [here](https://ko-fi.com/jamincollins).

# Bootstrap

Given the difficulty of getting several files on to a stock K2 I'm suggesting user place this archive a USB thumb drive and plug it into the side of the K2.
It'll automatically mount at `/mnt/exUDISK`.

You should be able to then run either installer:
* `/mnt/exUDISK/k2-improvements/menu.sh`
* `/mnt/exUDISK/k2-improvements/entware/menu.sh`


DISCLAIMER: use at your own risk, not responsible for fires or broken dreams.  But you do get to keep both halves if something breaks.

# Features
* restores and implements SCREWS_TILT_CALCULATE
* improved Bed Mesh, removes 9x9 limitation
* native Fluidd webcam feed/stream
* an M191 implementation
* improved START_PRINT macro

## START_PRINT

The improved START_PRINT macro adds:
* support for the M191 macro through an optional **CHAMBER_TEMP** parameter
* Z_TILT_ADJUST
* final M190 call to ensure the bed is at desired temperature

To leveraget the M191, you can pass the desired chamber temperature to `START_PRINT` by replacing this line in your slicer's **Start G-code** macro:
```
START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[bed_temperature_initial_layer_single]
```
with this one:
```
START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[bed_temperature_initial_layer_single] CHAMBER_TEMP=[overall_chamber_temperature]
```

## M191

This macro can be used in a couple different ways.

Some slicers (perhaps most) have a setting to generate M141 and M191 temperature control commands.  For Creality Print and Orca Slicer this setting is among the filament setttings near the **Chamber temperature** setting.

## Fluidd / K2 Webcam

Open Settings -> Cameras -> ADD CAMERA

* Stream type: **WebRTC (Creality K2 Plus)**
* Camera Url Stream: **http://<printer_name/ip>:8000**

# Entware

The addition of Entware opens up a number of possibilites including:

* restoration of classic MJPG camera feeds
* Obico

# Extras

## Bed Leveling

Sadly, many of the K2 beds resemble a taco or valley.  In the [bed_leveling](bed_leveling) folder you will find a python based script and short writeup on how to apply aluminium tape to shim the bed.

# Credits

* [@Guilouz](https://github.com/Guilouz) - standing on the shoulders of giants
* [@stranula](https://github.com/stranula)
* [@juliosueiras](https://github.com/juliosueiras)

* Moonraker - https://github.com/Arksine/moonraker
* Klipper - https://github.com/Klipper3d/klipper
* Fluidd - https://github.com/fluidd-core/fluidd
* Entware - https://github.com/Entware/Entware
* Obico - https://www.obico.io/
* OctoEverywhere - https://www.octoeverywhere.com

## Fluidd / K2 Webcam

The **WebRTC (Creality K2 Plus)** Stream type implemented by [@juliosueiras](https://github.com/juliosueiras)

# Known Issues

## Obico does not have a camera feed

I am actively working on resolving this.  Obico requires a camera service/binary known as `janus`.  I am not aware of a compatible build of `janus` for the K2's operating system.  So, I'm working on building it.

# FAQ

## I've installed the Camera fixes but I still can't setup the webcam in Fluidd

If you tried to setup the webcam before installing the fixes you've got at least one (or more) broken entries. Because these entries are broken, they can't be removed normally, but we have included a script ease their removal.

```
./scripts/delete-camera <name>
```

## What about KAMP/ Adaptive Bed Mesh

There's a gotcha for this.  Since you're only probing the print area, if your bed has say an upward bend of more than a layer or two, moves outside the print area (like say color swaps) may, run into the bed...

So, this is currently on hold until a safe path forward can be determined/found.

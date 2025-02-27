# K2 Cartographer Setup

## Firmware

The Cartographer **MUST** be flashed with the special K1 firmware.

The instructions and script for doing so can be found [here](./firmware/README.md)

## Print Mount and spacers for K2

The mount and spacers required for the cartographer installation have been provided by stranula, [here](https://www.printables.com/model/1198696-k2-plus-cartographer-mount-shroud-and-spacers). We recommend printing these at a minimum in PETG, but ABS, ASA or any other high glass transition temp filament is preferred.

The files are provided in the desired printing orientation, use a setting that you are comfortable with for functional parts with reasonable tolerances

## Calibration

This is much the same as the process detailed [here](https://docs.cartographer3d.com/cartographer-probe/installation-and-setup/installation/calibration#initial-calibration), with only slight adjustments for the oddities of the K2.

Issue the following commands in your Fluidd console:

```raw
PROBE_SWITCH MODE=touch
SAVE_CONFIG
```

Once Klipper restarts, enter the following command.

```raw
G28 X Y
```

The following `G28 Z` will lower the bed to the bottom of the printer, raise it and then give an error **No model loaded**, but it will also get the toolhead and bed near where we need them.

```raw
G28 Z
```

At this point you can query your endstops:

```raw
QUERY_ENDSTOPS
```

You will likely see something like the following:

```raw
x:open y:open z:TRIGGERED
```

This is normal and expected.

The following is needed on the K2 to allow us to walk the bed to the toolhead.

```raw
SET_KINEMATIC_POSITION Z=200
```

Now we begin the probe calibration process:

```raw
CARTOGRAPHER_CALIBRATE METHOD=manual
```

Use the Fluidd UI to raise the bed step by step toward the nozzle.  Use a piece of paper  or a feeler gauge to measure the offset. Once finished remove the paper/gauge and accept the position.

```raw
ACCEPT
```

```raw
SAVE_CONFIG
```

Wait for Klipper to restart.  Then, home the printer.

```raw
G28
```

Test the accuracy.  This will only use the scanning coil, it will not touch the bed.

```raw
PROBE_ACCURACY
```

Now to further tune the Cartographer we need to measure the backlash of the Z kinematics:

```raw
CARTOGRAPHER_ESTIMATE_BACKLASH
```

In output you're looking for the "delta" value. For example, the following shows my backlash as `0.00070`.

```raw
Median distance moving up 1.99701, down 1.99772, delta 0.00070 over 20 samples
```

Take your value, open the `custom/cartographer.cfg` and add the value inside the `[scanner]` section like so:

```raw
[scanner]
backlash_comp: 0.00070
```

## Touch

Home and level everything.

```raw
G28
Z_TILT_ADJUST
G28 Z
```

Initiate a threshold scan. This will determine your threshold for cartographer. The threshold will determine how much force is required to touch your bed consistently.

**This _will_ touch the nozzle to the bed**

Its okay if at first it doesnt touch the bed at all, this is completely normal. It will eventually start touching.

```raw
CARTOGRAPHER_THRESHOLD_SCAN
```

This _will_ take some time as several different thresholds are tested.  On the K2, we've found that around 1500 seems to be the magic point.

Now do a touch calibration with the new threshold.

```raw
CARTOGRAPHER_CALIBRATE
```

If everything went correctly the touch test should pass and you can now finish by saving these variables to your config.

```raw
SAVE_CONFIG
```

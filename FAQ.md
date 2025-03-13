# FAQ

## Can I still use the auto calibrate features?

A: Unfortunately, at this time they are not supported. No.

## I've installed the Fluidd update, but the camera doesn't show up

A: Have you tried using Firefox?  As far as we can tell this is due to an odd interaction between Creality's WebRTC implementation and Chrome based browsers.

## My bed crashes into the bottom! What did you do?

A: This has nothing to do with the K2 improvements.  Sadly, many of us have seen this with the stock 1.1.2.x series firmware.

## Why is the printer homing to the back and erroring? What did you do?

A: See above, this is a bug with the 1.1.2.x firmware.

## My touch screen doesn't show temperatures until I home my printer! What did you do?

A: See above, this is a bug with the 1.1.2.x firmware.

## When I print from the side spool, the printer still acts like I'm using the CFS

A: This is an issue with the k2-improvements.  We suspect it has something to do with the moonraker update and are investigating.

For now an a work around is to remove this line from your machine start g-code when using the side spool:

```raw
T[initial_no_support_extruder]
```

## Fluidd seems to hang at 99% even though the print appears to have finished

A: It apepars that this is an issue with Creality Print not placing a newline at the end of the sliced gcode.

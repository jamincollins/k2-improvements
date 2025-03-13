# Axis Twist Compensation

## Why?

This will sound strange (since I've included it as an option), but I don't recommend using this feature.  Does it improve prints?  Yes.  Then why don't I recommend it?  IMO this simply masks the K2 issue.  Specifically it makes the K2 bed _look_ flat.

## Calibration

```raw
G28
Z_TILT_ADJUST
AXIS_TWIST_COMPENSATION_CALIBRATE AUTO=TRUE SAMPLE_COUNT=10
SAVE_CONFIG
```

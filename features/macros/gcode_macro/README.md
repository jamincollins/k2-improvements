# START_PRINT

## Why

Adding a working Adaptive Purge line macro that you can call by copying start_print.cfg to your overrides.cfg and uncommenting "AMP MINX={MINX} MINY={MINY}" (second line from the bottom). The need for this arose when Adaptive Meshing is enabled, it has proven to drag the nozzle on the plate for some reason. This adaptive purge removes the standard purge from the bottom left of the plate. This also aides in faster meshing times, as you will only mesh the print area and MINX -5 and MINY - 5.

* Finds the "0" of X of the PRINT AREA only, not the WHOLE PLATE, and sets it as "MINX"
* Finds the "0" of Y of the PRINT AREA only, not the WHOLE PLATE, and sets it as "MINY"
* Applies a thick purge line at MINX - 5, MINY - 5.
* Continues your print as normal, no more purge line at the bottom left of the plate.

## Setup

Install this feature and update your slicer's start gcode to send the **MINX** and **MINY** as parameters, and **REMOVE** the factory purge line.

Here is an example for Creality Print:

```raw
M140 S0
M104 S0 
START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[bed_temperature_initial_layer_single] CHAMBER_TEMP=[overall_chamber_temperature] MATERIAL=[filament_type[initial_tool]] MINX=[first_layer_print_min_0] MINY=[first_layer_print_min_1]
T[initial_no_support_extruder]
M204 S2000
G1 Z3 F600
```

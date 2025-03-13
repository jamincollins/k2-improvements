# Better Init

## Why

The existing init scripts on the K2 feel like a bit of an after thought.

They don't create traditional tracking mechanisms for whether a process is running or not, such as a PID file.

The lack of these tracking mechanisms mean they don't allow integration with Moonraker and thereby Fluidd.

## Updated Init Scripts

This replaces some of the key init scripts with improved versions that do provide the process tracking.

Additionally, wrapper scripts are provided to allow integration with Moonraker and Fluidd.  This allows for service management of these processes from Fluidd's UI.

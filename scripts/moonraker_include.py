#!/usr/bin/env python3

import os
import sys

target = f"[include {sys.argv[1]}]"

update_needed = True

moonraker_config = os.path.expanduser('~/printer_data/config/moonraker.conf')

with open(moonraker_config, 'r') as handle:
    contents = handle.readlines()

    for line in contents:
        if line.strip() == target:
            update_needed = False
            break

if update_needed:
    contents.append('\n' + target + '\n')
    with open(moonraker_config, 'w') as handle:
        handle.writelines(contents)

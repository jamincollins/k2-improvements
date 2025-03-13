#!/usr/bin/env python3

import os
import sys

def add_include(config_path, include_path, commented=False):
    """
    Add an include statement to a configuration file if it doesn't exist.

    Args:
        config_path (str): Full path to the configuration file
        include_path (str): Path to be included
        commented (bool): Whether to comment out the include (default: False)
    """
    target = f"[include {include_path}]"
    if commented:
        target = f"#{target}"

    # Create the directory path if it doesn't exist
    os.makedirs(os.path.dirname(config_path), exist_ok=True)

    # If file doesn't exist, create it with the include
    if not os.path.exists(config_path):
        with open(config_path, 'w') as handle:
            handle.write(target + '\n')
        return

    update_needed = True
    insert_before = False

    with open(config_path, 'r') as handle:
        contents = handle.readlines()

        for line in contents:
            if line.strip() == target:
                update_needed = False
                break
            if line.startswith('#*#'):
                insert_before = True
                break
            if line.startswith('[include overrides.cfg]'):
                insert_before = True
                break

    if update_needed:
        if insert_before:
            contents.insert(contents.index(line), target + '\n')
        else:
            contents.append(target + '\n')
        with open(config_path, 'w') as handle:
            handle.writelines(contents)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: script.py <config_path> <include_path> [commented]")
        sys.exit(1)

    config_path = os.path.expanduser(sys.argv[1])
    include_path = os.path.expanduser(sys.argv[2])
    commented = bool(sys.argv[3]) if len(sys.argv) > 3 else False

    add_include(config_path, include_path, commented)

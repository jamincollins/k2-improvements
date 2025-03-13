import os
import sys
import sysconfig
import shutil
from pathlib import Path

def update_so_files(venv_path):
    """
    Walk through a virtualenv and update all SO files to match system expectations.

    Args:
        venv_path: Path to the virtualenv directory
    """
    # Get the expected suffix for this Python installation
    expected_suffix = sysconfig.get_config_var('EXT_SUFFIX')
    if not expected_suffix:
        print("Error: Could not determine Python extension suffix", file=sys.stderr)
        return 1

    print(f"Expected suffix: {expected_suffix}")

    # Walk through all directories in the venv
    for root, _, files in os.walk(venv_path):
        for filename in files:
            if filename.endswith('.so'):
                filepath = Path(root) / filename

                # Skip if it already has the correct suffix
                if filename.endswith(expected_suffix):
                    continue

                # Get the base module name (strip off .cpython-*-*.so)
                base_name = filename.split('.cpython-')[0]
                new_name = base_name + expected_suffix
                new_path = filepath.parent / new_name

                print(f"Renaming: {filepath} -> {new_path}")
                try:
                    shutil.move(str(filepath), str(new_path))
                except OSError as e:
                    print(f"Error renaming {filepath}: {e}", file=sys.stderr)

    return 0

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: script.py <venv_path>", file=sys.stderr)
        sys.exit(1)

    venv_path = sys.argv[1]
    if not os.path.isdir(venv_path):
        print(f"Error: {venv_path} is not a directory", file=sys.stderr)
        sys.exit(1)

    sys.exit(update_so_files(venv_path))

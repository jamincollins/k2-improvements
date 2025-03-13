import logging
import os
import re

def remove_section_from_ini(input_file: str, section_to_remove: str, backup_dir: str = "backup") -> tuple[bool, str]:
    """
    Remove a section from an INI file and save the removed section separately, preserving comments.

    Args:
        input_file: Path to the input INI file
        section_to_remove: Name of the section to remove
        backup_dir: Directory to store the removed section (default: "backup")

    Returns:
        tuple: (success: bool, message: str)
    """
    try:
        input_file = os.path.expanduser(input_file)
        backup_dir = os.path.expanduser(backup_dir)

        logging.info(f"Backup directory: {backup_dir}")
        # Create backup directory if it doesn't exist
        os.makedirs(backup_dir, exist_ok=True)


        # Read the original file content
        with open(input_file, 'r') as f:
            lines = f.readlines()
        logging.info("Read original file content")

        # Initialize variables
        current_section = None
        removed_lines = []
        kept_lines = []
        in_target_section = False
        found_section = False

        # Process the file line by line
        for line in lines:
            # Check for section header
            section_match = re.match(r'^\s*\[(.*?)\]\s*$', line)
            if section_match:
                current_section = section_match.group(1)
                in_target_section = (current_section == section_to_remove)
                if in_target_section:
                    found_section = True

            # Add line to appropriate list
            if in_target_section:
                removed_lines.append(line)
            else:
                kept_lines.append(line)

        if not found_section:
            return False, f"Section '{section_to_remove}' not found in {input_file}"

        backup_file = os.path.join(
            backup_dir,
            f"{section_to_remove}.cfg"
        )

        # Save the removed section
        with open(backup_file, 'w') as f:
            f.writelines(removed_lines)

        # Save the modified file
        with open(input_file, 'w') as f:
            f.writelines(kept_lines)

        return True, f"Section removed successfully. Backup saved to {backup_file}"

    except Exception as e:
        return False, f"Error: {str(e)}"

def main():
    """
    Example usage of the remove_section_from_ini function.
    """
    # Example usage
    input_file = "~/printer_data/config/printer.cfg"
    section_to_remove = "prtouch_v3"
    backup_dir = "~/printer_data/config/custom"

    success, message = remove_section_from_ini(input_file, section_to_remove, backup_dir)
    print(message)

if __name__ == "__main__":
    main()

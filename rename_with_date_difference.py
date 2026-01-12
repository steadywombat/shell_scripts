#!/usr/bin/env python3

# /// script
# dependencies = [
#   "python-dateutil",
# ]
# ///

"""

PRE-REQUISITES (macOS 2026):
Modern macOS prevents direct 'pip' installs. The easiest way to run this 
without environment errors is using 'pipx'.

1. Install Homebrew (if not already installed):
   /bin/bash -c "$(curl -fsSL raw.githubusercontent.com)"

2. Install pipx:
   brew install pipx
   pipx ensurepath



FOLDER DATE CALCULATOR & RENAMER
==============================================
DESCRIPTION:
Calculates time difference between folder dates and a base date.

HOW TO EXECUTE:
   To run in the CURRENT folder:
   pipx run ./rename_with_date_difference.py 20230226

   To run in a SPECIFIC folder:
   pipx run ./rename_with_date_difference.py 20230226 /Users/Name/Movies
"""

import os
import re
import argparse
from datetime import datetime
from dateutil.relativedelta import relativedelta

def get_relative_suffix(folder_date, base_date):
    """Calculates time difference and formats with underscores instead of spaces."""
    diff = relativedelta(folder_date, base_date)
    is_later = folder_date >= base_date
    direction = "later" if is_later else "before"
    
    y, m, d = abs(diff.years), abs(diff.months), abs(diff.days)
    parts = []
    if y: parts.append(f"{y}_year{'s' if y > 1 else ''}")
    if m: parts.append(f"{m}_month{'s' if m > 1 else ''}")
    if d: parts.append(f"{d}_day{'s' if d > 1 else ''}")
    
    # join with underscores and replace any remaining spaces
    suffix = f"_{'_'.join(parts)}_{direction}" if parts else "_same_day"
    return suffix.replace(" ", "_")

def rename_folders(target_dir, base_date_str):
    target_dir = os.path.abspath(target_dir)
    try:
        base_date = datetime.strptime(base_date_str, "%Y%m%d")
    except ValueError:
        print(f"Error: '{base_date_str}' is not in YYYYMMDD format.")
        return

    date_pattern = re.compile(r'^(\d{8})')
    pending_changes = []

    if not os.path.exists(target_dir):
        print(f"Error: Path '{target_dir}' does not exist.")
        return

    for folder_name in os.listdir(target_dir):
        folder_path = os.path.join(target_dir, folder_name)
        if not os.path.isdir(folder_path):
            continue
        match = date_pattern.match(folder_name)
        if match:
            try:
                folder_date = datetime.strptime(match.group(1), "%Y%m%d")
                suffix = get_relative_suffix(folder_date, base_date)
                
                # Prevent double-renaming
                if suffix in folder_name:
                    continue
                    
                new_name = f"{folder_name}{suffix}"
                pending_changes.append((folder_path, os.path.join(target_dir, new_name), folder_name, new_name))
            except ValueError:
                continue

    if not pending_changes:
        print(f"No valid folders found in: {target_dir}")
        return

    print(f"\nPROPOSED CHANGES IN: {target_dir}")
    print("=" * 80)
    for _, _, old, new in pending_changes:
        print(f"{old.ljust(40)} -> {new}")
    print("=" * 80)

    confirm = input(f"\nProceed with renaming these {len(pending_changes)} folders? (y/n): ").lower()
    if confirm != 'y':
        print("Aborted.")
        return

    for old_path, new_path, _, _ in pending_changes:
        try:
            os.rename(old_path, new_path)
        except OSError as e:
            print(f"Error renaming {old_path}: {e}")
    print("\nProcessing complete.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("date")
    parser.add_argument("path", nargs="?", default=".")
    args = parser.parse_args()
    rename_folders(args.path, args.date)

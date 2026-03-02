#!/usr/bin/env python3
"""
implode.py - Convert individual symlinks back into a directory symlink

Takes a directory containing individual symlinks and replaces it with
a single directory symlink to their common parent.

Usage:
    ./bin/implode.py <path>

Example:
    ./bin/implode.py dotfiles/hosts/j-bakotsu-mbp/nvim
"""

import sys
from pathlib import Path


def implode_directory(dir_path: Path) -> None:
    """
    Replace a directory of individual symlinks with a directory symlink.

    Args:
        dir_path: Path to the directory containing symlinks
    """
    if not dir_path.is_dir():
        print(f"Error: {dir_path} is not a directory", file=sys.stderr)
        sys.exit(1)

    if dir_path.is_symlink():
        print(f"Error: {dir_path} is already a symlink", file=sys.stderr)
        sys.exit(1)

    print(f"Imploding: {dir_path}")
    print()

    # Get all items in directory
    items = list(dir_path.iterdir())

    if not items:
        print("Error: Directory is empty", file=sys.stderr)
        sys.exit(1)

    # Verify all items are symlinks
    non_symlinks = [item for item in items if not item.is_symlink()]
    if non_symlinks:
        print("Error: Directory contains non-symlink files:", file=sys.stderr)
        for item in non_symlinks:
            print(f"  - {item}", file=sys.stderr)
        print("Cannot implode with customizations present.", file=sys.stderr)
        sys.exit(1)

    # Find common parent
    parents = set()
    for item in items:
        target = item.resolve()
        parents.add(target.parent)

    if len(parents) != 1:
        print("Error: Symlinks point to different directories:", file=sys.stderr)
        for parent in parents:
            print(f"  - {parent}", file=sys.stderr)
        print("Cannot implode - no common parent.", file=sys.stderr)
        sys.exit(1)

    common_parent = parents.pop()
    print(f"Common parent: {common_parent}")
    print()

    # Verify all items in common parent are represented
    parent_items = set(item.name for item in common_parent.iterdir())
    link_items = set(item.name for item in items)

    if parent_items != link_items:
        missing = parent_items - link_items
        extra = link_items - parent_items
        if missing:
            print(f"Warning: Some items from parent not linked: {missing}")
        if extra:
            print(f"Warning: Extra symlinks not in parent: {extra}")
        print()

    # Remove all symlinks
    for item in items:
        item.unlink()
        print(f"Removed: {item}")

    # Remove directory
    dir_path.rmdir()
    print(f"Removed directory: {dir_path}")
    print()

    # Create directory symlink
    dir_path.symlink_to(common_parent)
    print(f"Created: {dir_path} -> {common_parent}")
    print()
    print("Done! Individual symlinks collapsed into directory symlink.")


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description='Implode individual symlinks back into a directory symlink'
    )
    parser.add_argument('path', help='Path to directory containing symlinks')
    args = parser.parse_args()

    dir_path = Path(args.path)

    if not dir_path.exists():
        print(f"Error: {dir_path} does not exist", file=sys.stderr)
        sys.exit(1)

    implode_directory(dir_path)


if __name__ == '__main__':
    main()

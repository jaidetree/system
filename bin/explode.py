#!/usr/bin/env python3
"""
explode.py - Convert a directory symlink into individual symlinks

Takes a directory symlink in dotfiles/hosts/$hostname/ and replaces it with
a real directory containing individual symlinks to each item in the source.

Usage:
    ./bin/explode.py <path> [--deep]

Example:
    ./bin/explode.py dotfiles/hosts/j-bakotsu-mbp/nvim
"""

import os
import sys
from pathlib import Path


def explode_directory(link_path: Path, deep: bool = False) -> None:
    """
    Replace a directory symlink with individual symlinks.

    Args:
        link_path: Path to the directory symlink
        deep: If True, recursively explode subdirectories
    """
    if not link_path.is_symlink():
        print(f"Error: {link_path} is not a symlink", file=sys.stderr)
        sys.exit(1)

    target = link_path.resolve()

    if not target.is_dir():
        print(f"Error: {link_path} does not point to a directory", file=sys.stderr)
        sys.exit(1)

    print(f"Exploding: {link_path}")
    print(f"  Target: {target}")
    print()

    # Get list of items in target directory
    items = list(target.iterdir())

    if not items:
        print("Warning: Target directory is empty")
        return

    # Remove the directory symlink
    link_path.unlink()
    print(f"Removed symlink: {link_path}")

    # Create real directory
    link_path.mkdir()
    print(f"Created directory: {link_path}")
    print()

    # Create individual symlinks
    for item in items:
        item_link = link_path / item.name

        if deep and item.is_dir():
            # In deep mode, recurse into directories
            item_link.symlink_to(item)
            print(f"Created: {item_link} -> {item}")
            # Note: We create symlink first, then could recursively explode
            # But for now, deep mode just symlinks directories as-is
        else:
            # Create symlink to item
            item_link.symlink_to(item)
            print(f"Created: {item_link} -> {item}")

    print()
    print("Done! Directory exploded into individual symlinks.")


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Explode a directory symlink into individual symlinks')
    parser.add_argument('path', help='Path to directory symlink to explode')
    parser.add_argument('--deep', action='store_true',
                       help='Recursively explode subdirectories (not implemented)')
    args = parser.parse_args()

    link_path = Path(args.path)

    if not link_path.exists():
        print(f"Error: {link_path} does not exist", file=sys.stderr)
        sys.exit(1)

    if args.deep:
        print("Warning: --deep mode not yet implemented, using shallow mode", file=sys.stderr)

    explode_directory(link_path, deep=False)


if __name__ == '__main__':
    main()

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
    if not dir_path.exists():
        print(f"Error: {dir_path} does not exist", file=sys.stderr)
        sys.exit(1)

    # Case 1: Already a symlink - nothing to do
    if dir_path.is_symlink():
        target = dir_path.resolve()
        print(f"{dir_path} is already a directory symlink to {target}")
        return

    # Case 2: Real directory - check if safe to implode
    if not dir_path.is_dir():
        print(f"Error: {dir_path} is not a directory", file=sys.stderr)
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

    # Filter out nix-store symlinks (managed by home-manager)
    non_nix_items = [item for item in items if not str(item.resolve()).startswith('/nix/store')]

    if not non_nix_items:
        print("Error: All symlinks point to /nix/store (nothing to implode)", file=sys.stderr)
        sys.exit(1)

    nix_items = len(items) - len(non_nix_items)
    if nix_items > 0:
        print(f"Note: Ignoring {nix_items} nix-store symlink(s) (home-manager managed)")

    # Find common parent (using only non-nix symlinks)
    parents = set()
    for item in non_nix_items:
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

    # Remove all non-nix symlinks
    for item in non_nix_items:
        item.unlink()
        print(f"Removed: {item}")

    # Also remove nix-store symlinks (they'll be recreated by home-manager)
    for item in items:
        if item.exists() or item.is_symlink():  # Still exists
            item.unlink()
            print(f"Removed (nix-store): {item}")

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

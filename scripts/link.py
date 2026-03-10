#!/usr/bin/env python3
"""
link.py - Manage dotfile symlinks from ~/system/dotfiles to ~/.config

This script walks dotfiles/hosts/$hostname/ and creates symlinks in ~/.config/.
It tracks all created symlinks in a manifest file for cleanup and updates.

Usage:
    dot link [--dry-run] [--hostname HOSTNAME]
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, Set, Optional
import socket


def get_hostname() -> str:
    """Get the current hostname."""
    return socket.gethostname()


def resolve_system_root() -> Path:
    """Find the ~/system directory."""
    script_dir = Path(__file__).resolve().parent
    return script_dir.parent


def load_manifest(manifest_path: Path) -> Dict[str, str]:
    """Load the symlink manifest."""
    if not manifest_path.exists():
        return {}

    try:
        with open(manifest_path, 'r') as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError) as e:
        print(f"Warning: Failed to load manifest: {e}", file=sys.stderr)
        return {}


def save_manifest(manifest_path: Path, manifest: Dict[str, str]) -> None:
    """Save the symlink manifest."""
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2, sort_keys=True)


def walk_dotfiles(host_dir: Path, system_root: Path) -> Dict[str, str]:
    """
    Walk the host dotfiles directory and build a mapping of:
        ~/.config/path -> target_path

    For symlinks in host dir: resolve to absolute path in system_root
    For real files: use the host file path
    For directories: recurse (don't symlink directory itself)
    """
    # Files to ignore (system metadata, etc.)
    IGNORE_FILES = {'.DS_Store', '.localized', 'Thumbs.db', 'desktop.ini'}

    symlinks = {}

    if not host_dir.exists():
        return symlinks

    for root, dirs, files in os.walk(host_dir):
        root_path = Path(root)
        rel_from_host = root_path.relative_to(host_dir)

        # Process files in this directory
        for name in files:
            # Skip system metadata files
            if name in IGNORE_FILES:
                continue
            item_path = root_path / name
            config_path = Path.home() / '.config' / rel_from_host / name

            if item_path.is_symlink():
                # Resolve symlink to absolute path
                target = item_path.resolve()
                if not target.is_relative_to(system_root):
                    print(f"Warning: Symlink {item_path} points outside system root, using as-is")
                symlinks[str(config_path)] = str(target)
            else:
                # Real file - link to it
                symlinks[str(config_path)] = str(item_path)

        # Check for symlinked directories (should be treated as leaf nodes)
        # Also filter out system directories
        IGNORE_DIRS = {'.git', '__pycache__', '.pytest_cache', 'node_modules', 'homedir'}
        for name in list(dirs):
            # Skip system directories
            if name in IGNORE_DIRS:
                dirs.remove(name)
                continue

            item_path = root_path / name
            if item_path.is_symlink():
                # This is a symlinked directory - create symlink and don't recurse
                config_path = Path.home() / '.config' / rel_from_host / name
                target = item_path.resolve()
                symlinks[str(config_path)] = str(target)
                # Remove from dirs so os.walk doesn't descend into it
                dirs.remove(name)

    return symlinks


def walk_homedir(homedir_path: Path, system_root: Path) -> Dict[str, str]:
    """
    Walk host_dir/homedir/ and build a mapping of:
        ~/path -> target_path
    Same rules as walk_dotfiles but targets $HOME instead of ~/.config.
    """
    IGNORE_FILES = {'.DS_Store', '.localized', 'Thumbs.db', 'desktop.ini'}
    IGNORE_DIRS = {'.git', '__pycache__', '.pytest_cache', 'node_modules'}
    symlinks = {}

    if not homedir_path.exists():
        return symlinks

    for root, dirs, files in os.walk(homedir_path):
        root_path = Path(root)
        rel = root_path.relative_to(homedir_path)

        for name in files:
            if name in IGNORE_FILES:
                continue
            item_path = root_path / name
            home_path = Path.home() / rel / name
            if item_path.is_symlink():
                target = item_path.resolve()
                if not target.is_relative_to(system_root):
                    print(f"Warning: Symlink {item_path} points outside system root, using as-is")
                symlinks[str(home_path)] = str(target)
            else:
                symlinks[str(home_path)] = str(item_path)

        for name in list(dirs):
            if name in IGNORE_DIRS:
                dirs.remove(name)
                continue
            item_path = root_path / name
            if item_path.is_symlink():
                home_path = Path.home() / rel / name
                symlinks[str(home_path)] = str(item_path.resolve())
                dirs.remove(name)

    return symlinks


def create_symlink(link_path: Path, target_path: Path, dry_run: bool = False) -> bool:
    """
    Create a symlink from link_path -> target_path.
    Returns True if successful, False otherwise.
    """
    if dry_run:
        print(f"Would create: {link_path} -> {target_path}")
        return True

    # Check if link already exists and points to correct target
    if link_path.is_symlink():
        if link_path.resolve() == target_path:
            return True
        else:
            print(f"Updating: {link_path} -> {target_path}")
            link_path.unlink()
    elif link_path.exists():
        print(f"Error: {link_path} exists but is not a symlink. Skipping.", file=sys.stderr)
        return False

    # Create parent directories
    link_path.parent.mkdir(parents=True, exist_ok=True)

    # Create symlink
    try:
        link_path.symlink_to(target_path)
        print(f"Created: {link_path} -> {target_path}")
        return True
    except OSError as e:
        print(f"Error creating symlink {link_path}: {e}", file=sys.stderr)
        return False


def remove_symlink(link_path: Path, dry_run: bool = False) -> None:
    """Remove a symlink if it exists."""
    if not Path(link_path).exists() and not Path(link_path).is_symlink():
        return

    if dry_run:
        print(f"Would remove: {link_path}")
        return

    try:
        Path(link_path).unlink()
        print(f"Removed: {link_path}")
    except OSError as e:
        print(f"Error removing {link_path}: {e}", file=sys.stderr)


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Manage dotfile symlinks')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done')
    parser.add_argument('--hostname', help='Override hostname detection')
    args = parser.parse_args()

    hostname = args.hostname or get_hostname()
    system_root = resolve_system_root()
    host_dir = system_root / 'dotfiles' / 'hosts' / hostname
    manifest_path = Path.home() / '.config' / 'dotfiles.json'

    print(f"System root: {system_root}")
    print(f"Hostname: {hostname}")
    print(f"Host dotfiles: {host_dir}")
    print()

    if not host_dir.exists():
        print(f"Error: Host directory {host_dir} does not exist.", file=sys.stderr)
        print("Create it with symlinks to core dotfiles first.", file=sys.stderr)
        sys.exit(1)

    # Load existing manifest
    old_manifest = load_manifest(manifest_path)

    # Walk dotfiles and build desired state
    new_manifest = walk_dotfiles(host_dir, system_root)

    # Also handle homedir/ -> $HOME symlinks if present
    homedir_path = host_dir / 'homedir'
    if homedir_path.exists():
        print(f"Home directory dotfiles: {homedir_path}")
        new_manifest.update(walk_homedir(homedir_path, system_root))

    # Find diffs
    old_links = set(old_manifest.keys())
    new_links = set(new_manifest.keys())

    to_remove = old_links - new_links
    to_create = new_links - old_links
    to_update = {link for link in old_links & new_links
                 if old_manifest[link] != new_manifest[link]}

    # Report
    if to_remove:
        print(f"Removing {len(to_remove)} stale symlinks...")
        for link in sorted(to_remove):
            remove_symlink(Path(link), args.dry_run)
        print()

    if to_update:
        print(f"Updating {len(to_update)} changed symlinks...")
        for link in sorted(to_update):
            create_symlink(Path(link), Path(new_manifest[link]), args.dry_run)
        print()

    if to_create:
        print(f"Creating {len(to_create)} new symlinks...")
        for link in sorted(to_create):
            create_symlink(Path(link), Path(new_manifest[link]), args.dry_run)
        print()

    if not (to_remove or to_update or to_create):
        print("No changes needed.")

    # Save manifest
    if not args.dry_run:
        save_manifest(manifest_path, new_manifest)
        print(f"\nManifest saved to {manifest_path}")


if __name__ == '__main__':
    main()

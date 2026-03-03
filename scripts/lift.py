#!/usr/bin/env python3
"""
lift.py - Migrate existing configs from ~/.config into dotfiles structure

Interactive script to move files from ~/.config into ~/system/dotfiles,
with option to share to core or keep host-specific.

Usage:
    dot lift <path-in-config>

Example:
    dot lift ~/.config/bat
"""

import shutil
import socket
import sys
from pathlib import Path


def get_hostname() -> str:
    """Get the current hostname."""
    return socket.gethostname()


def resolve_system_root() -> Path:
    """Find the ~/system directory."""
    script_dir = Path(__file__).resolve().parent
    return script_dir.parent


def lift_config(config_path: Path, system_root: Path, hostname: str) -> None:
    """
    Migrate a config from ~/.config into dotfiles structure.

    Args:
        config_path: Path in ~/.config to migrate
        system_root: Path to ~/system
        hostname: Current hostname
    """
    if not config_path.exists():
        print(f"Error: {config_path} does not exist", file=sys.stderr)
        sys.exit(1)

    # Get relative path from ~/.config
    config_dir = Path.home() / '.config'
    try:
        rel_path = config_path.relative_to(config_dir)
    except ValueError:
        print(f"Error: {config_path} is not in ~/.config", file=sys.stderr)
        sys.exit(1)

    print(f"Lifting: {config_path}")
    print(f"Relative path: {rel_path}")
    print()

    # Ask user: core or host-specific?
    while True:
        choice = input("Share to [c]ore or keep [h]ost-specific? [c/h]: ").strip().lower()
        if choice in ('c', 'core'):
            target_base = system_root / 'dotfiles' / 'core'
            break
        elif choice in ('h', 'host'):
            target_base = system_root / 'dotfiles' / 'hosts' / hostname
            break
        else:
            print("Invalid choice. Please enter 'c' for core or 'h' for host.")

    target_path = target_base / rel_path

    print()
    print(f"Target: {target_path}")

    if target_path.exists():
        print(f"Warning: Target already exists at {target_path}")
        overwrite = input("Overwrite? [y/N]: ").strip().lower()
        if overwrite != 'y':
            print("Aborted.")
            sys.exit(0)

    # Create parent directory
    target_path.parent.mkdir(parents=True, exist_ok=True)

    # Move the file/directory
    if config_path.is_symlink():
        print(f"Note: {config_path} is already a symlink, copying target instead")
        resolved = config_path.resolve()
        if resolved.is_dir():
            shutil.copytree(resolved, target_path, symlinks=True)
        else:
            shutil.copy2(resolved, target_path)
        config_path.unlink()
    else:
        shutil.move(str(config_path), str(target_path))

    print(f"Moved: {config_path} -> {target_path}")

    # Create symlink back
    config_path.symlink_to(target_path)
    print(f"Created symlink: {config_path} -> {target_path}")

    print()
    print("Done! Config lifted and symlinked.")
    print("Run `dot link` or rebuild to update manifest.")


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Lift config from ~/.config into dotfiles')
    parser.add_argument('path', help='Path in ~/.config to migrate')
    args = parser.parse_args()

    config_path = Path(args.path).expanduser()
    system_root = resolve_system_root()
    hostname = get_hostname()

    lift_config(config_path, system_root, hostname)


if __name__ == '__main__':
    main()

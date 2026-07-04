#!/usr/bin/env python3
"""
use.py - Spread a core dotfile across host directories

Symlinks a file or directory in dotfiles/core/ into one or more
dotfiles/hosts/<host>/ directories, so `dot link` can pick it up per host.

Usage:
    dot use <name> <host> [<host> ...] [--dry-run] [--force]

Example:
    dot use doom j-bakotsu-mbp j-oni-mbp CGGK727W04
"""

import sys
from pathlib import Path


def resolve_system_root() -> Path:
    """Find the ~/system directory."""
    return Path(__file__).resolve().parent.parent


def spread_one(host_dir: Path, name: str, dry_run: bool, force: bool) -> bool:
    """
    Create host_dir/<name> -> ../../core/<name> (relative, matching existing links).
    Returns True on success (or already correct), False on error.
    """
    link_path = host_dir / name
    rel_target = Path("../../core") / name  # relative link target
    resolved = (link_path.parent / rel_target).resolve()

    if link_path.is_symlink():
        if link_path.resolve() == resolved:
            print(f"Exists:  {link_path} -> {rel_target}")
            return True
        if not force:
            print(f"Error:   {link_path} points elsewhere ({link_path.resolve()}). "
                  f"Use --force to replace.", file=sys.stderr)
            return False
        if not dry_run:
            link_path.unlink()
    elif link_path.exists():
        print(f"Error:   {link_path} exists and is not a symlink. Skipping.", file=sys.stderr)
        return False

    if dry_run:
        print(f"Would link: {link_path} -> {rel_target}")
        return True

    host_dir.mkdir(parents=True, exist_ok=True)
    try:
        link_path.symlink_to(rel_target)
        print(f"Created: {link_path} -> {rel_target}")
        return True
    except OSError as e:
        print(f"Error creating symlink {link_path}: {e}", file=sys.stderr)
        return False


def main():
    import argparse

    parser = argparse.ArgumentParser(
        prog="dot use",
        description="Spread a core dotfile into one or more host directories",
    )
    parser.add_argument("name", help="Name under dotfiles/core/ (e.g. doom)")
    parser.add_argument("hosts", nargs="+", help="Host directory names")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be done")
    parser.add_argument("--force", action="store_true",
                        help="Replace an existing symlink pointing elsewhere")
    args = parser.parse_args()

    system_root = resolve_system_root()
    core_path = system_root / "dotfiles" / "core" / args.name
    hosts_root = system_root / "dotfiles" / "hosts"

    if not core_path.exists():
        print(f"Error: {core_path} does not exist.", file=sys.stderr)
        available = sorted(p.name for p in (system_root / "dotfiles" / "core").iterdir()
                           if not p.name.startswith("."))
        print(f"Available in core/: {', '.join(available)}", file=sys.stderr)
        sys.exit(1)

    ok = True
    for host in args.hosts:
        if not (hosts_root / host).exists():
            print(f"Creating new host directory: {host}")
        ok = spread_one(hosts_root / host, args.name, args.dry_run, args.force) and ok

    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
use.py - Link a source into per-host manifest directories

Symlinks a repo source into one or more hosts/<host>/ manifest dirs as
relative symlinks, so `dot link` can materialize them per host. The manifest
dir mirrors $HOME: an entry at hosts/<host>/<relpath> becomes ~/<relpath>.

<src> is a path relative to the repo root. Two modes:

  Manifest mode: <src> is a directory containing links.json. Every rule is
  applied to each host. A rule's src is relative to the manifest dir and may
  be a glob; its dest is relative to $HOME. A glob src or a trailing "/" on
  dest means dest is a directory: each matched item is linked individually
  as dest/<basename> (keeps merge points like ~/.claude/skills/ real dirs).

  Identity mode: <src> is under dotfiles/ (a literal $HOME mirror), so dest
  is the src path minus the "dotfiles/" prefix. <src> may be a glob, quoted
  so the shell passes it through.

Usage:
    dot use <src> <host> [<host> ...] [--dry-run] [--force]

Examples:
    dot use dotfiles/.config/nvim j-bakotsu-mbp j-oni-mbp
    dot use 'dotfiles/.config/*' j-oni-mbp
    dot use ai j-oni-mbp
"""

import json
import os
import sys
from pathlib import Path
from typing import List, Tuple

GLOB_CHARS = set("*?[")


class UseError(Exception):
    """A planning error with a message for the user."""


def resolve_system_root() -> Path:
    """Find the ~/system directory."""
    return Path(__file__).resolve().parent.parent


def is_glob(pattern: str) -> bool:
    return any(ch in GLOB_CHARS for ch in pattern)


def normalize_src(system_root: Path, src_arg: str) -> str:
    """Return src as a path relative to system_root, or raise UseError."""
    src = Path(src_arg)
    if not src.is_absolute():
        return str(src)
    try:
        return str(src.relative_to(system_root))
    except ValueError:
        raise UseError(f"{src_arg} is outside the repo ({system_root})")


def check_dest(dest: str) -> Path:
    """Validate a manifest dest (relative to $HOME, no escapes)."""
    dest_path = Path(dest)
    if dest_path.is_absolute() or ".." in dest_path.parts:
        raise UseError(f"dest {dest!r} must be relative to $HOME without '..'")
    return dest_path


def plan_manifest_links(manifest_dir: Path) -> List[Tuple[Path, Path]]:
    """
    Read manifest_dir/links.json and return (src_abs, dest_relpath) pairs.
    dest_relpath is relative to $HOME (i.e. to hosts/<host>/).
    """
    manifest_path = manifest_dir / "links.json"
    try:
        rules = json.loads(manifest_path.read_text())["links"]
        pairs = []
        for rule in rules:
            src, dest = rule["src"], rule["dest"]
            dest_path = check_dest(dest)
            per_item = is_glob(src) or dest.endswith("/")
            matches = (sorted(manifest_dir.glob(src)) if is_glob(src)
                       else [manifest_dir / src])
            if not matches or not all(m.exists() for m in matches):
                raise UseError(f"{manifest_path}: src {src!r} matches nothing")
            if per_item:
                pairs.extend((m, dest_path / m.name) for m in matches)
            else:
                pairs.append((matches[0], dest_path))
        return pairs
    except (json.JSONDecodeError, KeyError, TypeError) as e:
        raise UseError(f"invalid manifest {manifest_path}: {e!r}")


def plan_identity_links(system_root: Path, src_rel: str) -> List[Tuple[Path, Path]]:
    """
    Mirror a dotfiles/ source: dest = src path minus the 'dotfiles/' prefix.
    src_rel may be a glob. Returns (src_abs, dest_relpath) pairs.
    """
    matches = (sorted(system_root.glob(src_rel)) if is_glob(src_rel)
               else [system_root / src_rel])
    if not matches:
        raise UseError(f"no matches for {src_rel!r} under {system_root}")

    dotfiles_root = system_root / "dotfiles"
    pairs = []
    for src_abs in matches:
        try:
            dest = src_abs.relative_to(dotfiles_root)
        except ValueError:
            raise UseError(
                f"{src_abs} has no links.json and is not under dotfiles/; "
                f"cannot infer a destination")
        if dest == Path("."):
            raise UseError("dotfiles/ itself cannot be linked; pick an entry inside it")
        pairs.append((src_abs, dest))
    return pairs


def plan_links(system_root: Path, src_arg: str) -> List[Tuple[Path, Path]]:
    """Choose manifest vs identity mode and return (src_abs, dest_relpath) pairs."""
    src_rel = normalize_src(system_root, src_arg)
    if not is_glob(src_rel):
        src_path = system_root / src_rel
        if not src_path.exists():
            raise UseError(f"{src_path} does not exist")
        if src_path.is_dir() and (src_path / "links.json").is_file():
            return plan_manifest_links(src_path)
    return plan_identity_links(system_root, src_rel)


def link_one(src_abs: Path, link_path: Path, dry_run: bool, force: bool) -> bool:
    """
    Create link_path as a relative symlink to src_abs.
    Returns True on success (or already correct), False on error.
    """
    rel_target = Path(os.path.relpath(src_abs, link_path.parent))

    if link_path.is_symlink():
        if link_path.resolve() == src_abs.resolve():
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

    link_path.parent.mkdir(parents=True, exist_ok=True)
    try:
        link_path.symlink_to(rel_target)
        print(f"Created: {link_path} -> {rel_target}")
        return True
    except OSError as e:
        print(f"Error creating symlink {link_path}: {e}", file=sys.stderr)
        return False


def use(src_arg: str, hosts: List[str], system_root: Path, hosts_root: Path,
        dry_run: bool = False, force: bool = False) -> bool:
    """Link src_arg into each host manifest dir. Returns True if all succeed."""
    try:
        pairs = plan_links(system_root, src_arg)
    except UseError as e:
        print(f"Error: {e}", file=sys.stderr)
        return False

    ok = True
    for host in hosts:
        if not (hosts_root / host).exists():
            print(f"Creating new host directory: {host}")
        for src_abs, dest_rel in pairs:
            ok = link_one(src_abs, hosts_root / host / dest_rel, dry_run, force) and ok
    return ok


def main():
    import argparse

    parser = argparse.ArgumentParser(
        prog="dot use",
        description="Link a repo source into one or more host manifest directories",
    )
    parser.add_argument("src", help="Path relative to the repo root: a dir with "
                                    "links.json, or an entry under dotfiles/ "
                                    "(may be a quoted glob)")
    parser.add_argument("hosts", nargs="+", help="Host directory names")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be done")
    parser.add_argument("--force", action="store_true",
                        help="Replace an existing symlink pointing elsewhere")
    args = parser.parse_args()

    system_root = resolve_system_root()
    hosts_root = system_root / "hosts"
    sys.exit(0 if use(args.src, args.hosts, system_root, hosts_root,
                      args.dry_run, args.force) else 1)


if __name__ == "__main__":
    main()

# AGENTS

This repo is a multi-system configuration including plain dotfiles and nix setup
with homedir.

## Environments

### Personal Computers

j-bakotsu-mbp and j-oni-mbp are personal computers with no restrictions.

### Work Computers

CGGK727W04 is my work computer, there are a lot of restrictions in what can be
installed and used. Most cloud based tools, non open-source software is
prohibited except for Obsidian. sf-cloud-ws refers to cloud workspaces deployed
to AWS. These are even more limited as they run RockyOS and can't run GUIs. Non
open-source software is also prohibited.

## Conventions

### Nix

Nix is the preferred system for configuration

### Dotfiles

Sometimes it does not make sense to use nix if a package or home-manager module
does not exist or I want the config to remain readily editable without requiring
a nix rebuild. For example, I want most of my neovim to be regular fennel files
I can quickly edit, eval, and reload.

The core directory contains the actual dotfile sources. The hosts directory
contains symlinks to the core files that are desired in that environment but may
contain one-off overrides for that host.

## Guidelines

- Prefer nix over dotfiles
- Make sure a home-manager module does not exist when considering dotfiles

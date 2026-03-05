#!/usr/bin/env python3
"""
Configure git settings for the system repository.
Sets up SSH commit signing and user information at the repository level.
"""

import os
import subprocess
import sys
from pathlib import Path


def run_git_config(key, value=None, check=False):
		"""Run git config command. If check=True, only check if value matches."""
		try:
				if check and value:
						result = subprocess.run(
								["git", "config", "--local", "--get", key],
								capture_output=True,
								text=True,
								check=False
						)
						current_value = result.stdout.strip()
						return current_value == value
				elif check:
						result = subprocess.run(
								["git", "config", "--local", "--get", key],
								capture_output=True,
								text=True,
								check=False
						)
						return result.returncode == 0
				else:
						subprocess.run(
								["git", "config", "--local", key, value],
								check=True,
								capture_output=True
						)
						return True
		except subprocess.CalledProcessError as e:
				print(f"Error setting {key}: {e}", file=sys.stderr)
				return False


def setup_git_config():
		"""Set up git configuration for the repository."""
		home = Path.home()
		ssh_key = home / ".ssh" / "id_ed_personal.pub"

		# User owned machine, changes not likely necessary
		if os.getenv('USER') == "j":
			print("User-owned machine, skipping git config check")
			return 0

		# Check if we're in a git repository
		try:
				subprocess.run(
						["git", "rev-parse", "--git-dir"],
						check=True,
						capture_output=True
				)
		except subprocess.CalledProcessError:
				print("Not in a git repository", file=sys.stderr)
				return 1

		# Configuration to set
		configs = {
				"user.name": "jaide",
				"user.email": "jayzawrotny@gmail.com",
				"core.sshCommand": f"/usr/bin/ssh -i {home}/.ssh/id_ed_personal",
				"gpg.format": "ssh",
				"user.signingkey": str(ssh_key),
				"commit.gpgsign": "true",
				"gpg.ssh.allowedSignersFile": str(home / ".ssh" / "allowed_signers"),
		}

		changes_made = False

		for key, value in configs.items():
				if not run_git_config(key, value, check=True):
						print(f"Setting {key} = {value}")
						if run_git_config(key, value):
								changes_made = True

		if not changes_made:
				print("Git config already up to date")

		return 0


if __name__ == "__main__":
		sys.exit(setup_git_config())

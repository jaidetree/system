#!/usr/bin/env fish
# Source this script to temporarily use personal git identity and SSH key.
# Useful for cloning repos outside of work organizations on work machines.
#
# Usage:
#   source scripts/personal-git-env.fish          # activate
#   source scripts/personal-git-env.fish --unset  # deactivate

if test (count $argv) -gt 0; and test $argv[1] = "--unset"
    set -e GIT_SSH_COMMAND
    set -e GIT_AUTHOR_NAME
    set -e GIT_AUTHOR_EMAIL
    set -e GIT_COMMITTER_NAME
    set -e GIT_COMMITTER_EMAIL
    set -e GIT_CONFIG_COUNT
    set -e GIT_CONFIG_KEY_0
    set -e GIT_CONFIG_VALUE_0
    set -e GIT_CONFIG_KEY_1
    set -e GIT_CONFIG_VALUE_1
    set -e GIT_CONFIG_KEY_2
    set -e GIT_CONFIG_VALUE_2
    set -e GIT_CONFIG_KEY_3
    set -e GIT_CONFIG_VALUE_3
    echo "Personal git env cleared"
    return 0
end

# Override core.sshCommand to use personal key instead of work SSH wrapper
set -gx GIT_SSH_COMMAND "/usr/bin/ssh -i $HOME/.ssh/id_ed_personal"

# Override author/committer identity
set -gx GIT_AUTHOR_NAME "jaide"
set -gx GIT_AUTHOR_EMAIL "jayzawrotny@gmail.com"
set -gx GIT_COMMITTER_NAME "jaide"
set -gx GIT_COMMITTER_EMAIL "jayzawrotny@gmail.com"

# SSH commit signing via GIT_CONFIG_* (requires git 2.32+)
# These override config files, equivalent to passing -c key=value on the CLI
set -gx GIT_CONFIG_COUNT 4
set -gx GIT_CONFIG_KEY_0 "gpg.format"
set -gx GIT_CONFIG_VALUE_0 "ssh"
set -gx GIT_CONFIG_KEY_1 "user.signingkey"
set -gx GIT_CONFIG_VALUE_1 "$HOME/.ssh/id_ed_personal.pub"
set -gx GIT_CONFIG_KEY_2 "commit.gpgsign"
set -gx GIT_CONFIG_VALUE_2 "true"
set -gx GIT_CONFIG_KEY_3 "gpg.ssh.allowedSignersFile"
set -gx GIT_CONFIG_VALUE_3 "$HOME/.ssh/allowed_signers"

echo "Personal git env set (SSH key: $HOME/.ssh/id_ed_personal)"
echo "Run 'source scripts/personal-git-env.fish --unset' to restore defaults"

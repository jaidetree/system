---
name: add-nix-github-module
description: >-
  Add a home-manager nix module that pins a GitHub repo and links or runs its
  contents. Use when the user wants to fetch a GitHub repo into their nix config,
  link files or tools from a GitHub repo via home-manager, or add a new module
  to nix/modules/home-manager/personal/.
---

# Add Nix GitHub Module

Pin a GitHub repo into home-manager: fetch it, link files or run scripts from it.

## Branches

Two patterns — choose before writing any code:

- **fetchFromGitHub** — self-contained module, no flake changes. Needs a `sha256`.
  Use when the module is standalone and the repo doesn't need to share a lockfile
  version with other inputs.
- **Flake input** — adds an entry to `flake.nix` inputs, tracked in `flake.lock`.
  Use when the repo ships a script that drives the activation, or must share a
  version with another input.

Prefer **fetchFromGitHub** unless the repo must be referenced by a script that
ships with it, or must share a lockfile version with another flake input.

## Steps

### 1. Gather

Collect from the user or args:
- GitHub `owner` and `repo`
- `rev`: a commit SHA or tag. If unknown, run:
  `gh api repos/<owner>/<repo>/commits/HEAD --jq .sha`
- Which files or dirs to link, and their destination paths under `$HOME`
- Whether a post-link activation script is needed
- Module name (default: `<repo>.nix`)

If the repo is unfamiliar, inspect it with:
```
gh api repos/<owner>/<repo>/contents --jq '.[].name'
gh api repos/<owner>/<repo>/contents/<file> --jq '.content' | base64 -d
```

### 2. Choose pattern

If not clear from the user's description, ask which branch to use (see above).

### 3. Get sha256 (fetchFromGitHub branch only)

Run both commands — the first fetches and outputs a base32 hash, the second converts it to the base64 format nix expects:
```
nix-prefetch-url --unpack "https://github.com/<owner>/<repo>/archive/<rev>.tar.gz" 2>/dev/null
nix hash convert --hash-algo sha256 --to base64 <base32-hash>
```

If `nix-prefetch-url` is unavailable, use `lib.fakeHash` as a placeholder — the
build error will print the correct hash to substitute in.

### 4. Write the module

Place at: `nix/modules/home-manager/personal/<module-name>.nix`

This directory is auto-imported for personal machines — no further wiring needed.

**fetchFromGitHub template:**
```nix
{ pkgs, lib, ... }:
let
  src = pkgs.fetchFromGitHub {
    owner = "<owner>";
    repo = "<repo>";
    rev = "<rev>";
    sha256 = "<sha256>";
  };
in
{
  home.file."<dest-path>" = {
    source = "${src}/<source-path>";
    # executable = true;
  };

  # Uncomment if a post-link script is needed:
  # home.activation.<name> = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #   <commands>
  # '';
}
```

**Flake input template:**
```nix
{ inputs, pkgs, lib, ... }:
{
  home.activation.<module-name> = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.bash}/bin/bash ${inputs.<input-name>}/<script-path>
  '';
}
```

### 5. Add flake input (flake input branch only)

In `nix/flake.nix`, add to the `inputs` block:
```nix
<input-name> = { url = "github:<owner>/<repo>/<rev>"; flake = false; };
```

`inputs` is already passed to all home-manager modules via `home-manager.extraSpecialArgs`.

Git-stage the change before verifying — nix flakes only read tracked files.

### 6. Verify

Run `nix/rebuild.sh` or `nix flake check`.

If the build fails with a hash mismatch, replace `sha256` with the correct value
from the error output and re-run.

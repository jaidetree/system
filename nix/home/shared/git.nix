{
  enable = true;

  ignores = [
    ".DS_Store"
    ".envrc"
    ".cache"
    ".shadow-cljs"
    ".direnv"
    "*.swp"
    "*.swo"
    "*~"
    "node_modules"
    "**/*.private.*"
    "**/*.secret.*"
    "**/*.j.*"
  ];

  lfs.enable = true;

  # See https://blog.gitbutler.com/how-git-core-devs-configure-git/ as a guide
  settings = {
    alias = {
      co = "checkout --ignore-other-worktrees";
    };

    init.defaultBranch = "main";

    branch = {
      autoSetupMerge = "simple";
      sort = "-committerdate";
    };

    checkout = {
      defaultRemote = "current";
      ignoreOtherWorktrees = true;
    };

    commit = {
      verbose = true;
    };

    column.ui = "auto";

    diff = {
      algorithm = "histogram";
      colorMoved = "plain";
      mnemonicPrefix = true;
      renames = true;
    };

    fetch = {
      prune = true;
      pruneTags = true;
      all = true;
    };

    help.autocorrect = "prompt";

    merge.conflictstyle = "zdiff3";

    pull = {
      default = "current";
      rebase = true;
    };

    push = {
      default = "current";
      autoSetupRemote = true;
      followTags = true;
    };

    rebase = {
      autoSquash = true;
      autoStash = true;
      updateRefs = true;
    };

    rerere = {
      enabled = true;
      autoupdate = true;
    };

    tag = {
      sort = "version:refname";
    };

    # Filters

    "filter \"media\"" = {
      required = true;
      clean = "git media clean %f";
      smudge = "git media smudge %f";
    };

    "filter \"lfs\"" = {
      required = true;
      clean = "git-lfs clean %f";
      smudge = "git-lfs smudge %f";
      process = "git-lfs filter-process";
    };
  };
}

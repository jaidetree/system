{ pkgs, ... }:
{
  home.packages = [
    pkgs.gh
  ];

  programs.lazygit.enable = true;

  programs.git = {
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

    signing = {
      signByDefault = true;
      key = "3195AC4CF81866EA95A5D66C6BF5C081A9500AF1";
      signer = "/Applications/Beyond Identity.app/Contents/MacOS/gpg-bi";
    };

    # See https://blog.gitbutler.com/how-git-core-devs-configure-git/ as a guide
    settings = {
      user.name = "Jay Zawrotny";
      user.email = "jay.zawrotny@snowflake.com";

      core = {
        editor = "nvim";
        sshCommand = "/usr/local/bin/sf __ssh";
      };

      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };

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

      github = {
        user = "jay-zawrotny_snow";
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
      };

    };
  };
}

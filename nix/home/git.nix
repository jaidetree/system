{ pkgs, ... }:
{
  home.packages = [
    pkgs.gh
  ];

  programs.lazygit.enable = true;

  programs.git = {
    enable = true;
    userName = "jaide";
    userEmail = "jayzawrotny@gmail.com";
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
      key = "/Users/j/.ssh/id_ed25519.pub";
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull = {
	default = "current";
	rebase = true;
      };
      push = {
	default = "current";
	autoSetupRemote = true;
      };
      rebase = {
      	autoStash = true; 
	updateRefs = true;
      };
      branch = {
	autoSetupMerge = "always";
      };
      github = {
	user = "jaidetree";
      };
      gpg.format = "ssh";
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

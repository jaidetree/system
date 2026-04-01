{ ... }: {
  programs.fish = {
    interactiveShellInit = ''
      # Salesforce CLI aliases
      if type -q sf
        sf aliases --fish-shell | source
      end
    '';
  };
}

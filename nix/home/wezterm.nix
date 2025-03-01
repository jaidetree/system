{ pkgs, ... }:
{
  home.packages = [
    pkgs.lua54Packages.fennel
  ];

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local configdir = wezterm.config_dir
      local homedir = wezterm.home_dir

      debug = { traceback = function() end }

      fennel = dofile('${pkgs.lua54Packages.fennel}/share/lua/5.4/fennel.lua')

      wezterm.log_error('Loaded fennel')

      do
        local fnldir = (configdir .. "/fnl")
        for _, dir in ipairs({"/?.fnl", "/?/init.fnl"}) do
          fennel["path"] = (fnldir .. dir .. ";" .. fennel.path)
          fennel["macro-path"] = (fnldir .. dir .. ";" .. fennel["macro-path"])
        end
      end

      fennel.install()

      wezterm.log_error('Installed fennel')

      _G['config-paths'] = {};
      _G['config-paths'].fish = '${pkgs.fish}/bin/fish';

      local config = (require "j.wezterm.config")

      wezterm.log_error('Loaded custom config')

      return config
    '';
  };
}

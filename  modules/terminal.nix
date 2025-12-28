{ config, lib, pkgs, ... }:

{
  options.modules.terminal = {
    enable = lib.mkEnableOption "Enable terminal UX configuration";
  };

  config = lib.mkIf config.modules.terminal.enable {

    programs.bash = {
      enable = true;
      shellAliases = {
        btw = "echo i use nixos btw";
        nrs = "sudo nixos-rebuild switch";
        nf = "neofetch";
        z = "zeditor ."
      };
    };

    home.packages = with pkgs; [
      # Core terminal tools
      bat
      btop
      fzf
      neofetch
      wget
      wl-clipboard
      brightnessctl
      ripgrep
      fd
      jq
      curl
      zip
      unzip
      tree
      eza
    ];
  };
}

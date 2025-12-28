{ config, lib, pkgs, ... }:

{
  options.modules.apps = {
    enable = lib.mkEnableOption "Enable user GUI and utility applications";
  };

  config = lib.mkIf config.modules.apps.enable {

    home.packages = with pkgs; [
      # File + system utilities
      nautilus
      file-roller
      nautilus-python
      qbittorrent
      zathura

      # Media apps
      mpv
      imv

      # Chat / communication
      discord
      spotify

      # Terminal + coding tools
      neovim
      zed-editor
      bat
      btop
      fzf
      neofetch
      wget
    ];
  };
}

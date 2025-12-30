{ config, pkgs, ... }:

{
  home.username = "to_run";
  home.homeDirectory = "/home/to_run";
  home.stateVersion = "24.11";

  home.enableNixpkgsReleaseCheck = false;

  # Import user modules
  imports = [
    ./modules/browser.nix
    ./modules/apps.nix
    ./modules/desktop.nix
    ./modules/services.nix
    ./modules/terminal.nix
    ./modules/webdev.nix
    ./modules/cpp.nix
  ];

  # Enable selected modules
  modules.browser.enable = true;
  modules.apps.enable = true;
  modules.desktop.enable = true;
  modules.services.enable = false;  # currently empty, disable for now
  modules.terminal.enable = true;
  modules.webdev.enable = true;
  modules.cpp.enable = true;
}

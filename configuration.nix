{ config, lib, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";
in
{
  # Imports & Home Manager
  imports = [
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
  ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.to_run = import ./home.nix;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.nixPath = [ "nixos-config=/etc/nixos/configuration.nix" ];

  # Boot & Core System
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  time.timeZone = "Asia/Kolkata";
  nixpkgs.config.allowUnfree = true;

  # Hardware & Performance
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  boot.kernelParams = [
    "i915.enable_dc=4"
    "i915.enable_psr=1"
  ];

  # User Account
  users.users.to_run = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ tree ];
  };

  security.sudo.extraConfig = ''
    Defaults env_keep += "NIX_PATH"
  '';

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  # Power Management
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  services.tlp.enable = true;
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    PLATFORM_PROFILE_ON_BAT = "low-power";
    WIFI_PWR_ON_BAT = "on";
    USB_AUTOSUSPEND = "1";
  };

  # Wayland / Session
  programs.xwayland.enable = true;
  programs.niri.enable = true;
  programs.gtklock.enable = true;

  # lightdm
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    displayManager.sessionCommands = ''
      xwallpaper --zoom ~/rice/wallpapers/2.jpg
    '';
  };

  # Idle & Locking behavior
  systemd.user.services.swayidle = {
    description = "Idle manager for Wayland";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart =
        "${pkgs.swayidle}/bin/swayidle -w before-sleep '${pkgs.gtklock}/bin/gtklock -m ${pkgs.gtklock-powerbar-module}/lib/gtklock/powerbar-module.so'";
      Restart = "on-failure";
    };
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  systemd.services."display-manager".serviceConfig.KillMode = "mixed";

  # Portals
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Applications
  programs.firefox.enable = true;

  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    networkmanager
    bluez
    bluez-tools
    adwaita-icon-theme
    dconf
    glib
    gsettings-desktop-schemas
    papirus-icon-theme
    colloid-gtk-theme
  ];

  # Environment Vars
  environment.sessionVariables = lib.mkForce {
    GTK_THEME = "Colloid-Dark";
    NIX_PATH = "nixos-config=/etc/nixos/configuration.nix";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    XDG_DATA_DIRS = [
      "${pkgs.gsettings-desktop-schemas}/share"
      "${pkgs.glib}/share"
    ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    source-code-pro
    jetbrains-mono
    fira-code
    inter
    noto-fonts-color-emoji
  ];

  # State version
  system.stateVersion = "25.11";
}

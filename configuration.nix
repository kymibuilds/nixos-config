# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.to_run = import ./home.nix;

  nixpkgs.config.allowUnfree = true;

  # systemd boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;
  programs.xwayland.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.nixPath = [ "nixos-config=/etc/nixos/configuration.nix" ];

  security.sudo.extraConfig = ''
    Defaults env_keep += "NIX_PATH"
  '';

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

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
  hardware.cpu.intel.updateMicrocode = true;

  boot.kernelParams = [
    "i915.enable_dc=4"
    "i915.enable_psr=1"   # Panel Self Refresh
  ];

  hardware.enableRedistributableFirmware = true;


  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    displayManager.sessionCommands = ''
     xwallpaper --zoom ~/rice/wallpapers/2.jpg
    '';
  };

  programs.niri.enable = true;

  programs.gtklock.enable = true;


  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  systemd.user.services.swayidle = {
    description = "Idle manager for Wayland";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.swayidle}/bin/swayidle -w before-sleep '${pkgs.gtklock}/bin/gtklock -m ${pkgs.gtklock-powerbar-module}/lib/gtklock/powerbar-module.so'";
      Restart = "on-failure";
    };
  };


  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.to_run = {
   isNormalUser = true;
   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
   packages = with pkgs; [
     tree
   ];
  };

  programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
 environment.systemPackages = with pkgs; [
   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
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

 programs.dconf.enable = true;

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

 fonts.packages = with pkgs; [
   source-code-pro
   jetbrains-mono
   noto-fonts-color-emoji
   noto-fonts-monochrome-emoji
 ];

 systemd.services."display-manager".serviceConfig.KillMode = "mixed";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # allowed ports
  networking.firewall.enable = false;

  system.stateVersion = "25.11";
}

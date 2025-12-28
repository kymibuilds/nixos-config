{ config, lib, pkgs, ... }:

{
  options.modules.desktop = {
    enable = lib.mkEnableOption "Enable desktop UI configuration and themes";
  };

  config = lib.mkIf config.modules.desktop.enable {

    # Wayland desktop user packages
    home.packages = with pkgs; [
      waybar
      swww
      papirus-icon-theme
      adwaita-icon-theme
      dconf
      glib
      gsettings-desktop-schemas
    ];

    # Autostart waybar for Niri sessions
    systemd.user.services.waybar = {
      Unit = {
        Description = "Waybar Status Bar";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.waybar}/bin/waybar";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}

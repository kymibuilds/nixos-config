{ config, lib, pkgs, ... }:

{
  options.modules.browser = {
    enable = lib.mkEnableOption "Enable browser configuration";
  };

  config = lib.mkIf config.modules.browser.enable {

    # Wayland browser environment
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    # Browsers installed for user
    home.packages = with pkgs; [
      firefox
      chromium
    ];

    # Firefox Wayland + VAAPI acceleration
    programs.firefox = {
      enable = true;
      profiles.default = {
        settings = {
          "widget.use-xdg-desktop-portal" = 1;
          "media.ffmpeg.vaapi.enabled" = true;
          "gfx.webrender.all" = true;
          "media.navigator.mediadatadecoder_vpx_enabled" = true;
        };
      };
    };

    # Chromium Wayland flags + VAAPI on Intel/AMD
    programs.chromium = {
      enable = true;
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--enable-features=UseOzonePlatform"
        "--enable-features=VaapiVideoDecoder"
        "--disable-features=UseChromeOSDirectVideoDecoder"
      ];
    };
  };
}

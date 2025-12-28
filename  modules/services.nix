{ config, lib, ... }:

{
  options.modules.services = {
    enable = lib.mkEnableOption "Enable user background services";
  };

  config = lib.mkIf config.modules.services.enable {

    # Currently no user services enabled.
    # This file acts as a placeholder for future background daemons.
    # Example: notifications, system monitoring, media hotkeys, etc.

  };
}

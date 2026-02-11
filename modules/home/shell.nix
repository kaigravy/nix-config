{ config, ... }:

let
  configDir = "${config.home.homeDirectory}/${config.home.evict.configDirName}";
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  # Set XDG_CONFIG_HOME for evict's config directory
  home.sessionVariables = {
    XDG_CONFIG_HOME = configDir;
  };

  # Tell systemd where to find user services with evict
  systemd.user.sessionVariables = {
    XDG_CONFIG_HOME = configDir;
  };
}

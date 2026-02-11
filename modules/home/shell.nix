{ config, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  # Set XDG_CONFIG_HOME for evict's config directory
  # This is needed for systemd user services to be found
  home.sessionVariables = {
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/${config.home.evict.configDirName}";
  };
}

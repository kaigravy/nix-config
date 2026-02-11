{ pkgs, config, lib, ... }:

let
  homeDir = "${config.home.homeDirectory}/${config.home.evict.homeDirName}";
  configDir = "${config.home.homeDirectory}/${config.home.evict.configDirName}";

  syncPairs = builtins.toJSON [
    {
      local = "${homeDir}/Desktop";
      remote = "/Desktop";
      syncMode = "twoWay";
    }
    {
      local = "${homeDir}/Documents";
      remote = "/Documents";
      syncMode = "twoWay";
    }
  ];
in
{
  home.packages = [ pkgs.filen-cli ];

  # Write sync pair configuration into evict's config dir
  xdg.configFile."filen-cli/syncPairs.json".text = syncPairs;

  # Symlink authentication config from secrets
  # The symlink will be broken if secret doesn't exist, but service won't start
  xdg.configFile."filen-cli/.filen-cli-auth-config".source = 
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/filen-cli-auth";

  # Persist directories across ephemeral home wipes
  home.persistence."/persist" = {
    directories = [
      "${config.home.evict.homeDirName}/Desktop"
      "${config.home.evict.homeDirName}/Documents"
      "${config.home.evict.homeDirName}/Downloads"
    ];
  };

  # Systemd user service for continuous sync
  systemd.user.services.filen-sync = {
    Unit = {
      Description = "Filen continuous sync";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      # Only start if auth config exists
      # xdg.configFile puts files in XDG_CONFIG_HOME which is configDir
      ConditionPathExists = "${config.xdg.configHome}/filen-cli/.filen-cli-auth-config";
    };

    Service = {
      Type = "simple";
      Environment = [ "XDG_CONFIG_HOME=${configDir}" ];
      ExecStart = "${pkgs.filen-cli}/bin/filen sync --continuous";
      Restart = "on-failure";
      RestartSec = 10;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}

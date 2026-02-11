{ pkgs, config, ... }:

let
  filen-cli = pkgs.callPackage ../../packages/filen-cli.nix { };
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
  home.packages = [ filen-cli ];

  # Write sync pair configuration into evict's config dir
  xdg.configFile."filen-cli/syncPairs.json".text = syncPairs;

  # Persist directories across ephemeral home wipes
  home.persistence."/persist" = {
    directories = [
      "${config.home.evict.homeDirName}/Desktop"
      "${config.home.evict.homeDirName}/Documents"
      "${config.home.evict.homeDirName}/Downloads"
      "${config.home.evict.configDirName}/filen-cli"
    ];
  };

  # Systemd user service for continuous sync
  systemd.user.services.filen-sync = {
    Unit = {
      Description = "Filen continuous sync";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      Environment = [ "XDG_CONFIG_HOME=${configDir}" ];
      ExecStart = "${filen-cli}/bin/filen sync --continuous";
      Restart = "on-failure";
      RestartSec = 10;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}

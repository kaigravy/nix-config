{ inputs, config, lib, ... }:

{
  imports = [
    inputs.evict.homeManagerModules.evict
    ./cli.nix
    ./shell.nix
    ./zsh.nix
    ./fonts.nix
    ./git.nix
    ./filen.nix
    ./emacs.nix
    ./kitty.nix
    ./zen-browser.nix
  ];

  home = {
    username = "kai";
    homeDirectory = "/users/kai";
    stateVersion = "25.11";
    evict = {
      enable = true;
      homeDirName = "home";
      configDirName = "config";
    };
  };

  xdg.userDirs = {
    desktop = lib.mkForce "${config.home.homeDirectory}/${config.home.evict.homeDirName}/Desktop";
    documents = lib.mkForce "${config.home.homeDirectory}/${config.home.evict.homeDirName}/Documents";
    download = lib.mkForce "${config.home.homeDirectory}/${config.home.evict.homeDirName}/Downloads";
  };

  programs.home-manager.enable = true;
}

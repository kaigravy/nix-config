{ pkgs, config, lib, ... }:

let
  # Use the persistent home directory for Doom installation
  homeDir = "${config.home.homeDirectory}/${config.home.evict.homeDirName}";
  doomDir = "${config.home.homeDirectory}/${config.home.evict.configDirName}/doom";
  emacsDir = "${homeDir}/.emacs.d";
in
{
  # Install Emacs
  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk; # Emacs 29 with pure GTK
  };

  # Install dependencies for Doom Emacs
  home.packages = with pkgs; [
    # Core dependencies
    git
    (ripgrep.override { withPCRE2 = true; })
    gnutls
    
    # Optional dependencies
    fd
    imagemagick
    pinentry-emacs
    zstd
    
    # Module dependencies
    nodePackages.stylelint
    nodePackages.js-beautify
    
    # Doom's bin
    emacs-all-the-icons-fonts
  ];

  # Set environment variables so Doom uses persistent locations
  home.sessionVariables = {
    DOOMDIR = doomDir;        # Config location: /users/kai/config/doom
    EMACSDIR = emacsDir;      # Install location: /users/kai/home/.emacs.d
  };

  # Symlink Doom config from this repo to /users/kai/config/doom (via XDG_CONFIG_HOME)
  # This makes your Doom config declarative while letting Doom manage itself
  xdg.configFile."doom" = {
    source = ../../config/emacs/doom;
    recursive = true;
  };

  # Persist Doom Emacs installation and packages in the home directory
  # With evict: config is ephemeral, home is persistent
  home.persistence."/persist/users/kai" = lib.mkIf config.home.evict.enable {
    directories = [
      "home/.emacs.d"  # Doom Emacs itself and installed packages
    ];
    allowOther = true;
  };
}

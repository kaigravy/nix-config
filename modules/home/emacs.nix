{ pkgs, config, lib, ... }:

let
  # Use config directory for both Doom config and installation
  configDir = "${config.home.homeDirectory}/${config.home.evict.configDirName}";
  doomDir = "${configDir}/doom";
  emacsDir = "${configDir}/emacs";
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

  # Set environment variables so Doom uses config locations
  home.sessionVariables = {
    DOOMDIR = doomDir;        # Config location: /users/kai/config/doom
    EMACSDIR = emacsDir;      # Install location: /users/kai/config/emacs
  };

  # Symlink Doom config from this repo to /users/kai/config/doom (via XDG_CONFIG_HOME)
  # This makes your Doom config declarative while letting Doom manage itself
  xdg.configFile."doom" = {
    source = ../../config/emacs/doom;
    recursive = true;
  };

  # Persist Doom Emacs installation and packages
  home.persistence."/persist/users/kai" = lib.mkIf config.home.evict.enable {
    directories = [
      "config/emacs"  # Doom Emacs installation at /users/kai/config/emacs
    ];
  };
}

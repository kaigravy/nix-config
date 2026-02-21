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
    package = pkgs.emacs30-pgtk; # Emacs 30 with pure GTK
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

  # Add Doom's bin to PATH so 'doom sync', 'doom doctor', etc. work from any shell
  home.sessionPath = [ "${emacsDir}/bin" ];

  # Symlink Doom config from this repo to /users/kai/config/doom (via XDG_CONFIG_HOME)
  # This makes your Doom config declarative while letting Doom manage itself
  xdg.configFile."doom" = {
    source = ../../config/emacs/doom;
    recursive = true;
  };

  # Auto-install Doom Emacs on first activation if it isn't already present.
  # Subsequent rebuilds are a no-op (the binary already exists).
  home.activation.installDoom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "${emacsDir}/bin/doom" ]; then
      $VERBOSE_ECHO "Doom Emacs not found at ${emacsDir} — cloning and installing..."
      ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs "${emacsDir}"
      export DOOMDIR="${doomDir}"
      export EMACSDIR="${emacsDir}"
      export PATH="${pkgs.emacs30-pgtk}/bin:${pkgs.git}/bin:$PATH"
      # --no-config: don't overwrite our declarative init.el/config.el/packages.el
      # --no-env:    skip dumping env vars to $DOOMDIR/env (we handle that via Nix)
      "${emacsDir}/bin/doom" install --no-config --no-env
    fi
  '';

  # Persist Doom Emacs installation and packages
  home.persistence."/persist" = lib.mkIf config.home.evict.enable {
    directories = [
      "${config.home.evict.configDirName}/emacs"  # Doom Emacs installation at /users/kai/config/emacs
    ];
  };
}

{ pkgs, config, lib, ... }:

let
  # Use config directory for both Doom config and installation
  configDir = "${config.home.homeDirectory}/${config.home.evict.configDirName}";
  doomDir = "${configDir}/doom";
  emacsDir = "${configDir}/emacs";
in
{
  # Install Emacs as a plain package — do NOT use programs.emacs.enable = true here.
  # When enabled, home-manager writes its own init.el to $XDG_CONFIG_HOME/emacs/init.el,
  # which is the same path as EMACSDIR (/users/kai/config/emacs), overwriting Doom's
  # init.el and causing "void-variable doom-modules" on startup.
  home.packages = with pkgs; [
    emacs30-pgtk # Emacs 30 with pure GTK

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

  # Mirror into systemd user environment so the daemon service sees them too
  # (same pattern used for XDG_CONFIG_HOME in shell.nix)
  systemd.user.sessionVariables = {
    DOOMDIR = doomDir;
    EMACSDIR = emacsDir;
  };

  # Start Emacs as a daemon so emacsclient can connect to it
  services.emacs = {
    enable = true;
    package = pkgs.emacs30-pgtk;
    client.enable = true; # makes emacsclient available and sets EDITOR
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

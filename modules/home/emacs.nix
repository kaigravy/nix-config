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

  # Emacs daemon — written as a raw systemd unit rather than services.emacs because
  # services.emacs.enable = true implicitly sets programs.emacs.enable = mkDefault true,
  # which causes home-manager to write its own init.el over $EMACSDIR/init.el and break Doom.
  systemd.user.services.emacs = {
    Unit = {
      Description = "Emacs daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "notify";
      ExecStart = "${pkgs.emacs30-pgtk}/bin/emacs --fg-daemon";
      ExecStop = "${pkgs.emacs30-pgtk}/bin/emacsclient --no-wait --eval '(kill-emacs)'";
      Restart = "on-failure";
      # Env vars must be set explicitly here; systemd user services don't
      # automatically inherit sessionVariables set by home-manager.
      Environment = [
        "DOOMDIR=${doomDir}"
        "EMACSDIR=${emacsDir}"
        "XDG_CONFIG_HOME=${configDir}"
      ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Run 'doom install' once, asynchronously, the first time the user logs in.
  # This avoids blocking nixos-rebuild activation (which caused timeouts) while
  # still ensuring Doom is fully set up before the daemon tries to use it.
  systemd.user.services.doom-install = {
    Unit = {
      Description = "First-time Doom Emacs package install";
      # Run before the daemon so packages are ready when Emacs starts.
      Before = [ "emacs.service" ];
      # Only run if the Doom binary is missing (i.e. not yet installed).
      ConditionPathExists = "!${emacsDir}/bin/doom";
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${emacsDir}/bin/doom install --no-config --no-env";
      Environment = [
        "DOOMDIR=${doomDir}"
        "EMACSDIR=${emacsDir}"
        "XDG_CONFIG_HOME=${configDir}"
        "PATH=${pkgs.emacs30-pgtk}/bin:${pkgs.git}/bin:/run/current-system/sw/bin"
      ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Add Doom's bin to PATH so 'doom sync', 'doom doctor', etc. work from any shell
  home.sessionPath = [ "${emacsDir}/bin" ];

  # Symlink Doom config from this repo to /users/kai/config/doom (via XDG_CONFIG_HOME)
  # This makes your Doom config declarative while letting Doom manage itself
  xdg.configFile."doom" = {
    source = ../../config/emacs/doom;
    recursive = true;
  };

  # Clone Doom Emacs on first activation if not already present.
  # We do NOT run 'doom install' here — that blocks nixos-rebuild for 10+ minutes
  # while Doom compiles packages. The doom-install.service handles it async on first login.
  home.activation.cloneDoom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "${emacsDir}/.git" ]; then
      $VERBOSE_ECHO "Doom Emacs not found — cloning to ${emacsDir}..."
      ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs "${emacsDir}"
    fi
  '';

  # Use emacsclient as the default editor, connecting to the running daemon.
  # Falls back to launching a regular Emacs frame if no daemon is running.
  home.sessionVariables.EDITOR = "${pkgs.emacs30-pgtk}/bin/emacsclient --create-frame --alternate-editor=${pkgs.emacs30-pgtk}/bin/emacs";

  # Persist Doom Emacs installation and packages
  home.persistence."/persist" = lib.mkIf config.home.evict.enable {
    directories = [
      "${config.home.evict.configDirName}/emacs"  # Doom Emacs installation at /users/kai/config/emacs
    ];
  };
}

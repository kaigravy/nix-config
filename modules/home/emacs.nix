{ pkgs, config, lib, ... }:

let
  configDir = "${config.home.homeDirectory}/${config.home.evict.configDirName}";
  doomDir   = "${configDir}/doom";
  emacsDir  = "${configDir}/emacs";
in
{
  # Install Emacs and enable the daemon via home-manager's services.emacs.
  # programs.emacs only writes an init.el if extraConfig is set — we don't set it,
  # so Doom's init.el is never touched.
  programs.emacs = {
    enable  = true;
    package = pkgs.emacs30-pgtk;
  };

  # Socket-activated daemon: Emacs only starts when emacsclient connects, which means
  # it never tries to grab a Wayland display at boot — solving the PGTK restart loop.
  services.emacs = {
    enable                  = true;
    package                 = pkgs.emacs30-pgtk;
    client.enable           = true;  # installs emacsclient wrapper and sets EDITOR
    socketActivation.enable = true;
  };

  # Doom dependencies
  home.packages = with pkgs; [
    git
    (ripgrep.override { withPCRE2 = true; })
    gnutls
    fd
    imagemagick
    pinentry-emacs
    zstd
    nodePackages.stylelint
    nodePackages.js-beautify
    emacs-all-the-icons-fonts
  ];

  # Tell Doom where its config and install directories are.
  # Mirrored into systemd.user.sessionVariables so the daemon service inherits them
  # via environment.d (same pattern used for XDG_CONFIG_HOME in shell.nix).
  home.sessionVariables = {
    DOOMDIR  = doomDir;
    EMACSDIR = emacsDir;
  };
  systemd.user.sessionVariables = {
    DOOMDIR         = doomDir;
    EMACSDIR        = emacsDir;
    XDG_CONFIG_HOME = configDir;
  };

  # Add doom binary to PATH for 'doom sync', 'doom doctor', etc.
  home.sessionPath = [ "${emacsDir}/bin" ];

  # On every rebuild, force-symlink config files from the repo into DOOMDIR.
  # ln -sfn overwrites any real files doom install/sync may have created, ensuring
  # the repo config always wins.
  home.activation.linkDoomConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $VERBOSE_ECHO "Linking Doom config to ${doomDir}"
    mkdir -p "${doomDir}/snippets"
    ln -sfn "${../../config/emacs/doom/init.el}"     "${doomDir}/init.el"
    ln -sfn "${../../config/emacs/doom/config.el}"   "${doomDir}/config.el"
    ln -sfn "${../../config/emacs/doom/packages.el}" "${doomDir}/packages.el"
  '';

  # Clone Doom itself on first activation (fast — no package install yet).
  home.activation.cloneDoom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "${emacsDir}/.git" ]; then
      $VERBOSE_ECHO "Cloning Doom Emacs to ${emacsDir}"
      ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs "${emacsDir}"
    fi
  '';

  # Run 'doom install' once at first login, before the socket becomes available.
  # ~/.local/share/doom/straight is only created after a successful install, so
  # this is a reliable sentinel that the service never repeats on subsequent logins.
  systemd.user.services.doom-install = {
    Unit = {
      Description         = "First-time Doom Emacs install";
      Before              = [ "emacs.socket" ];
      ConditionPathExists = "!${config.home.homeDirectory}/.local/share/doom/straight";
    };
    Service = {
      Type            = "oneshot";
      RemainAfterExit = true;
      ExecStart       = "${emacsDir}/bin/doom install --no-config --no-env";
      Environment     = [
        "DOOMDIR=${doomDir}"
        "EMACSDIR=${emacsDir}"
        "XDG_CONFIG_HOME=${configDir}"
        "PATH=${pkgs.emacs30-pgtk}/bin:${pkgs.git}/bin:/run/current-system/sw/bin"
      ];
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Persist the Doom installation across reboots.
  home.persistence."/persist" = lib.mkIf config.home.evict.enable {
    directories = [
      "${config.home.evict.configDirName}/emacs"
    ];
  };
}

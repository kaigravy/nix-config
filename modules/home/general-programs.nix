{ pkgs, lib, config, ... }:

let
  ankiWrapped = pkgs.symlinkJoin {
    name = pkgs.anki.name;
    paths = [ pkgs.anki ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/anki" \
        --set ANKI_WAYLAND 1
    '';
  };
in
{
  # Prepend GTK/GSettings schema paths to XDG_DATA_DIRS for the whole user
  # session. xdg.systemDirs.data appends rather than replaces, so it's safe
  # globally and fixes the 'org.gtk.Settings.FileChooser not installed' crash
  # for any GTK app (Anki, Scribus, etc.) launched from the GUI.
  xdg.systemDirs.data = [
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    "${pkgs.gtk3}/share"
    "${pkgs.shared-mime-info}/share"
  ];

  home.packages = with pkgs; [
    libreoffice-fresh hunspell hunspellDicts.en_AU-large
    gimp
    inkscape
    scribus
    audacity
    vlc
    calibre
    qbittorrent
    krita
    xournalpp
    obs-studio
    thunderbird
    zotero
    handbrake
    qalculate-gtk
    typst typstyle
    conjure
    soundconverter
    timeshift
    pairdrop
    rustdesk-flutter
    zint-qt
    kdePackages.okular
    shotcut
    blanket
    wordbook
    gnome-solanum
    ankiWrapped
    gImageReader
    picard
    virtualbox
  ];

  home.persistence."/persist" = lib.mkIf config.home.evict.enable {
    directories = [
      "${config.home.evict.configDirName}/local/share/Anki2"
    ];
  };
}


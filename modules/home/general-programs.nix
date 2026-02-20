{ pkgs, ... }:

{
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
        anki
	gImageReader
    ];
}


{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    dust
    aria2
    ffmpeg
    bat
    inxi
    mpv
    pandoc
    onefetch
    just
    ripgrep
    nmap
    gnupg
    imagemagick
    diff-so-fancy
    eza
    tldr
    streamlink
    yank
    sox
    hexyl
    yt-dlp
    fd
    croc
    f3
    entr
    jq
    exiftool
    ps_mem
    radio-active
    fzf
    localtunnel
    trash-cli
    htop
    neovim
    tmux
    zellij
    btop
    up
    astroterm
    bit-logo
    meteor-git
    serie
    tailspin
    bibiman
    wordgrinder
    lue
    ne
    tetris
    sc
  ];

  # Persist Trash so deleted files survive impermanence wipes
  home.persistence."/persist" = {
    directories = [ ".local/share/Trash" ];
  };
}

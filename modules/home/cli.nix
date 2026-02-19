{ pkgs, ... }:

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
  ];
}
{ pkgs, config, lib, ... }:

let
  pkgByNames = names:
    let
      found = builtins.filter (name: builtins.hasAttr name pkgs) names;
    in
    lib.optional (found != [ ]) (builtins.getAttr (builtins.head found) pkgs);

  localtunnelPkg =
    if builtins.hasAttr "localtunnel" pkgs then
      [ pkgs.localtunnel ]
    else if (builtins.hasAttr "nodePackages" pkgs) && (builtins.hasAttr "localtunnel" pkgs.nodePackages) then
      [ pkgs.nodePackages.localtunnel ]
    else
      [ ];

  userDataDir = "${config.home.homeDirectory}/${config.home.evict.homeDirName}/.local/share";
in
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
    tldr
    streamlink
    trash-cli
    sox
    hexyl
    yt-dlp
    fd
    croc
    f3
    entr
    jq
    exiftool
    fzf
  ]
  ++ localtunnelPkg
  ++ (pkgByNames [ "radio-active" "radio_active" "radioactive" ])
  ++ (pkgByNames [ "ps_mem" "psmem" ])
  ++ (pkgByNames [ "yank" ])
  ++ (pkgByNames [ "exa" "eza" ]);

  # Keep data files (including Trash) in the evict-managed home subtree.
  home.sessionVariables = {
    XDG_DATA_HOME = userDataDir;
  };

  # Persist trash-cli data with impermanence/evict.
  home.persistence."/persist" = lib.mkIf config.home.evict.enable {
    directories = [
      "${config.home.evict.homeDirName}/.local/share/Trash"
    ];
  };
}
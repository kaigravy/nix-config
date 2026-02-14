{ pkgs, config, inputs, ... }:

{
  imports = [
    inputs.nix-doom-emacs.hmModule
  ];

  programs.doom-emacs = {
    enable = true;
    doomDir = ../../config/emacs/doom;
  };
}

{ pkgs, config, inputs, ... }:

{
  imports = [
    inputs.nix-doom-emacs.hmModule
  ];

  services.emacs.enable = true;

  programs.doom-emacs = {
    enable = true;
    doomDir = ../../config/emacs/doom;
  };
}

{ inputs, ... }:

{
  imports = [
    ../../modules/nixos/boot.nix
    ../../modules/nixos/btrfs.nix
    ../../modules/nixos/impermanence.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/gnome.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/nix-settings.nix
    ../../modules/nixos/sops.nix
    ../../modules/nixos/ssh.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.kai = import ../../modules/home;
  };

  system.stateVersion = "25.11";
}

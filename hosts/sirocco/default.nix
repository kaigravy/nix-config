{ ... }:

{
  imports = [
    ../common
    ./disks.nix
    ./hardware.nix
  ];

  networking.hostName = "sirocco";
}

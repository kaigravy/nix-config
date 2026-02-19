{ ... }:

{
  imports = [
    ../common
    ./disks.nix
    ./hardware.nix
  ];

  networking.hostName = "sirocco";

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/disk-main-luks";
    allowDiscards = true;
  };
}

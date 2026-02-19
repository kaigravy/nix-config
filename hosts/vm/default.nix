{ ... }:

{
  imports = [
    ../common
    ./disks.nix
    ./hardware.nix
  ];

  networking.hostName = "vm";

  # Explicitly declare the LUKS device so the systemd initrd knows to unlock it.
  # disko names the GPT partition label "disk-main-luks" based on disk name "main"
  # and partition name "luks" in disks.nix.
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/disk-main-luks";
    allowDiscards = true;
  };
}

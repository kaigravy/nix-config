{ pkgs, ... }:

{
  imports = [
    ../common
    ./disks.nix
    ./hardware.nix
  ];

  networking.hostName = "sirocco";

  # ── Desktop packages ───────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    nvtopPackages.full  # GPU monitor (NVIDIA + shows CPU)
  ];

  # ── Firmware updates ───────────────────────────────────────────────────────
  # Delivers ASUS motherboard / peripheral firmware updates via fwupdmgr
  services.fwupd.enable = true;
}

{ pkgs, ... }:

{
  imports = [
    ../common
    ./disks.nix
    ./hardware.nix
  ];

  networking.hostName = "mistral";

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/disk-main-luks";
    allowDiscards = true;
  };

  # ── 4K display — GNOME HiDPI ──────────────────────────────────────────────
  # Integer 2× scaling is the sharpest option for a 15.6" 4K panel; enable the
  # mutter experimental feature so GNOME also exposes fractional options
  # (125 %, 150 %, 175 %) in Settings → Displays if you prefer.
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.mutter]
    experimental-features=['scale-monitor-framebuffer']
  '';

  # ── Laptop-specific packages ──────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    powertop      # analyse power consumption
    nvtopPackages.full  # GPU monitor (shows both Intel + NVIDIA)
  ];

  # ── Firmware updates ──────────────────────────────────────────────────────
  # Delivers Dell BIOS/firmware updates via GNOME Software / fwupdmgr
  services.fwupd.enable = true;
}

# Dell Precision 5550 hardware configuration
# CPU:  Intel Core i7-10850H (Comet Lake H, 6c/12t)
# iGPU: Intel UHD Graphics 630
# dGPU: NVIDIA Quadro T2000 Max-Q
# WiFi: Killer AX1650 (Intel AX200 chipset — iwlwifi, works out of the box)
#
# NVIDIA PRIME offload mode: iGPU drives the display; dGPU is available
# on demand (nvidia-offload <app>).  This gives the best battery life.
#
# IMPORTANT — before first install, verify the PCI bus IDs:
#   lspci | grep -E 'VGA|3D'
# Then update intelBusId / nvidiaBusId below (format: "PCI:<bus>:<slot>:<func>").
# Typical values for the Precision 5550:
#   Intel UHD 630  → 00:02.0  →  "PCI:0:2:0"
#   NVIDIA T2000   → 01:00.0  →  "PCI:1:0:0"
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.config.allowUnfree = true;

  # ── Kernel modules ────────────────────────────────────────────────────────
  # nvme: primary storage; thunderbolt/uas: Thunderbolt 3 dock
  boot.initrd.availableKernelModules = [
    "xhci_pci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  # ── CPU microcode ─────────────────────────────────────────────────────────
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;

  # ── Intel / NVIDIA hybrid graphics (PRIME offload) ────────────────────────
  # The display is driven by the iGPU; the dGPU only powers on when you
  # explicitly run an app with `nvidia-offload <app>` (or via .desktopItem).
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;   # needed for Vulkan / Steam compatibility
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;         # suspend/resume the dGPU with the system
      finegrained = true;    # RTD3 — power-gate dGPU when idle (requires Turing+)
    };
    open = false;            # Turing (TU117) is NOT supported by the open kernel module
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;  # installs `nvidia-offload` wrapper command
      };
      # ── Verify these with `lspci | grep -E 'VGA|3D'` ──────────────────
      intelBusId  = "PCI:0:2:0";   # Intel UHD 630  (00:02.0)
      nvidiaBusId = "PCI:1:0:0";   # NVIDIA T2000   (01:00.0)
    };
  };

  # ── Power / thermal ───────────────────────────────────────────────────────
  # thermald manages CPU temperature on Intel laptops
  services.thermald.enable = true;

  # TLP for battery charge management and radio power saving
  services.tlp = {
    enable = true;
    settings = {
      # Keep battery between 20–80 % to extend cell longevity
      START_CHARGE_THRESH_BAT0 = 20;
      STOP_CHARGE_THRESH_BAT0  = 80;
    };
  };

  # ── 4K / HiDPI display ────────────────────────────────────────────────────
  # GDM needs Wayland + correct scaling before the session starts.
  # 200 % (2×) is the native integer scale for 4K on a 15.6" panel; fractional
  # scaling (e.g. 150 %) is also available if you prefer it — see below.
  services.xserver.dpi = 192;   # hint for Xwayland / legacy X11 apps

  # Enable fractional scaling in GNOME (Wayland path)
  services.displayManager.gdm.wayland = true;

  # ── Platform ──────────────────────────────────────────────────────────────
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

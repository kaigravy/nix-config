# Sirocco desktop hardware configuration
# CPU:  Intel Core i7-4770 (Haswell, 4c/8t)
# GPU:  NVIDIA GeForce GTX 1070 (Pascal GP104) — sole display adapter, no iGPU output used
# WiFi: ASUS PCE-AC68 PCIe adapter (Broadcom BCM4360 — needs proprietary wl / broadcom-sta)
# Boot: UEFI, SATA SSD
#
# NOTE — confirm the SSD device path before install:
#   lsblk
# Update hosts/sirocco/disks.nix `device` if it is not /dev/sda.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.config.allowUnfree = true;
  # broadcom-sta is marked insecure in nixpkgs; match by name so it works
  # regardless of the exact version that nixpkgs ships.
  nixpkgs.config.allowInsecurePredicate = pkg: lib.getName pkg == "broadcom-sta";

  # ── Kernel modules ────────────────────────────────────────────────────────
  # ahci: SATA controller; ehci_pci: USB 2.0 on older boards
  boot.initrd.availableKernelModules = [
    "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"
  ];
  boot.kernelModules = [
    "kvm-intel"   # KVM hardware virtualisation
    "wl"          # Broadcom BCM4360 — proprietary Wi-Fi driver
  ];
  # Blacklist nouveau (conflicts with proprietary NVIDIA driver, causes hangs
  # on Wayland startup) and the open-source Broadcom drivers that conflict with wl.
  boot.blacklistedKernelModules = [
    "nouveau"
    "b43" "bcma" "ssb" "brcmsmac" "brcmfmac"
  ];
  # broadcom-sta must be listed here so its out-of-tree module is available
  # in initrd / early userspace.
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  # ── CPU microcode ─────────────────────────────────────────────────────────
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;

  # ── NVIDIA GTX 1070 (Pascal) — single-GPU desktop ─────────────────────────
  # No iGPU output is used so PRIME offload is NOT configured.
  # The GTX 1070 (GP104) does NOT support the open kernel module — keep open = false.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;   # required for Vulkan / Steam / 32-bit games
  };

  # nvidia_drm.fbdev=1 lets GDM/Wayland own the framebuffer from the start;
  # without it you can get a black screen or KMS failures on Wayland.
  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = false;       # desktop — no suspend/resume battery concern
      finegrained = false;  # RTD3 is a laptop feature; irrelevant here
    };
    open = false;           # Pascal (GP104) is not supported by the open module
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # No `prime` block — single GPU, no offload needed.
  };

  # ── Platform ──────────────────────────────────────────────────────────────
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

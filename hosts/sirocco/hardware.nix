# PLACEHOLDER - Replace with output of: nixos-generate-config --show-hardware-config
# Run this from the installer ISO after booting
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Allow unfree and insecure packages for hardware drivers
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "broadcom-sta-6.30.223.271"  # Required for ASUS PCE-AC68 Wi-Fi card
    ];
  };

  # Intel i7-4770 (Haswell architecture)
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" "wl" ];  # KVM virtualization + Broadcom Wi-Fi
  
  # NVIDIA GTX 1070 support
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # Use the proprietary driver
    modesetting.enable = true;
    # Enable power management (recommended for desktop too)
    powerManagement.enable = false;
    # Use the production branch driver
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # Enable nvidia-settings menu
    nvidiaSettings = true;
    # Enable open-source kernel modules (not available for GTX 1070, keeping closed source)
    open = false;
  };
  
  # ASUS PCE-AC68 Wi-Fi card driver (Broadcom BCM4360)
  # This card uses the broadcom-sta driver (wl)
  hardware.enableRedistributableFirmware = true;
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  # Blacklist conflicting open-source drivers
  boot.blacklistedKernelModules = [ "b43" "bcma" "ssb" "brcmsmac" "brcmfmac" ];
  
  # Enable CPU microcode updates
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  
  # Enable 32-bit support for Steam and other applications
  hardware.graphics.enable32Bit = true;
  
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

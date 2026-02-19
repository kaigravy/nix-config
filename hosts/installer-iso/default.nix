{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
  ];

  # Allow unfree and insecure packages (needed for Broadcom Wi-Fi driver)
  nixpkgs.config = {
    allowUnfree = true;
    allowInsecurePredicate = pkg: lib.getName pkg == "broadcom-sta";
  };

  # NVIDIA: disable modesetting to prevent blank screen / flashing cursor on boot.
  # The ISO has no NVIDIA driver, so the GPU must not attempt KMS.
  # nomodeset forces the kernel to use a basic framebuffer (VESA/EFI) so GNOME
  # can start via software rendering (llvmpipe).
  boot.kernelParams = [ "nomodeset" ];
  # Blacklist nouveau so it doesn't partially init the GPU and hang.
  boot.blacklistedKernelModules = [ "nouveau" "b43" "bcma" "ssb" "brcmsmac" "brcmfmac" ];

  # Enable Wi-Fi support for ASUS PCE-AC68 (Broadcom BCM4360)
  hardware.enableRedistributableFirmware = true;
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  # Don't auto-load wl module at boot - load it manually after boot if needed
  # This prevents boot issues if the driver conflicts with hardware detection
  # boot.kernelModules = [ "wl" ];
  
  # Enable NetworkManager for easy Wi-Fi setup
  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false;  # Disable wpa_supplicant (conflicts with NetworkManager)
  
  # Include useful tools for installation
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
    pciutils  # lspci to identify hardware
    usbutils  # lsusb
    parted
    gptfdisk
    cryptsetup
    btrfs-progs
    mkpasswd
  ];
  
  # Enable SSH for remote installation (optional)
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  
  # Automatically log in as nixos user
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };
  
  # Enable flakes in the ISO
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Set a reasonable console font for the installer
  console.font = "Lat2-Terminus16";
  console.keyMap = "us";
  
  # Don't bloat the ISO with build dependencies - clone from GitHub instead
  isoImage.includeSystemBuildDependencies = false;
  
  system.stateVersion = "25.11";
}

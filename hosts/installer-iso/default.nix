{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
  ];

  # Allow unfree and insecure packages (needed for Broadcom Wi-Fi driver)
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "broadcom-sta"
    ];
  };

  # Enable Wi-Fi support for ASUS PCE-AC68 (Broadcom BCM4360)
  hardware.enableRedistributableFirmware = true;
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.kernelModules = [ "wl" ];
  # Blacklist conflicting open-source drivers
  boot.blacklistedKernelModules = [ "b43" "bcma" "ssb" "brcmsmac" "brcmfmac" ];
  
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
  
  # Include this flake in the ISO for easy installation
  # You can also clone from GitHub, but this is convenient
  isoImage.includeSystemBuildDependencies = true;
  
  system.stateVersion = "25.11";
}

{ pkgs, lib, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot = {
    plymouth = {
      enable = true;
      theme = "cuts";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = ["rings"];
        })
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
  };

  # Roll back ephemeral subvolumes to blank snapshots on every boot.
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir -p /mnt
    mount /dev/mapper/cryptroot /mnt -t btrfs -o subvol=/

    rollback_subvol() {
      local name="$1"
      if [ -d "/mnt/''${name}-blank" ]; then
        echo "Deleting @$name and all nested subvolumes..."
        btrfs subvolume list -o "/mnt/$name" |
          cut -f9 -d' ' |
          sort -r |
          while read -r subvol; do
            echo "  deleting /$subvol ..."
            btrfs subvolume delete "/mnt/$subvol"
          done
        btrfs subvolume delete "/mnt/$name"
        echo "Restoring @$name from blank snapshot..."
        btrfs subvolume snapshot "/mnt/''${name}-blank" "/mnt/$name"
      else
        echo "WARNING: ''${name}-blank snapshot not found, skipping rollback"
      fi
    }

    rollback_subvol @root
    rollback_subvol @home

    umount /mnt
  '';
}

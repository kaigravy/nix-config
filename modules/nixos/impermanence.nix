{ ... }:

{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/log"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  # Persist SOPS keys directory
  systemd.tmpfiles.rules = [
    "d /persist/sops 0755 root root -"
  ];

  # Allow home-manager impermanence bind mounts via FUSE
  programs.fuse.userAllowOther = true;

  # Ephemeral filesystems must be available early for bind mounts during activation
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/users".neededForBoot = true;
}

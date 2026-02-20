{ ... }:

{
  # Pre-create ~/.ssh with strict permissions so that sops can write the SSH
  # keys into it at boot (see sops.nix for the secret definitions).
  #
  # The /users filesystem is persistent (neededForBoot = true in
  # impermanence.nix), so this directory survives reboots.  Sops writes the
  # decrypted keys here only when /persist/sops/age-keys.txt is present;
  # without it the directory still exists but is empty — the system boots
  # normally and SSH keys appear on the next reboot after you add your age key.
  systemd.tmpfiles.rules = [
    "d /users/kai/.ssh 0700 kai users -"
  ];
}

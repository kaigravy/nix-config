{ config, lib, ... }:

{
  # SOPS configuration for secret management
  sops = {
    # Default SOPS file location
    defaultSopsFile = ../../secrets/secrets.yaml;

    # Age key file location (persisted across reboots).
    # If this file does not exist (e.g. on a fresh machine before bootstrapping),
    # sops decryption will fail silently and secrets simply won't be present.
    # Add age-keys.txt and reboot to populate all secrets.
    age.keyFile = "/persist/sops/age-keys.txt";

    # validateSopsFiles = false allows the system to build and boot even when
    # the age key is absent or secrets.yaml has entries not yet encrypted for
    # this host.  Graceful degradation: missing key → no secrets populated,
    # everything else works normally.
    validateSopsFiles = false;

    secrets = {
      # Filen cloud CLI credentials
      "filen-cli-auth" = {
        owner = config.users.users.kai.name;
        mode = "0400";
      };

      # SSH keys — written directly to ~/.ssh by sops at boot.
      # Each key pair lives under a named sub-key in secrets.yaml:
      #   ssh:
      #     github: |
      #       -----BEGIN OPENSSH PRIVATE KEY-----
      #       ...
      #       -----END OPENSSH PRIVATE KEY-----
      #     github_pub: "ssh-ed25519 AAAA... kai@hostname"
      # To add more key pairs in future, add another sub-key here and
      # a matching entry in secrets.yaml (e.g. ssh/work, ssh/work_pub).
      "ssh/github" = {
        path  = "/users/kai/.ssh/github";
        owner = config.users.users.kai.name;
        mode  = "0600";
      };

      "ssh/github_pub" = {
        path  = "/users/kai/.ssh/github.pub";
        owner = config.users.users.kai.name;
        mode  = "0644";
      };
    };
  };
}

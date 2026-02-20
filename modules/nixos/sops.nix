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

      # SSH private key — written directly to ~/.ssh by sops at boot.
      # Add to secrets.yaml with:
      #   nix-shell -p sops --run "sops secrets/secrets.yaml"
      # then paste your private key under the key path:
      #   ssh/id_ed25519: |
      #     -----BEGIN OPENSSH PRIVATE KEY-----
      #     ...
      #     -----END OPENSSH PRIVATE KEY-----
      "ssh/id_ed25519" = {
        path  = "/users/kai/.ssh/id_ed25519";
        owner = config.users.users.kai.name;
        mode  = "0600";
      };

      # SSH public key
      "ssh/id_ed25519_pub" = {
        path  = "/users/kai/.ssh/id_ed25519.pub";
        owner = config.users.users.kai.name;
        mode  = "0644";
      };
    };
  };
}

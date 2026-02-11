{ config, ... }:

{
  # SOPS configuration for secret management
  sops = {
    # Default SOPS file location
    defaultSopsFile = ../../secrets/secrets.yaml;
    
    # Age key file location (persisted across reboots)
    age.keyFile = "/persist/sops/age-keys.txt";
    
    # Validate sops files at activation time
    # Set to false to allow home-manager to work even if secrets aren't set up yet
    validateSopsFiles = false;

    # Define secrets to be decrypted
    secrets."filen-cli-auth" = {
      # The secret will be available at /run/secrets/filen-cli-auth
      # This path is accessible by the kai user
      owner = config.users.users.kai.name;
      mode = "0400";
    };
  };
}

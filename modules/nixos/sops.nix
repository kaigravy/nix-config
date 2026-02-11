{ config, lib, ... }:

let
  # Check if the age key file exists
  ageKeyExists = builtins.pathExists /persist/sops/age-keys.txt;
  # Check if secrets file exists and is not the template
  secretsFileExists = builtins.pathExists ../../secrets/secrets.yaml;
in
{
  # SOPS configuration for secret management
  # Only activate if the age key exists
  sops = lib.mkIf ageKeyExists {
    # Default SOPS file location
    defaultSopsFile = ../../secrets/secrets.yaml;
    
    # Age key file location (persisted across reboots)
    age.keyFile = "/persist/sops/age-keys.txt";
    
    # Validate sops files at activation time
    # Set to false to allow building even if secrets file isn't properly encrypted yet
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

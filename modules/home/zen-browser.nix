{ inputs, pkgs, config, lib, ... }:

{
  home.packages = [
    inputs.zen-browser.packages.${pkgs.system}.default
  ];

  # Set Zen browser profile directory to /users/kai/config/zen
  home.file.".zen/.keep".text = "";  # Prevent default ~/.zen usage
  
  home.sessionVariables = {
    # Point Zen to use the config directory directly
    MOZ_USER_DIR = "${config.home.homeDirectory}/${config.home.evict.configDirName}/zen";
  };

  # Browser data will be at /users/kai/config/zen (ephemeral by default)
  
  # If you want to persist browser data, uncomment this:
  # home.persistence."/persist/users/kai" = lib.mkIf config.home.evict.enable {
  #   directories = [
  #     "${config.home.evict.configDirName}/zen"  # Persists /users/kai/config/zen
  #   ];
  #   allowOther = true;
  # };
}

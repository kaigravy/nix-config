{ pkgs, ... }:

{
  # Passwords are managed declaratively via files in /persist.
  # Generate with: mkpasswd -m sha-512
  users.mutableUsers = false;

  users.defaultUserHome = "/users";

  users.users.kai = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPasswordFile = "/persist/passwords/kai";
    shell = pkgs.zsh;
  };

  users.users.root = {
    hashedPasswordFile = "/persist/passwords/root";
  };
  
  # Enable zsh system-wide
  programs.zsh.enable = true;
}
